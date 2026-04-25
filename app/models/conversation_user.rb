class ChannelUser < ApplicationRecord
  # belongs_to :channel
  belongs_to :channel
  belongs_to :user

  validates :user_id, uniqueness: { scope: :channel_id, message: "このユーザーはすでにこのチャンネルに存在しています" }
end
