class NotificationChannel < ApplicationCable::Channel
  def subscribed
    stream_from "notification_#{connection.current_user.id}"
    transmit({message: "接続"})
  end
end
