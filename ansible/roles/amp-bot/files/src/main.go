package main

import (
	"encoding/json"
	"log"
	"net/http"
	"os"
	"os/signal"
	"strconv"
	"sync"
	"syscall"
	"time"

	"github.com/bwmarrin/discordgo"
)

type ampEvent struct {
	Event     string `json:"event"`
	User      string `json:"user"`
	State     string `json:"state"`
	UserCount string `json:"userCount"`
	MaxUsers  string `json:"maxUsers"`
	CPU       string `json:"cpu"`
	RAM       string `json:"ram"`
}

type StatusCache struct {
	mu     sync.RWMutex
	latest ampEvent
	known  bool
}

func (c *StatusCache) Set(ev ampEvent) {
	c.mu.Lock()
	defer c.mu.Unlock()
	c.latest = ev
	c.known = true
}

func (c *StatusCache) Get() (ampEvent, bool) {
	c.mu.RLock()
	defer c.mu.RUnlock()
	return c.latest, c.known
}

// IdleTracker watches player counts over time and decides when the server
// has been empty long enough to trigger an auto-shutdown, firing only once
// per idle period (resets once a player reconnects).
type IdleTracker struct {
	mu            sync.Mutex
	lastNonZero   time.Time
	shutdownFired bool
	idleThreshold time.Duration
}

func NewIdleTracker(threshold time.Duration) *IdleTracker {
	return &IdleTracker{
		lastNonZero:   time.Now(), // assume active at startup, avoids instant-trigger on boot
		idleThreshold: threshold,
	}
}

// Update reports the current player count and returns true exactly once
// when the idle threshold has just been crossed.
func (t *IdleTracker) Update(userCount string) bool {
	t.mu.Lock()
	defer t.mu.Unlock()

	count, err := strconv.Atoi(userCount)
	if err != nil {
		return false // unparseable count, don't act on it
	}

	if count > 0 {
		t.lastNonZero = time.Now()
		t.shutdownFired = false
		return false
	}

	if t.shutdownFired {
		return false // already fired for this idle stretch
	}

	if time.Since(t.lastNonZero) >= t.idleThreshold {
		t.shutdownFired = true
		return true
	}

	return false
}

func main() {
	botToken := mustEnv("DISCORD_BOT_TOKEN")
	guildID := mustEnv("DISCORD_GUILD_ID")
	channelID := mustEnv("DISCORD_CHANNEL_ID")
	ampURL := mustEnv("AMP_URL")
	ampInstance := mustEnv("AMP_INSTANCE_ID")
	webhookSecret := mustEnv("WEBHOOK_SHARED_SECRET")
	webhookToken := mustEnv("AMP_WEBHOOK_TOKEN")
	listenAddr := envOr("LISTEN_ADDR", "0.0.0.0:8090")
	idleMinutes := envIntOr("EMPTY_SHUTDOWN_MINUTES", 60)

	amp := NewAMPClient(ampURL, ampInstance)
	statusCache := &StatusCache{}
	idleTracker := NewIdleTracker(time.Duration(idleMinutes) * time.Minute)

	dg, err := discordgo.New("Bot " + botToken)
	if err != nil {
		log.Fatalf("failed to create discord session: %v", err)
	}

	dg.AddHandler(func(s *discordgo.Session, r *discordgo.Ready) {
		log.Printf("logged in as %s", r.User.String())
		registerCommands(s, guildID)
	})
	dg.AddHandler(func(s *discordgo.Session, i *discordgo.InteractionCreate) {
		if i.Type == discordgo.InteractionApplicationCommand {
			handleInteraction(amp, statusCache, webhookToken)(s, i)
		}
	})

	if err := dg.Open(); err != nil {
		log.Fatalf("failed to open discord connection: %v", err)
	}
	defer dg.Close()

	mux := http.NewServeMux()
	mux.HandleFunc("/amp-event", func(w http.ResponseWriter, r *http.Request) {
		if r.Header.Get("X-Webhook-Secret") != webhookSecret {
			http.Error(w, "unauthorized", http.StatusUnauthorized)
			return
		}
		if r.Method != http.MethodPost {
			http.Error(w, "method not allowed", http.StatusMethodNotAllowed)
			return
		}

		var ev ampEvent
		if err := json.NewDecoder(r.Body).Decode(&ev); err != nil {
			http.Error(w, "bad request", http.StatusBadRequest)
			return
		}

		switch ev.Event {
		case "join":
			sendChannelMessage(dg, channelID, "🟢 **"+ev.User+"** entered the world")
		case "leave":
			sendChannelMessage(dg, channelID, "🔴 **"+ev.User+"** exited the world")
		case "status":
			statusCache.Set(ev)
			if idleTracker.Update(ev.UserCount) {
				log.Printf("server idle for %d+ minutes, triggering shutdown", idleMinutes)
				sendChannelMessage(dg, channelID, "😴 No one has been online for a while, shutting the server down to save resources. Use `/startserver` to bring it back up.")
				if err := amp.TriggerWebhook(webhookToken, "stop-server"); err != nil {
					log.Printf("failed to trigger auto-shutdown: %v", err)
					sendChannelMessage(dg, channelID, "⚠️ Tried to auto-shutdown but the request to AMP failed.")
				}
			}
		default:
			http.Error(w, "unknown event", http.StatusBadRequest)
			return
		}

		w.WriteHeader(http.StatusOK)
	})

	go func() {
		log.Printf("webhook listener starting on %s", listenAddr)
		if err := http.ListenAndServe(listenAddr, mux); err != nil {
			log.Fatalf("http server failed: %v", err)
		}
	}()

	stop := make(chan os.Signal, 1)
	signal.Notify(stop, os.Interrupt, syscall.SIGTERM)
	<-stop
	log.Println("shutting down")
}

func sendChannelMessage(dg *discordgo.Session, channelID, msg string) {
	if _, err := dg.ChannelMessageSend(channelID, msg); err != nil {
		log.Printf("failed to send discord message: %v", err)
	}
}

func mustEnv(key string) string {
	v := os.Getenv(key)
	if v == "" {
		log.Fatalf("missing required env var: %s", key)
	}
	return v
}

func envOr(key, fallback string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return fallback
}

func envIntOr(key string, fallback int) int {
	v := os.Getenv(key)
	if v == "" {
		return fallback
	}
	n, err := strconv.Atoi(v)
	if err != nil {
		return fallback
	}
	return n
}
