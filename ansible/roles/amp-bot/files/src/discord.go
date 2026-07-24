package main

import (
	"fmt"

	"github.com/bwmarrin/discordgo"
)

var commands = []*discordgo.ApplicationCommand{
	{
		Name:        "startserver",
		Description: "Start the Palworld server",
	},
	{
		Name:        "serverinfo",
		Description: "Check if the Palworld server is online",
	},
}

func registerCommands(s *discordgo.Session, guildID string) {
	for _, cmd := range commands {
		_, err := s.ApplicationCommandCreate(s.State.User.ID, guildID, cmd)
		if err != nil {
			fmt.Printf("failed to register command %s: %v\n", cmd.Name, err)
		}
	}
}

func handleInteraction(amp *AMPClient, statusCache *StatusCache, webhookToken string) func(s *discordgo.Session, i *discordgo.InteractionCreate) {
	return func(s *discordgo.Session, i *discordgo.InteractionCreate) {
		switch i.ApplicationCommandData().Name {
		case "startserver":
			respond(s, i, "🟡 Starting the server...")
			if err := amp.TriggerWebhook(webhookToken, "start-server"); err != nil {
				followUp(s, i, fmt.Sprintf("❌ Failed to start server: %v", err))
				return
			}
			followUp(s, i, "✅ Start command sent to AMP.")

		case "serverinfo":
			ev, known := statusCache.Get()
			if !known {
				respond(s, i, "⚠️ No status received from AMP yet. Status updates every minute once the server has run at least one status check.")
				return
			}
			msg := fmt.Sprintf(
				"📊 Status: %s\n👥 Players: %s / %s\n⚙️ CPU: %s%%\n💾 RAM: %s MB",
				formatState(ev.State), ev.UserCount, ev.MaxUsers, ev.CPU, ev.RAM,
			)
			respond(s, i, msg)
		}
	}
}

func respond(s *discordgo.Session, i *discordgo.InteractionCreate, msg string) {
	s.InteractionRespond(i.Interaction, &discordgo.InteractionResponse{
		Type: discordgo.InteractionResponseChannelMessageWithSource,
		Data: &discordgo.InteractionResponseData{Content: msg},
	})
}

func followUp(s *discordgo.Session, i *discordgo.InteractionCreate, msg string) {
	s.FollowupMessageCreate(i.Interaction, true, &discordgo.WebhookParams{Content: msg})
}

func formatState(state string) string {
	switch state {
	case "Ready":
		return "🟢 **Server is online**"
	case "Stopped", "Undefined":
		return "🔴 **Server is offline**"
	case "PreStart", "Starting", "Configuring":
		return "🟡 **Server is starting...**"
	case "Stopping":
		return "🟡 **Server is stopping...**"
	case "Failed":
		return "❌ **Server failed to start**"
	case "Suspended":
		return "⏸️ **Server is suspended**"
	default:
		return "❔ **Status: " + state + "**"
	}
}
