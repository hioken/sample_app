class Message < ApplicationRecord
  belongs_to :user_id
  belongs_to :channel_id
end
