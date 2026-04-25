require "test_helper"

class ConversationsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @conversation = conversations(:conversation_1)
    @user = users(:michael)
    @non_member = users(:user_1)
    log_in_as(@user)
  end

  test "should get index" do
    get conversations_path
    assert_response :success
  end

  test "should get show when is member" do
    log_in_as(@user)
    get conversation_path(@conversation)
    assert_response :success
  end

  test 'should redirect show when is not member' do
    log_in_as(@non_member)
    get conversation_path(@conversation)
    assert_redirected_to conversations_url
  end

end
