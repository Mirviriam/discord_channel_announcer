require "minitest/autorun"
require_relative "../tracking_channel"

class TestTrackingChannel < Minitest::Test
  def setup
    @channel_struct = Struct.new(:id, :name).new(123, "General")
    @server_id = 456
    @hoster_id = 789
    @tracking_channel = Tracking_Channel.from_discord(@channel_struct, @server_id, @hoster_id)
  end

  def test_initialization
    assert_equal 123, @tracking_channel.id
    assert_equal "General", @tracking_channel.name
    assert_equal @channel_struct, @tracking_channel.channel
    assert_equal 456, @tracking_channel.server_id
    assert_equal 789, @tracking_channel.hoster_id
    refute_nil @tracking_channel.host_started
    assert_nil @tracking_channel.host_stopped
  end

  def test_equality
    other_channel = Tracking_Channel.new(123, "General", @channel_struct, @server_id, @hoster_id)
    assert_equal @tracking_channel, other_channel
    different_channel = Tracking_Channel.new(999, "Other", @channel_struct, @server_id, @hoster_id)
    refute_equal @tracking_channel, different_channel
  end

  def test_set_end_time
    @tracking_channel.set_end_time
    refute_nil @tracking_channel.host_stopped
  end

  def test_active
    assert @tracking_channel.active?
    @tracking_channel.set_end_time
    refute @tracking_channel.active?
  end

  def test_to_s
    str = @tracking_channel.to_s
    assert_match /Tracking_Channel/, str
    assert_match /id=123/, str
    assert_match /name='General'/, str
    assert_match /server=456/, str
    assert_match /hoster=789/, str
  end

  def test_from_discord
    tc = Tracking_Channel.from_discord(@channel_struct, @server_id, @hoster_id)
    assert_instance_of Tracking_Channel, tc
    assert_equal @channel_struct.id, tc.id
    assert_equal @channel_struct.name, tc.name
    assert_equal @server_id, tc.server_id
    assert_equal @hoster_id, tc.hoster_id
  end
end
