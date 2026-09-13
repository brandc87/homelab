# Tautulli

This role installs Tautulli and the pinned JBOPS `kill_stream.py` helper. The
helper is installed at `/opt/tautulli-scripts/kill_stream.py`.

## Block Plex video transcoding

After Tautulli is connected to Plex, add the notification agent in the
Tautulli UI:

1. Open **Settings > Notification Agents > Add a new notification agent > Script**.
2. Under **Configuration**, select:
   - Script folder: `/opt/tautulli-scripts`
   - Script file: `kill_stream.py`
3. Enable both **Playback Start** and **Transcode Decision Change** under
   **Triggers**. The second trigger catches a stream that starts with Direct
   Play and switches to transcoding later.
4. Add the condition **Video Decision is transcode**. If audio transcoding
   should also be blocked, use **Transcode Decision is transcode** instead;
   this is stricter and can terminate Direct Stream sessions that only
   transcode audio.
5. Set the following arguments for both enabled triggers:

   ```text
   --jbop stream --userId {user_id} --username {username} --sessionId {session_id} --killMessage "Video transcoding is disabled on this server. Please adjust your Plex quality settings."
   ```

6. Save the agent, then test with a non-critical Plex client configured to
   request a lower quality than the source.

The script uses the `TAUTULLI_URL` and `TAUTULLI_APIKEY` environment variables
that Tautulli supplies to notification scripts. Plex must allow the account
used by Tautulli to terminate sessions.
