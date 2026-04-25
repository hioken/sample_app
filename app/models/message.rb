class Message < ApplicationRecord
  belongs_to :conversation
  belongs_to :user

  validates :content, presence: true, length: { maximum: 1024 }

  after_create :conversation_update

  def conversation_update
    conversation.update(last_message_at: created_at)
  end
end
