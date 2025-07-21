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

# This statement creates a bot with the specified token and application ID. After this line, you can add events to the
# created bot, and eventually run it.
#bot = Discordrb::Bot.new(token: ENV['DISCORD_BOT_TOKEN'], client_id: ENV['DISCORD_CLIENT_ID'])  
bot = Discordrb::Bot.new(token: ENV['DISCORD_BOT_TOKEN'], client_id: ENV['DISCORD_CLIENT_ID'], intents: %i[servers server_messages server_voice_states])  

MyServerID = '163453933400883201'

$tracked_voice_channels = {}

bot.ready do |event|
  puts 'Bot is ready!'
  puts bot.name
 # bot.FleetMemberList = [];
  
  bot.servers.each do |server|
    puts "Server: #{server[1].name} (ID: #{server[0]})"
    # Here we check if the bot is already on the server with the ID MyServerID
    if server.any? { |b| b == MyServerID }
      puts "Bot is already on server!"
    else
      puts "Bot is not on server: #{server[1].name}"
    end
  end
end


# Here we output the invite URL to the console so the bot account can be invited to the channel. This only has to be
# done once, afterwards, you can remove this part if you want
puts "This bot's invite URL is #{bot.invite_url}"
puts 'Click on it to invite it to your server.'


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

# This method call has to be put at the end of your script, it is what makes the bot actually connect to Discord. If you
# leave it out (try it!) the script will simply stop and the bot will not appear online.
begin
  bot.run
rescue => e
  puts "WebSocket closed with error: #{e.message}"
end
#test

