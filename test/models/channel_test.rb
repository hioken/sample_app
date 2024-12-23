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
    members = [:michael, :archer, :lana].map { |user| users(user) }
    channel_users_count = ChannelUser.count
    user_ids = members.map { |user| user.id }
    channel = Channel.make_channel(user_ids)
    assert channel.valid?
    assert ChannelUser.count == channel_users_count + members.length
    assert members.all? { |member| ChannelUser.find_by(channel_id: channel.id, user_id: member.id) }
  end

  test 'should be invalid with only one member' do
    assert_not Channel.make_channel([users(:michael).id]).valid?
  end

  test 'should return existing channel' do
    existing_channel = channels(:channel_1)
    user_ids = existing_channel.users.map(&:id)
    channel = Channel.make_channel(user_ids)
    assert_equal existing_channel.id, channel.id
  end
end