import consumer from "channels/consumer"

const dmChannel = consumer.subscriptions.create(
  {channel: "MessageShowChannel", channel_id: URLSearchParams(window.location.search).get('id')},
  {
    // connected() {
    //   // 既読機能
    // },

    received(data) {
      const messagesElement = document.getElementById('messages');
      messagesElement.innerHTML += data.message_element;

      messagesElement.scrollTop = messagesElement.scrollHeight;
    }, 

    sending(message) {
      this.perform('receive', { message: message });
    }
  }
);

function send_message(obj, dmChannel) {
  let message = obj.value.trim();
  if (message.length > 0) {
    dmChannel.sending(message);
    obj.value = "";
  }
}

document.addEventListener("turbo:load", () => {
  const messageInput = document.getElementById("message-input");
  const sendButton = document.getElementById("send-button");

  sendButton.addEventListener("click", () => {
    send_message(messageInput, dmChannel)
  });

  messageInput.addEventListener("keydown", function(e) {
    if (e.ctrlKey && e.key === "Enter") {
      send_message(messageInput, dmChannel)
    }
  });
});