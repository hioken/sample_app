require 'test_helper'

class ChannelsIndex < ActionDispatch::IntegrationTest
  def setup
    @channel = channels(:channel_1)
    @user = users(:michael)
    @member = users(:archer)
    @non_member = users(:user_1)

    log_in_as(@user)
    get channels_path
  end

  test 'should have channel links' do
    first_page_of_channels = @user.active_channels.includes(:latest_message) #fix_point_3 表示チャンネル制限
    first_page_of_channels.each do |channel|
      assert_select 'a[href=?]', channel_path(channel)
      assert_select 'div.channel-message', text: channel.latest_message.content
      assert_select 'div.channel-timestamp', text: I18n.l(channel.last_message_at, format: :short)
    end
  end

  test 'should not create a channel when no users are selected' do
    unique_id = 'undefind_id'
    post add_user_path, params: { unique_id: unique_id }, headers: { 'Accept' => 'text/vnd.turbo-stream.html' }
    assert_select 'p', text: /ユーザーが見つかりません/

    user_ids = css_select('input[name="user_ids[]"]').map { |element| element['value'] }
    assert_no_difference 'Channel.count', "チャンネルが作成されてはいけません" do
      post channels_path, params: { user_ids: user_ids }
    end
  end

  test 'should be able to create a channel' do
    unique_id = @non_member.unique_id
    post add_user_path, params: { unique_id: unique_id }, headers: { 'Accept' => 'text/vnd.turbo-stream.html' }
    assert_select 'p', text: @non_member.name
    assert_select 'input[type="hidden"][value=?]', @non_member.id

    user_ids = css_select('input[name="user_ids[]"]').map { |element| element['value'] }
    assert_difference 'Channel.count', 1, "チャンネルが1つ作成されるべきです" do
      post channels_path, params: { user_ids: user_ids }
    end
  end
end
