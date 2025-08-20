require "minitest/autorun"
require_relative "../TrackingManager3"
require_relative "../tracking_channel"

class TestTrackingManager < Minitest::Test
def setup
  @channel_struct = Struct.new(:id, :name) do
    def send(msg); end
  end.new(123, "General")
  @server_id = 456
  @hoster_id = 789
  @tracking_channel = Tracking_Channel.from_discord(@channel_struct, @server_id, @hoster_id)
  @manager = TrackingManager.new
end

  def test_empty_check_raises_for_nil
    assert_raises(ArgumentError) { @manager.send(:empty_check, nil, "param") }
  end

  def test_empty_check_raises_for_blank
    assert_raises(ArgumentError) { @manager.send(:empty_check, "", "param") }
  end

  def test_start_tracking_channel_adds_session
    @manager.start_tracking_channel(@channel_struct, @server_id, @hoster_id)
    session = @manager.session_for_channel(@channel_struct)
    refute_nil session
    assert_equal @channel_struct.id, session.id
    assert_equal @hoster_id, session.hoster_id
  end

def test_start_tracking_channel_prevents_duplicate_channel
  # First call should add the session
  result1 = @manager.start_tracking_channel(@channel_struct, @server_id, @hoster_id)
  assert_instance_of Tracking_Channel, result1
  initial_count = @manager.count_active

  # Second call should return early (no new session, no output, returns nil)
  result2 = @manager.start_tracking_channel(@channel_struct, @server_id, @hoster_id)
  assert_nil result2
  assert_equal initial_count, @manager.count_active
end

  def test_stop_tracking_channel_removes_session
    @manager.start_tracking_channel(@channel_struct, @server_id, @hoster_id)
    @manager.stop_tracking_channel(@hoster_id)
    session = @manager.session_for_hoster(@hoster_id)
    assert_nil session
  end

  def test_session_for_channel_returns_nil_for_unknown
    assert_nil @manager.session_for_channel(@channel_struct)
  end

  def test_session_for_hoster_returns_nil_for_unknown
    assert_nil @manager.session_for_hoster(@hoster_id)
  end
end
