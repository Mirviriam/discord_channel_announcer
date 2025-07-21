require 'dotenv/load' # Load environment variables from .env file
require 'discordrb'


# Create a new bot instance
bot = Discordrb::Bot.new(token: ENV['DISCORD_BOT_TOKEN'], intents: %i[servers server_messages server_voice_states]) # You'll need GUILD_VOICE_STATES intent to receive voice state updates

# Event handler for voice state updates
bot.voice_state_update do |event|
  # Check if a user has just connected to a voice channel
  if event.channel && event.old_channel.nil?
    # Get the user and the channel they joined
    user = event.user
    channel = event.channel

    # Perform actions when a user joins
    puts "#{user.name} connected to voice channel #{channel.name}!"
    # You can send a message to a specific text channel, for example:
    # event.server.text_channels.find { |c| c.name == "general" }.send_message("#{user.name} joined #{channel.name}!")
  end

  # Check if the user is leaving a voice channel
  if event.old_channel && !event.channel
    puts "User #{event.user.name} left voice channel #{event.old_channel.name}"
    # You can add further actions here, such as:
    # - Sending a message to a text channel.
    # - Logging the event.
    # - Unmuting the user if they were muted in the channel they left.
  end  
end

# Run the bot
bot.run