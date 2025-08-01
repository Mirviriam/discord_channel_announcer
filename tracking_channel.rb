class Tracking_Channel
  # @return [Discorb::Snowflake] The ID of the channel
  attr_reader :id, :name, :channel, :server_id, :hoster_id
  attr_reader :host_started, :host_stopped

  # Initializes a new Channel instance
  def initialize(id, name, channel, server_id, hoster_id, host_started = DateTime.now)
    @id = id
    @name = name
    @channel = channel
    @server_id = server_id
    @hoster_id = hoster_id
    @host_started = host_started
  end

  # Checks if the channel is the same as another channel
  def ==(other)
    return false unless other.respond_to?(:id)
    @id == other.id
  end

  def set_end_time(host_stopped = DateTime.now)
    @host_stopped = host_stopped
  end

  def self.from_discord(channel, hoster_id, started = DateTime.now)
    new(channel.id, channel.name, channel, channel.guild_id, hoster_id, started)
  end
end
