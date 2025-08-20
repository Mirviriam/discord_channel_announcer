class AttendanceTracker
  def initialize
    # { user_id => { joined_at: Time, total_seconds: Integer } }
    @attendance = Hash.new { |h, k| h[k] = { joined_at: nil, total_seconds: 0 } }
  end

  def user_joined(user_id)
    @attendance[user_id][:joined_at] ||= Time.now
  end

  def user_left(user_id)
    joined_at = @attendance[user_id][:joined_at]
    if joined_at
      @attendance[user_id][:total_seconds] += (Time.now - joined_at).to_i
      @attendance[user_id][:joined_at] = nil
    end
  end

  def total_time(user_id)
    @attendance[user_id][:total_seconds]
  end

  def all_times
    @attendance.transform_values { |v| v[:total_seconds] }
  end
end
