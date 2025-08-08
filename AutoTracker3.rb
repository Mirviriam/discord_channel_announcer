# This simple bot responds to every "Ping!" message with a "Pong!"
require 'dotenv/load' # Load environment variables from .env file
require 'discordrb'
require_relative 'tracking_channel'
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
tracking_config = {}
channel_track_stopped = {}
channel_tracker = TrackingManager.new

bot = Discordrb::Bot.new(
  name: ENV['DISCORD_BOT_NAME'],
  token: ENV['DISCORD_BOT_TOKEN'],
  client_id: ENV['DISCORD_CLIENT_ID']
)

def notifier(msg, event)
  puts msg
  if event && respond_to?(:respond, true)
    event.respond(msg)
  else
    puts "(Could not respond: event unavailable)"
  end
end

# Bot ready and invite to server necessary?
bot.ready do |event|
  puts 'Bot is ready!'
  puts "Bot Name: #{bot.name}"

  bot.servers.each do |server|
    puts "Server: #{server[1].name} (ID: #{server[0]})"
    # Here we check if the bot is already on the server with the ID MyServerID
    if server.any? { |b| b == server_id }
      puts "Bot is already on server!"
      bot.server(server_id).channels.each do |channel|
        puts "Channel: #{channel.name} (ID: #{channel.id}) -- #{channel.text? ? "Text Channel" : "Voice Channel"}"
        # puts channel.inspect
      end
    else
      puts "Bot is not on server: #{server[1].name}"
      puts "Click this invite URL to add it:  #{bot.invite_url}"
    end
  end
end

# Bot test receiving messages - !
# bot.message(content: Bot_Prefix) do |event|
#   unless event.message.content.length < 100
#     event.respond "Input too long! Keep it under 100 characters."
#     next
#   end
#   author = event.author
#   voice_channel = bot.server(server_id).member(author.id).voice_channel
#   puts "Found channel: #{voice_channel.name} (ID: #{voice_channel.id})"

#   voice_channel.send('Hello, this is a message!')

# Test:   starting in channel, not in channel

# !Start-Tracking command
bot.message(content: START_CMD) do |event|
  notifier('Command received Fleet Commander - Standby...', event)
  author = event.author

  # Must be in a channel to start tracking
  voice_channel = bot.server(server_id).member(author.id).voice_channel
  if voice_channel.nil?
    notifier("Host needs to be in a voice channel to track it.", event)
    next
  end

  # Adding tracking for channel, object handles is it already tracked
  channel_tracker.start_tracking_channel(voice_channel, server_id, author)
  # Checking result
  puts channel_tracker.active_channel?(voice_channel)

  # rather than calling from old data, we are using the object now as source of truth
  session = channel_tracker.session_for_channel(voice_channel)

  # TODO:  Add discord profile versus server profile handler for FC Name
  event.respond "Certainly Fleet Commander - Starting tracking of fleet members!"
  puts session.inspect
  puts "Voice Channel: #{session.id} - #{session.name}"

  session.channel.send("Fleet Commander has started tracking fleet members!")
  session.channel.send("Please rejoin voice channel to be tracked.")
end

# Test:  Stopping in channel, not in channel + if tracking started not in channel (cause nothing there to end tracking)

# !Stop-Tracking command
bot.message(content: STOP_CMD) do |event|
  event.respond 'Command received Fleet Commander - Standby...'
  author = event.author

  session = channel_tracker.session_for_hoster(author.id)
  channel_tracker.stop_tracking_channel(author.id)

  event.respond 'Certainly Fleet Commander - Stopping tracking of fleet members!'
  session.channel.send("Fleet Commander has stopped tracking fleet members!")
end

bot.voice_state_update do |event|
  # We get: user, old_channel, channel, server_id from event
  # pp event.inspect

  before = event.old_channel
  after = event.channel
  user = event.user

  # Only track the specific channel
  next unless channel_tracker.involved_in_tracked?(before: before, after: after)
  tracked_channel = channel_tracker.session_for_channel(after) || channel_tracker.session_for_channel(before)
  # puts tracked_channel.inspect

  # We need output to console the event is for an channel being actively tracked
  # puts "- before channel: #{before.name} (ID: #{before.id})" if before
  # puts "- after channel: #{after.name} (ID: #{after.id})" if after
  # puts "- user: #{user.username} (ID: #{user.id})"

  timestamp = Time.now

  # Joining voice channel.channel from nowhere doesn't annouce yet
  # annoucing not working
  if before.nil? && after
    joined_message = "#{timestamp} -- #{user.username} joined #{after.name}"
    puts joined_message
    tracked_channel.channel.send(joined_message)
  elsif before && after.nil?
    left_message = "#{timestamp} -- #{user.username} left #{before.name}"
    puts left_message
    tracked_channel.channel.send(left_message)
  elsif before != after && before&.id == tracked_channel.id
    left_message = "#{timestamp} -- #{user.username} left #{before.name}"
    puts left_message
    tracked_channel.channel.send(left_message)
  elsif before != after && after&.id == tracked_channel.id
    joined_message = "#{timestamp} -- #{user.username} joined #{after.name}"
    puts joined_message
    tracked_channel.channel.send(joined_message)
  end
end


bot.run

# this took an hour and half to formalize after getting working prototype
