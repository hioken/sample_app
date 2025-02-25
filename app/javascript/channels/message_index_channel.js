import consumer from "channels/consumer"

consumer.subscriptions.create("NotificationChannel", {
  received(data) {
    // DM画面の最新メッセージを更新
    // getElementIdBy(channel_<%= cu.channel_id %>_message)
  }
});
