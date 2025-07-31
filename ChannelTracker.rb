# This simple bot responds to every "Ping!" message with a "Pong!"
require 'dotenv/load' # Load environment variables from .env file
require 'discordrb'

bot = Discordrb::Bot.new(name: ENV['DISCORD_BOT_NAME'],
  token: ENV['DISCORD_BOT_TOKEN'],
  client_id: ENV['DISCORD_CLIENT_ID'])

# Store tracking info: { user_id => { channel_id: ..., tracking: true } }
tracking_config = {}

# Event: when a user sends a message
bot.message do |event|
  next unless event.content == '!track'

  puts event.author
  puts "Channel: #{event.channel.name}"
  puts "You are in #{event.author.voice_channel}"
  member = event.user
  voice_state = member.voice_state

  # Make sure the user is in a voice channel
  if voice_state.channel
    tracking_config[member.id] = {
      channel_id: voice_state.channel.id,
      channel_name: voice_state.channel.name,
      username: member.display_name
    }
    event.respond "Now tracking voice activity in #{voice_state.channel.name} for #{member.display_name}."
  else
    event.respond "You must be in a voice channel to use this command."
  end
end

# Event: track voice state updates
bot.voice_state_update do |event|
  next unless tracking_config.any?

  user_id = event.user.id
  before = event.before
  after = event.after
  timestamp = Time.now.strftime("%Y-%m-%d %H:%M:%S")

  tracking_config.each do |tracked_user_id, config|
    tracked_channel_id = config[:channel_id]
    joined_message = "#{timestamp} -- #{event.user.username} joined #{after.channel.name}"
    left_message = "#{timestamp} -- #{event.user.username} left #{before.channel.name}"


    # Only track the specific channel
    if before.channel&.id == tracked_channel_id || after.channel&.id == tracked_channel_id

      # Joining w/no previous channel
      if before.channel.nil? && after.channel
        puts joined_message
        bot.send_message(event.server.default_channel.id, joined_message)
      # Leaving w/no current channel
      elsif before.channel && after.channel.nil?
        puts left_message
        bot.send_message(event.server.default_channel.id, left_message)
      # Leaving by switching channels
      elsif before.channel != after.channel && before.channel&.id == tracked_channel_id
        puts left_message
        bot.send_message(event.server.default_channel.id, left_message)
      # Joining by switching channels
      elsif before.channel != after.channel && after.channel&.id == tracked_channel_id
        puts joined_message
        bot.send_message(event.server.default_channel.id, joined_message)
      end
    end
  end
end

bot.run
