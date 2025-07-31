# This simple bot responds to every "Ping!" message with a "Pong!"
require 'dotenv/load' # Load environment variables from .env file
require 'discordrb'
require_relative 'tracking_channel'

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
    else
      puts "Bot is not on server: #{server[1].name}"
      puts "Click this invite URL to add it:  #{bot.invite_url}"
    end
  end
end

# Bot test receiving messages - !
bot.message(content: Bot_Prefix) do |event|
  event.respond START_REPLY
end

# !Start-Tracking command
bot.message(content: START_CMD) do |event|
  author = event.author
  puts "Message Author: #{author.name}"
  voice_channel = bot.server(server_id).member(author.id).voice_channel

  # TODO:  Add discord profile versus server profile handler for FC Name
  event.respond "Certainly Fleet Commander - Starting tracking of fleet members!"

  tracking_channel = Tracking_Channel.new(
    voice_channel.id,
    voice_channel.name,
    server_id,
    author.id
  )

  puts "Voice Channel: #{tracking_channel.name}"
end

bot.message(content: STOP_CMD) do |event|
  event.respond 'Certainly Fleet Commander - Stopping tracking of fleet members!'
end


bot.run
