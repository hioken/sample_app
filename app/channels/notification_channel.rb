class NotificationChannel < ApplicationCable::Channel
  def subscribed
    stream_from "notification_#{connection.current_user.id}"
  end
end
