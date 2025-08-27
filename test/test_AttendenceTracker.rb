require "minitest/autorun"
require_relative "../AttendenceTracker"

class TestAttendanceTracker < Minitest::Test
  def setup
    @tracker = AttendanceTracker.new
    @user_id = 123
  end

  def test_initial_total_time_is_zero
    assert_equal 0, @tracker.total_time(@user_id)
  end

  def test_user_joined_sets_joined_at
    @tracker.user_joined(@user_id)
    refute_nil @tracker.instance_variable_get(:@attendance)[@user_id][:joined_at]
  end

  def test_user_joined_double_join_does_not_overwrite
    @tracker.user_joined(@user_id)
    first_joined_at = @tracker.instance_variable_get(:@attendance)[@user_id][:joined_at]
    sleep 1
    @tracker.user_joined(@user_id)
    second_joined_at = @tracker.instance_variable_get(:@attendance)[@user_id][:joined_at]
    assert_equal first_joined_at, second_joined_at
  end

  def test_multiple_sessions_accumulate_time
    @tracker.user_joined(@user_id)
    sleep 1
    @tracker.user_left(@user_id)
    first_total = @tracker.total_time(@user_id)
    @tracker.user_joined(@user_id)
    sleep 1
    @tracker.user_left(@user_id)
    second_total = @tracker.total_time(@user_id)
    assert_operator second_total, :>, first_total
  end

  def test_all_times_returns_hash_with_multiple_users
    user2 = 456
    @tracker.user_joined(@user_id)
    sleep 1
    @tracker.user_left(@user_id)
    @tracker.user_joined(user2)
    sleep 2
    @tracker.user_left(user2)
    times = @tracker.all_times
    assert_kind_of Hash, times
    assert times.key?(@user_id)
    assert times.key?(user2)
    assert_operator times[@user_id], :>=, 1
    assert_operator times[user2], :>=, 2
  end
end
