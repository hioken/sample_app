class Message < ApplicationRecord
  belongs_to :channel
  belongs_to :user
  after_create :channel_update

  validates :content, presence: true, length: { maximum: 1200 }

  def channel_update
    Channel.find(channel_id).update(last_message_at: created_at)
  end
end
