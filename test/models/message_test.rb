require "test_helper"

class MessageTest < ActiveSupport::TestCase

  def setup
    @user = users(:michael)
    @message = @user.messages.build(channel_id: channels(:channel_1).id, content: "Lorem ipsum")
  end

  test 'should be valid' do
    assert @message.valid?
  end

  test 'should require a channel_id' do
    @message.channel_id = nil
    assert_not @message.valid?
  end

  test 'should require a user_id' do
    @message.user_id = nil
    assert_not @message.valid?
  end

  test 'should require a content' do
    @message.content = ''
    assert_not @message.valid?
  end

  test 'content should be at most 1024 characters' do
    @message.content = 'a' * 1025
    assert_not @message.valid?
  end
end

