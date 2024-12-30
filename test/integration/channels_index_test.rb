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

  test 'should render the index page' do
    assert_template '/index'
  end

  test 'should have channel links' do
    first_page_of_channels = current_user.channels.includes(:latest_message)
    first_page_of_channels.each do |channel|
      assert_select 'a[href=?]', channel_path(channel)
      assert_select 'div.channel-message', text: channel.latest_message.content
      assert_select 'div.channel-timestamp', text: channel.last_message_at
    end
  end

  # fix_point
  # test 'should paginate users' do
  #   assert_select 'div.pagination'
  # end

  test 'should not create a channel when no users are selected' do
    email = 'undefind_email.com'
    post add_user_path, params: { emails: [email] }
    assert_select 'p', text: /ユーザーが見つかりません/

    email_values = css_select('input[name="emails[]"]').map { |element| element['value'] }
    assert_no_difference 'Channel.count', "チャンネルが作成されてはいけません" do
      post channels_path, params: { emails: email_values }
    end
  end

  test 'should be able to create a channel' do
    email = @non_member.email
    post add_user_path, params: { emails: [email] }
    assert_select 'p', text: @non_member.name
    assert_select 'p', text: @non_member.email
    assert_select 'input[type="hidden"][value=?]', @non_member.email

    email_values = css_select('input[name="emails[]"]').map { |element| element['value'] }
    assert_difference 'Channel.count', 1, "チャンネルが1つ作成されるべきです" do
      post channels_path, params: { emails: email_values }
    end
  end
end
