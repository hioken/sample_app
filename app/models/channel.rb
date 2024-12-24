class Channel < ApplicationRecord
  has_many :channel_users, dependent: :destroy
  has_many :users, through: :channel_users
  has_many :messages, dependent: :destroy
  has_one :latest_message, -> { order(created_at: :desc) }, class_name: 'Message'

  validates :last_message_at, presence: true

  def self.make_channel(user_ids)
    return invalid_channel('対象のユーザーが選択されていません') if user_ids.length < 2

    find_existing_channel(user_ids) || create_new_channel(user_ids, Time.current)
  end

  def is_member?(user_id)
    channel_users.find_by(user_id: user_id)
  end

  private

  def self.invalid_channel(message)
    channel = Channel.new
    channel.errors.add(:users, message)
    channel
  end

  def self.create_new_channel(user_ids, time_now)
    channel = Channel.new(last_message_at: time_now)
    return channel unless channel.save

    channel_user_records = user_ids.map do |id|
      {
        channel_id: channel.id, user_id: id,
        created_at: time_now, updated_at: time_now
      }
    end
    ChannelUser.insert_all(channel_user_records)
    channel
  end

  def self.find_existing_channel(user_ids)
    return nil if user_ids.empty?
    ChannelUser.group(:channel_id)
      .having('COUNT(DISTINCT CASE WHEN user_id IN (?) THEN user_id END) = ?', user_ids, user_ids.length)
      .having('COUNT(DISTINCT user_id) = ?', user_ids.length).first
      &.channel
  end

end
