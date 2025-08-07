require_relative 'tracking_channel'

class TrackingManager
  def initialize
    @sessions = {} # hoster_id => Tracking_Channel
  end

  # --- Session Management ---

  # Start tracking a user in a voice channel
  def start_tracking(channel, server_id, hoster)
    # stop_tracking(hoster.id) if tracking?(hoster.id) && active?(hoster.id)
    return puts "Channel tracked already" if session_for_channel(channel)
    return puts "Hoster tracked already" if session_for_hoster(hoster)

    # session = Tracking_Channel.from_discord(channel, hoster.id)
    session = Tracking_Channel.from_discord(channel, server_id, hoster)
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

  # Classify the voice change event
  def classify_change(before:, after:)
    was_tracked = active_channel?(before)
    is_tracked  = active_channel?(after)

    return :no_change if !was_tracked && !is_tracked
    return :same_channel if before&.id == after&.id

    case [was_tracked, is_tracked] # rubocop:disable Layout/SpaceInsideArrayLiteralBrackets
    in [true, true]  then :switched_between_tracked # rubocop:disable Layout/SpaceInsideArrayLiteralBrackets
    in [true, false] then :exited_tracked # rubocop:disable Layout/SpaceInsideArrayLiteralBrackets
    in [false, true] then :entered_tracked # rubocop:disable Layout/SpaceInsideArrayLiteralBrackets
    else                   :no_change
    end
  end

  # Run action based on event type
  def handle_voice_change(event, before:, after:, &block)
    return unless involved_in_tracked?(before: before, after: after)

    case classify_change(before: before, after: after)
    in :switched_between_tracked
      block&.(:switched, event, from: before, to: after)

    in :exited_tracked
      if after
        block&.(:switched_out, event, from: before, to: after)
      else
        block&.(:disconnected, event, last: before)
      end

    in :entered_tracked
      if before
        block&.(:switched_in, event, from: before, to: after)
      else
        block&.(:connected_in, event, channel: after)
      end

    in :same_channel
      block&.(:no_change, event, channel: after)
    end
  end

  # --- Debug / List Active Sessions ---

  def active_sessions
    @sessions.values.select(&:active?)
  end

  def count_active
    active_sessions.size
  end

  def inspect
    "#<TrackingManager active=#{count_active}>"
  end
end

# HostStruct = Struct.new(:name, :id)
# hoster = HostStruct.new("Steve", 1)
# puts hoster

# DiscordChannel = Struct.new(:id, :name, :guild_id, :server_id)
# discord_channel = DiscordChannel.new(123456789, "General", 987654321, 987654321)
# puts discord_channel

# tracking_manager = TrackingManager.new
# tm = tracking_manager.start_tracking(discord_channel, hoster)
# puts tm.inspect
