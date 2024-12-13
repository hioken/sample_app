require "test_helper"

class ChannelUserTest < ActiveSupport::TestCase

  def setup
    @channel_user = ChannelUser.new(channel_id: channels(:channel_1).id,
                                    user_id: users(:michael).id)
  end

  test 'should be valid' do
    assert @channel_user.valid?
  end

  test 'should require a channel_id' do
    @channel_user.channel_id = nil
    assert_not @channel_user.valid?
  end

  test 'should require a user_id' do
    @channel_user.user_id = nil
    assert_not @channel_user.valid?
  end
end
