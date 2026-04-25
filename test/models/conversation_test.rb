require "test_helper"

class ConversationTest < ActiveSupport::TestCase
  def setup
    @conversation = Conversation.new(last_message_at: Time.zone.now)
  end

  test 'should be valid' do
    assert @conversation.valid?
  end

  test 'should require a last_message_at' do
    @conversation.last_message_at = nil
    assert_not @conversation.valid?
  end

  test 'should create conversation with conversation_users' do
    members = [:michael, :archer, :lana].map { |user| users(user) }
    conversation_users_count = ConversationUser.count
    user_ids = members.map { |user| user.id }
    conversation = Conversation.make_conversation(user_ids)
    assert conversation.valid?
    assert ConversationUser.count == conversation_users_count + members.length
    assert members.all? { |member| ConversationUser.find_by(conversation_id: conversation.id, user_id: member.id) }
  end

  test 'should be invalid with only one member' do
    assert_not Conversation.make_conversation([users(:michael).id]).valid?
  end

  test 'should return existing conversation' do
    existing_conversation = conversations(:conversation_1)
    user_ids = existing_conversation.users.map(&:id)
    conversation = Conversation.make_conversation(user_ids)
    assert_equal existing_conversation.id, conversation.id
  end

  test 'should is_member? return true' do
    conversation = conversations(:conversation_1)  
    user = conversation.users.first
    assert conversation.is_member?(user.id)
  end

  test 'should is_member? return false' do
    conversation = conversations(:conversation_1)  
    user = conversation.users.last
    assert_not conversation.is_member?(user.id + 1)
  end
end