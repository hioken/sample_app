class ConversationUser < ApplicationRecord
  # belongs_to :conversation
  belongs_to :conversation
  belongs_to :user

  validates :user_id, uniqueness: { scope: :conversation_id, message: "このユーザーはすでにこのチャンネルに存在しています" }
end
