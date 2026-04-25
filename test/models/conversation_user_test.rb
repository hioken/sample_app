require "test_helper"

class ConversationUserTest < ActiveSupport::TestCase

  def setup
    @conversation_user = ConversationUser.new(conversation_id: conversations(:conversation_1).id,
                                    user_id: users(:juna).id)
  end

  test 'should be valid' do
    assert @conversation_user.valid?
  end

  test 'should require a conversation_id' do
    @conversation_user.conversation_id = nil
    assert_not @conversation_user.valid?
  end

  test 'should require a user_id' do
    @conversation_user.user_id = nil
    assert_not @conversation_user.valid?
  end
end
