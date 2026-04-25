class Conversation < ApplicationRecord
  has_many :conversation_users, dependent: :destroy
  has_many :users, through: :conversation_users
  has_many :messages, dependent: :destroy
  has_one :latest_message, -> { order(created_at: :desc) }, class_name: 'Message'

  validates :last_message_at, presence: true

  def self.make_conversation(user_ids)
    return invalid_conversation('対象のユーザーが選択されていません') if user_ids.length < 2

    find_existing_conversation(user_ids) || create_new_conversation(user_ids, Time.current)
  end

  def is_member?(user_id)
    conversation_users.find_by(user_id: user_id)
  end

  private

  def self.invalid_conversation(message)
    conversation = Conversation.new
    conversation.errors.add(:users, message)
    conversation
  end

  def self.create_new_conversation(user_ids, time_now)
    conversation = Conversation.new(last_message_at: time_now)
    begin
      ActiveRecord::Base.transaction do
        raise ActiveRecord::Rollback unless conversation.save

        conversation_user_records = user_ids.map do |id|
          {
            conversation_id: conversation.id, user_id: id,
            created_at: time_now, updated_at: time_now
          }
        end
        ConversationUser.insert_all(conversation_user_records)
      end
    rescue => e
      conversation.errors.add(:conversation_users, '不明なエラー(中間レコードエラー)')
      logger.error "チャンネル作成エラー: #{e.message}"
      logger.error e.backtrace.join("\n")
      p e
    end
    conversation
  end

  def self.find_existing_conversation(user_ids)
    return nil if user_ids.empty?
    conversation = ConversationUser.group(:conversation_id)
      .having('COUNT(DISTINCT CASE WHEN user_id IN (?) THEN user_id END) = ?', user_ids, user_ids.length)
      .having('COUNT(DISTINCT user_id) = ?', user_ids.length).first
      &.conversation
    conversation.conversation_users.where(user_id: user_ids[0]).update(is_left: false) if conversation
    conversation
  end
end
