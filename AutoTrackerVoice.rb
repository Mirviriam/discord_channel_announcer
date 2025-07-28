# frozen_string_literal: true

# This simple bot responds to every "Ping!" message with a "Pong!"
require 'dotenv/load' # Load environment variables from .env file
require 'discordrb'

# .freeze makes the string immutable, a good practice for constants
Bot_Prefix = '!'.freeze
START_VERB = "Start".freeze
STOP_VERB = "Stop".freeze
COMMAND_NAME = "Tracking".freeze
START_CMD = "#{Bot_Prefix}#{START_VERB}-#{COMMAND_NAME}".freeze
STOP_CMD = "#{Bot_Prefix}#{STOP_VERB}-#{COMMAND_NAME}".freeze
MyEventChannel = 'General'.freeze


# This statement creates a bot with the specified token and application ID.
# bot = Discordrb::Bot.new(token: ENV['DISCORD_BOT_TOKEN'], client_id: ENV['DISCORD_CLIENT_ID'])
# bot = Discordrb::Bot.new(name: "TestMe",token: ENV['DISCORD_BOT_TOKEN'], client_id: ENV['DISCORD_CLIENT_ID'])
bot = Discordrb::Bot.new(name: ENV['DISCORD_BOT_NAME'], token: ENV['DISCORD_BOT_TOKEN'], client_id: ENV['DISCORD_CLIENT_ID'])
bot = Discordrb::Bot.new(
  name: ENV['DISCORD_BOT_NAME'],
  token: ENV['DISCORD_BOT_TOKEN'],
  client_id: ENV['DISCORD_CLIENT_ID'],
    # intents: %i[servers server_messages server_voice_states]
  )

# bot.debug = true

# bot = Discordrb::Bot.new(token: ENV['DISCORD_BOT_TOKEN'], client_id: ENV['DISCORD_CLIENT_ID'], intents: %i[servers server_messages server_voice_states])

MyServerID = '163453933400883201'
$tracked_voice_channels = {}

bot.ready do |event|
  puts "Bot Name: #{bot.name}"
  # puts "Bot ID: #{bot.id}"
  puts 'Bot is ready!'
  # not working: puts bot.get_application_commands
  # bot.FleetMemberList = [];

  bot.servers.each do |server|
    puts "Server: #{server[1].name} (ID: #{server[0]})"
    # Here we check if the bot is already on the server with the ID MyServerID
    if server.any? { |b| b == MyServerID }
      puts "Bot is already on server!"
    else
      puts "Bot is not on server: #{server[1].name}"
      puts "Click this invite URL to add it:  #{bot.invite_url}"
    end
  end
end

# Listen for voice_state_update events
bot.voice_state_update do |event|
  # Get the current timestamp
  timestamp = Time.now.strftime("%Y-%m-%d %H:%M:%S")

  # Check if a user joined a voice channel
  if event.old_channel.nil? && !event.channel.nil?
    puts "#{timestamp} #{event.user.name} joined voice channel: #{event.channel.name}"
  # Check if a user left a voice channel
  elsif !event.old_channel.nil? && event.channel.nil?
    puts "#{timestamp} #{event.user.name} left voice channel: #{event.old_channel.name}"
  end
end

bot.message(content: '!Start') do |event|
    event.respond 'Where does one ever truly begin?'
end

# This method call adds an event handler that will be called on any message that exactly contains the string "Ping!".
# The code inside it will be executed, and a "Pong!" response will be sent to the channel.
bot.message(content: START_CMD) do |event|
    event.respond 'Certainly Fleet Commander - Starting tracking of fleet members!'
  # voice_state = event.user.voice_state(event.server)
  # puts voice_state
end

bot.message(content: STOP_CMD) do |event|
  event.respond 'Certainly Fleet Commander - Stopping tracking of fleet members!'
end

# bot.run
# Run all the things we just made for the bot & handle any errors when disconnecting
begin
  bot.run
rescue => e
  puts "WebSocket closed with error: #{e.message}"
end
# test
