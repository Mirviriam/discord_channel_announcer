require_relative 'tracking_channel'

  def empty_check(param, param_name = "parameter")
    if param.nil? || param == "" || (param.respond_to?(:blank?) && param.blank?)
      raise ArgumentError, "#{param_name} is required"
    end
  end

class TrackingManager
  def initialize
    @sessions = {} # hoster_id => Tracking_Channel
    @sessions_over = {} # hoster_id => Tracking_Channel
  end

  # --- Session Management ---

  # Start tracking a user in a voice channel
  def start_tracking_channel(channel, server_id, hoster_id)
  return if tracking?(hoster_id) && active?(hoster_id)

  empty_check(channel, "channel")
  empty_check(server_id, "server_id")
  empty_check(hoster_id, "hoster_id")

    puts "Channel: #{channel.name} (ID: #{channel.id})"

    # session = Tracking_Channel.from_discord(channel, hoster.id)
    session = Tracking_Channel.from_discord(channel, server_id, hoster_id)
    @sessions[hoster_id] = session
    puts "Starting tracking for hoster: (#{hoster_id}) in channel: #{session.name} (ID: #{session.id})"
    session.channel.send 'Fleet Commander has started tracking fleet members!'
    session.channel.send 'Please rejoin voice channel to be tracked.'
    session
  end

  # Remove tracking a hoster (e.g., stream ended)
  def stop_tracking_channel(hoster_id)
    session = @sessions[hoster_id]
    return nil unless session&.active?
    puts "Stopping tracking for hoster: (#{hoster_id}) in channel: #{session.name} (ID: #{session.id})"

    session.set_end_time
    @sessions_over[hoster_id] = session
    @sessions.delete(hoster_id)
    session.channel.send 'Fleet Commander has stopped tracking fleet members!'
    session
  end

  # --- Query Methods --- #

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

  # --- Event Helpers --- #

  # Was the user in a tracked channel, or did they join one?
  def involved_in_tracked?(before:, after:)
    [ before, after ].compact.any? { |ch| active_channel?(ch) }
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
# tm = tracking_manager.start_tracking_channel(discord_channel, hoster)
# puts tm.inspect
