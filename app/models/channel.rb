class Channel < ApplicationRecord
  has_many :channel_users
  has_many :users, -> { includes(:user) }, class_name: 'channel_users'
  has_many :messages
  has_many :messages_with_users, -> { includes(:user) }, class_name: 'Messages'

  validates :last_message_at, presence: true

  def self.make_channel(user_ids)
    time_now = Time.current
    validate_user_combination(user_ids)
    if user_ids.present? && channel = Channel.create(last_message_at: time_now)
      channel_id = channel.id
      channel_user_records = user_ids.map do |id|
        {
          channel_id: channel_id, user_id: id,
          created_at: time_now, updated_at: time_now
        }
      end
      ChannelUser.insert_all(channel_user_records)
      channel
    else
      # エラー処理
      return nil
    end
  end

  private

  def validate_user_combination(user_ids)
    Channel.joins(:channel_users)
           .where(:user_id: user_ids)
           .group('channel_users.channel_id')
  end
end
