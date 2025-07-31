# This simple bot responds to every "Ping!" message with a "Pong!"
require 'dotenv/load' # Load environment variables from .env file
require 'discordrb'

tracked_channel = nil
bot = Discordrb::Bot.new(name: ENV['DISCORD_BOT_NAME'], token: ENV['DISCORD_BOT_TOKEN'], client_id: ENV['DISCORD_CLIENT_ID'])

bot.message(with_text: '!t') do |event|
  next unless event.content == '!track' || event.content == '!t'
  puts event.author
  puts event.author.inspect

  # Get the voice channel the user is in
  tracked_channel = bot.server(ENV['DISCORD_SERVER_TEST_ID']).member(event.author.id).voice_channel
  if tracked_channel.nil?
    event.respond("You are not in a voice channel.")
  else
    event.respond("You are in the voice channel: #{tracked_channel.name}")
    event.respond("Beginning Tracking in: #{tracked_channel.name}, please have every leave & rejoin the channel to track their activity.")
    # bot.voice_connect(tracked_channel)
    puts "Discord Channel:  #{tracked_channel.name}"
  end
end

bot.run
