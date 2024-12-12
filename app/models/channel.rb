class Channel < ApplicationRecord
  has_many :channel_users
  has_many :users -> { includes(:user) }, class_name: 'channel_users'
  has_many :messages
  has_many :messages_with_users -> { includes(:user) }, class_name: 'Messages'

  validates :last_message_at, presence: true

  def self.make_channel(user_ids)
    if channel_id = Channel.create(last_message_at: Time.current).id
      records = user_ids.map do |id|
        {
          channel_id: channel_id, user_id: id,
          created_at: Time.current, updated_at: Time.current
        }
      end
    else
      # エラー処理
    end
  end
end
