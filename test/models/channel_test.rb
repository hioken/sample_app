require "test_helper"

class ChannelTest < ActiveSupport::TestCase
  def setup
    @channel = Channel.new(last_message_at: Time.zone.now)
  end

  test 'should be valid' do
    assert @channel.valid?
  end

  test 'should require a last_message_at' do
    @channel.last_message_at = nil
    assert_not @channel.valid?
  end

  test 'should create channel with channel_users' do
    ids = [:michael, :archer, :lana].map { |user| users(user).id }
    assert Channel.new
    


  end
end