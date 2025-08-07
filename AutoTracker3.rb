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
post_tracking = {}
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

#   event.respond START_REPLY
# end

# !Start-Tracking command
bot.message(content: START_CMD) do |event|
  author = event.author
  puts "Message Author: #{author.name}"

  # Need to remember what we just added to check it
  voice_channel = bot.server(server_id).member(author.id).voice_channel
  # Adding tracking for channel, object handles is it already tracked
  channel_tracker.start_tracking(voice_channel, server_id, author)
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

# !Stop-Tracking command
bot.message(content: STOP_CMD) do |event|
  author = event.author
  event.respond 'Certainly Fleet Commander - Stopping tracking of fleet members!'
  tracking_config[author.id].set_end_time
  tracking_config[author.id].channel.send("Fleet Commander has stopped tracking fleet members!")
  post_tracking[author.id] = tracking_config[author.id]
  puts "Tracking stopped for: #{tracking_config[author.id].name} (ID: #{tracking_config[author.id].id}) @ #{tracking_config[author.id].host_stopped}"
  tracking_config.delete(author.id)
end

bot.voice_state_update do |event|
  # Skip if no tracking config is present
  next unless tracking_config.any?

    before = event.old_channel
    after = event.channel

  # We need determine the event is for an channel being actively tracked
  puts "before channel: #{event.before.name} (ID: #{event.before.id})"
  puts "after channel: #{event.after.name} (ID: #{event.after.id})"

  next unless check_tracked_channel?(tracking_config, before: before, after: after)


    timestamp = Time.now.strftime("%Y-%m-%d %H:%M:%S")

    # Only track the specific channel
    if before.id == tracking_config[author.id].id || after.id == tracking_config[author.id].id
      if before.nil? && after
        joined_message = "#{timestamp} -- #{author.username} joined #{after.name}"
        puts joined_message
        tracking_config[author.id].channel.send(joined_message)
      elsif before && after.nil?
        left_message = "#{timestamp} -- #{author.username} left #{before.name}"
        puts left_message
        tracking_config[author.id].channel.send(left_message)
      elsif before != after && before&.id == tracking_config[author.id].id
        left_message = "#{timestamp} -- #{author.username} left #{before.name}"
        puts left_message
        tracking_config[author.id].channel.send(left_message)
      elsif before != after && after&.id == tracking_config[author.id].id
        joined_message = "#{timestamp} -- #{author.username} joined #{after.name}"
        puts joined_message
        tracking_config[author.id].channel.send(joined_message)
      end
    end
  end


bot.run

# this took an hour and half to formalize after getting working prototype
