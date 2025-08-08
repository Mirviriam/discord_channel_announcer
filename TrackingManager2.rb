class TrackingManager
  def initialize
    @sessions = {} # hoster_id => Tracking_Channel
  end

  # --- Session Management ---

  # Start tracking a user in a voice channel
  def start_tracking(channel, hoster)
     # TODO do we want to stop tracking if already tracking?
     stop_tracking(hoster.id) if tracking?(hoster.id) && active?(hoster.id)

    session = Tracking_Channel.from_discord(channel, hoster.id)
    @sessions[hoster.id] = session
    session
  end

  # Stop tracking a hoster (e.g., stream ended)
  def stop_tracking(hoster_id)
    session = @sessions[hoster_id]
    return nil unless session&.active?

    session.set_end_time
    @sessions.delete(hoster_id)
    session
  end

  # --- Query Methods ---

  # Is this hoster currently being tracked?
  def tracking?(hoster_id)
    @sessions.key?(hoster_id)
  end

  # Is the hoster's session still active?
  def active?(hoster_id)
    session = @sessions[hoster_id]
    session&.active?
  end

  # Is the given channel currently being actively tracked by anyone?
  def active_channel?(channel)
    return false unless channel&.id
    @sessions.values.any? { |t| t.active? && t.id == channel.id }
  end

  # Get the active tracking session for a channel (if any)
  def session_for_channel(channel)
    return nil unless channel&.id
    @sessions.values.find { |t| t.active? && t.id == channel.id }
  end

  # Get the tracking session for a hoster
  def session_for_hoster(hoster_id)
    @sessions[hoster_id]
  end

  # --- Event Helpers ---

  # Was the user in a tracked channel, or did they join one?
  def involved_in_tracked?(before:, after:)
    [ before, after ].compact.any? { |ch| active_channel?(ch) }
  end
end
