require "test_helper"

class ChannelsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @channel = channels(:channel_1)
    @user = users(:michael)
    @non_member = users(:user_1)
  end

  test "should get index" do
    get channel_path
    assert_response :success
  end

  test "should get show when is member" do
    log_in_as(@user)
    get channel_path(@channel)
    assert_response :success
  end

  test 'should redirect show when is not member' do
    log_in_as(@non_member)
    get channel_path(@channel)
    assert_redirected_to channels_url
  end

end
