class ChannelUser < ApplicationRecord
  belongs_to :channel_id
  belongs_to :user_id
end
