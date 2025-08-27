require 'dotenv/load' # Load environment variables from .env file
require 'discordrb'

# Manually trigger audit of people in the channel

class AttendanceLogger
    def initialize
        @attendance_log = []
    end

    def log_attendance(user_id, timestamp)
        @attendance_log << { user_id: user_id, timestamp: timestamp }
    end

    def display_log
        @attendance_log.each do |entry|
            puts "User ID: #{entry[:user_id]}, Timestamp: #{entry[:timestamp]}"
        end
    end
end

    # This statement creates a bot with the specified token and application ID.
    bot = Discordrb::Bot.new(token: ENV['DISCORD_BOT_TOKEN'], client_id: ENV['DISCORD_CLIENT_ID'])

    attendance_logger = AttendanceLogger.new

    bot.message(content: '!Record') do |event|
    attendance_logger.log_attendance(event.user.id, Time.now)
    event.respond 'Attendance recorded!'
    end

    bot.message(content: '!Show') do |event|
    attendance_logger.display_log
    end

    bot.run
