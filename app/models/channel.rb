class Channel < ApplicationRecord
  has_many :channel_users
  has_many :messages
end
