class Message < ApplicationRecord
  belongs_to :channel
  belongs_to :user

  validates :content, presence: true, length: { maximum: 1200 }
end
