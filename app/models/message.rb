class Message < ApplicationRecord
  belongs_to :channel
  belongs_to :user

  validates :content, presence: true, length: { maximum: 1024 }

  after_create :channel_update

  def channel_update
    channel.update(last_message_at: created_at)
  end
end
