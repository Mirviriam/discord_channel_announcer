class Tracking_Channel
  # @return [Discorb::Snowflake] The ID of the channel
  attr_reader :id
  attr_reader :name
  attr_reader :server_id
  attr_reader :hoster_id
  attr_reader :host_started
  attr_reader :host_stopped

  # Initializes a new Channel instance
  def initialize(id, name, hoster_id, host_started = DateTime.now)
    @id = id
    @name = name
    @hoster_id = hoster_id
    @host_started = host_started
  end

  # Checks if the channel is the same as another channel
  def ==(other)
    return false unless other.respond_to?(:id)
    @id == other.id
  end
end

  def set_end_time(host_stopped = DateTime.now)
    @host_stopped = host_stopped
  end
