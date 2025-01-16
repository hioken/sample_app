
require 'test_helper'

class ChannelShowTest < ActionDispatch::IntegrationTest
  def setup
    @channel = channels(:channel_1)
    @user = users(:michael)
    @member = users(:archer)

    log_in_as(@user)
    get channel_path(@channel)
  end

  test 'should have messages' do
    messages = @channel.messages
    messages.each do |message|
      assert_select 'p', text: "発言者: #{message.user.name_with_id}"
      assert_select 'span', text: message.content
      assert_select 'div.message-timestamp', text: I18n.l(message.updated_at, format: :short)
    end
  end

  test 'should have cookie' do
    assert_not cookies[:sending_user_id].blank?
  end

  test 'should leave' do
    patch leave_path(@channel)
    assert_redirected_to channels_url
    assert cookies[:sending_user_id].blank?
    assert_equal 1, @user.channels.count - @user.active_channels.count
  end
end
