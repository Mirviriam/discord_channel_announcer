require 'date'
class Tracking_Channel
  attr_reader :id, :name, :channel, :server_id, :hoster_id
  attr_reader :host_started, :host_stopped

  def initialize(id, name, channel, server_id, hoster_id, host_started = DateTime.now)
    @id = id
    @name = name
    @channel = channel
    @server_id = server_id
    @hoster_id = hoster_id
    @host_started = host_started
  end

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

  def active?
    @host_stopped.nil?
  end

  def to_s
    "<Tracking_Channel id=#{@id} name='#{@name}' hoster=#{@hoster_id} started=#{@host_started}>"
  end
end

# DiscordChannel = Struct.new(:id, :name, :guild_id, :server_id)

# discord_channel = DiscordChannel.new(123456789, "General", 987654321, 987654321)
# # tc = Tracking_Channel.from_discord(discord_channel, 1, 1)
# tc = Tracking_Channel.new(123456789, "General", discord_channel, 987654321, 1)
# puts tc
