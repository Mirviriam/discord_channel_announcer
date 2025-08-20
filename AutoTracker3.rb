# This simple bot responds to every "Ping!" message with a "Pong!"
require 'dotenv/load' # Load environment variables from .env file
require 'discordrb'
# require_relative 'tracking_channel'
require_relative 'TrackingManager3'

# TODO: extract these constants to a config file
# TODO: restructure so command_name first, then verb in word order
# .freeze makes the string immutable, a good practice for constants
Bot_Prefix = '!'.freeze
START_VERB = "Start".freeze
STOP_VERB = "Stop".freeze
COMMAND_NAME = "Tracking".freeze
START_CMD = "#{Bot_Prefix}#{START_VERB}-#{COMMAND_NAME}".freeze
STOP_CMD = "#{Bot_Prefix}#{STOP_VERB}-#{COMMAND_NAME}".freeze
MyEventChannel = 'General'.freeze
START_REPLY = 'Where does one ever truly begin?'.freeze

server_id = ENV['DISCORD_SERVER_TEST_ID']
channel_tracker = TrackingManager.new

bot = Discordrb::Bot.new(
  name: ENV['DISCORD_BOT_NAME'],
  token: ENV['DISCORD_BOT_TOKEN'],
  client_id: ENV['DISCORD_CLIENT_ID']
)

# Bot ready and invite to server necessary?
bot.ready do |event|
  puts 'Bot is ready!'
  puts "Bot Name: #{bot.name}"

  bot.servers.each do |server|
    puts "Server: #{server[1].name} (ID: #{server[0]})"
    # Here we check if the bot is already on the server with the ID MyServerID
    if server.any? { |b| b == server_id }
      puts 'Bot is already on server!'
    else
      puts "Bot is not on server: #{server[1].name}"
      puts "Click this invite URL to add it:  #{bot.invite_url}"
    end
  end
end

# !Start-Tracking command
bot.message(content: START_CMD) do |event|
  author_id = event.author.id
  hoster_name = bot.server(server_id).member(author_id).display_name

  # Calls to notifier must be after it's defined
  event.respond "Command received Fleet Commander #{hoster_name} - Standby..."

  voice_channel = bot.server(server_id).member(author_id).voice_channel

  # Adding tracking for channel, object handles is it already tracked
  channel_tracker.start_tracking_channel(voice_channel, server_id, author_id)
  # rather than calling from old data, we are using the object now as source of truth
  session = channel_tracker.session_for_channel(voice_channel)

  # Must be in a channel to start tracking
  if voice_channel.nil?
    event.respond 'Host needs to be in a voice channel to track it.'
    next
  else
    event.respond 'Everything you create, you use to destroy -L'
    event.respond "Beginning tracking of channel #{voice_channel.name} (ID: #{voice_channel.id})"
  end
end

# TODO:  The tests
# Test:  Stopping in channel, not in channel + if tracking started not in channel (cause nothing there to end tracking)

# !Stop-Tracking command
bot.message(content: STOP_CMD) do |event|
  hoster_name = bot.server(server_id).member(event.author.id).display_name
  event.respond "Command received Fleet Commander #{hoster_name} - Standby..."

  session = channel_tracker.session_for_hoster(event.author.id)

  event.respond 'Stopping tracking of fleet members!'
  event.respond 'Bzzzzt - End of transmission -RR'
end

bot.voice_state_update do |event|
  before = event.old_channel
  after = event.channel
  user_name = bot.server(server_id).member(event.user.id).display_name

  # Only track the specific channel
  next unless channel_tracker.involved_in_tracked?(before: before, after: after)

  # Setup the following decision structure to be a bit more comprehensible even if it disconnects logic
  tracked_channel = channel_tracker.session_for_channel(after) || channel_tracker.session_for_channel(before)

  timestamp = Time.now

  # this grabs the extra variables that are already declared due to lambda scope quirk
  format_message = ->(verb) { "#{timestamp} -- #{user_name} #{verb} #{tracked_channel.name}" }

  if before.nil? && after
    message = format_message.call 'joined'
  elsif before && after.nil?
    message = format_message.call 'left'
  elsif before != after && before&.id == tracked_channel.id
    message = format_message.call 'left'
  elsif before != after && after&.id == tracked_channel.id
    message = format_message.call 'joined'
  else
  end
  tracked_channel.channel.send message
  event.respond message if verbose_mode
end


bot.run

# this took an hour and half to formalize after getting working prototype
