# frozen_string_literal: true

require 'dotenv/load' # Load environment variables from .env file
require 'discordrb'

bot = Discordrb::Bot.new(token: ENV['DISCORD_BOT_TOKEN'], client_id: ENV['DISCORD_CLIENT_ID'])  
MyServerID = '163453933400883201'

# On ready, check we have connection to server
bot.ready do |event|
    puts "Bot is ready! Logged in as #{bot.profile.username} (ID: #{bot.profile.id})"
    bot.servers.each do |server|
        puts "Server: #{server[1].name} (ID: #{server[0]})"
        # Here we check if the bot is already on the server with the ID MyServerID
        if server.any? { |b| b == MyServerID }
        puts "Bot is logged on server: #{server[1].name}!"
        else
            puts "Bot is not logged on server: #{server[1].name} ..."
            puts 'Click on URL below to invite bot to your server.'
            puts "This bot's invite URL is #{bot.invite_url}"
        end
    end
end

    # Begin voice channel list lookup feature
    VoiceChannelList = []
    # Begin looking for voice channels
    server[1].voice_channels.each do |channel|
      puts "Voice Channel: #{channel.name} (ID: #{channel.id})"
      VoiceChannelList << channel      
      members = channel.users.map(&:nickname)
      channel.users.each do |user|
        puts "User: #{user.username} (ID: #{user.id})"
        puts user.inspect
      end
      puts "Members in voice channel #{channel.name}: #{members.join(', ')}"

# This method call adds an event handler that will be called on any message that exactly contains the string "Ping!".
# The code inside it will be executed, and a "Pong!" response will be sent to the channel.
bot.message(content: 'Ping!') do |event|
  event.respond 'Pong!'
end

bot.message(content: 'Record!') do |event|
    event.respond 'Certainly Fleet Commander!'
    #VoiceChat = event.author.voice_channel
    #puts event.author.inspect
    pp event
end

# This method call has to be put at the end of your script, it is what makes the bot actually connect to Discord. If you
# leave it out (try it!) the script will simply stop and the bot will not appear online.
bot.run
#test

