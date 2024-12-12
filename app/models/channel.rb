class Channel < ApplicationRecord
  has_many :channel_users
  has_many :users -> { includes(:user) }, class_name: 'channel_users'
  has_many :messages
  has_many :messages_with_users -> { includes(:user) }, class_name: 'Messages'

  validates :last_message_at, presence: true

  def self.make_channel(user_ids)
    if user_ids.present? && channel = Channel.create(last_message_at: Time.current)
      channel_id = channel.id
      channel_user_records = user_ids.map do |id|
        {
          channel_id: channel_id, user_id: id,
          created_at: Time.current, updated_at: Time.current
        }
      end
      ChannelUser.insert_all(channel_user_records)
      channel
    else
      # エラー処理
      return nil
    end
  end
end
