require 'test_helper'

class ConversationsIndex < ActionDispatch::IntegrationTest
  def setup
    @conversation = conversations(:conversation_1)
    @user = users(:michael)
    @member = users(:archer)
    @non_member = users(:user_1)

    log_in_as(@user)
    get conversations_path
  end

  test 'should have conversation links' do
    first_page_of_conversations = @user.active_conversations.includes(:latest_message) #fix_point_3 表示チャンネル制限
    first_page_of_conversations.each do |conversation|
      assert_select 'a[href=?]', conversation_path(conversation)
      assert_select 'div.conversation-message', text: conversation.latest_message.content
      assert_select 'div.conversation-timestamp', text: I18n.l(conversation.last_message_at, format: :short)
    end
  end

  test 'should not create a conversation when no users are selected' do
    unique_id = 'undefind_id'
    post add_user_path, params: { unique_id: unique_id }, headers: { 'Accept' => 'text/vnd.turbo-stream.html' }
    assert_select 'p', text: /ユーザーが見つかりません/

    user_ids = css_select('input[name="user_ids[]"]').map { |element| element['value'] }
    assert_no_difference 'Conversation.count', "チャンネルが作成されてはいけません" do
      post conversations_path, params: { user_ids: user_ids }
    end
  end

  test 'should be able to create a conversation' do
    unique_id = @non_member.unique_id
    post add_user_path, params: { unique_id: unique_id }, headers: { 'Accept' => 'text/vnd.turbo-stream.html' }
    assert_select 'p', text: @non_member.name_with_id
    assert_select 'input[type="hidden"][value=?]', @non_member.id

    user_ids = css_select('input[name="user_ids[]"]').map { |element| element['value'] }
    assert_difference 'Conversation.count', 1, "チャンネルが1つ作成されるべきです" do
      post conversations_path, params: { user_ids: user_ids }
    end
  end
end
