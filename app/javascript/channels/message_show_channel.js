import consumer from "channels/consumer"


const dmChannel = consumer.subscriptions.create(
  {channel: "MessageShowChannel", channel_id: window.location.pathname.match(/\/channels\/(\d+)/)?.[1] },
  {
    handlers: {
      1: 'handleConnected',
      2: 'handleJoined',
      3: 'handleLeaved',
      4: 'handleMessage',
      400: 'handleError'
    },
    currentUserId: null,
    lastReadMessageIds: null,
    activeUsersCount: 0,

    disconnected() {
      window.location.href = "/channels"
    },

    received(data) {
      if (!(data.event in this.handlers)) {
        data = {event: 400, params: '不明なエラー: データの受け取りに失敗'};
      }
      this[this.handlers[data.event]](data.params);
    },

    sending(message) {
      this.perform('receive', { message: message });
    },

    handleConnected(data) {
      this.currentUserId = data.current_user_id;
      delete data.last_read_message_ids[this.currentUserId];
      this.lastReadMessageIds = data.last_read_message_ids;
      for (const key of Object.keys(this.lastReadMessageIds)){
        if (this.lastReadMessageIds[key] == 0) { this.activeUsersCount += 1 }
      }

      const lastReadMessageIdsArray = Object.values(this.lastReadMessageIds).sort((a, b) => a - b);
      document.querySelectorAll('.read-count').forEach((readCountElement) => {
        let low = 0, high = lastReadMessageIdsArray.length;
        while (low < high) {
          const mid = Math.floor((low + high) / 2);
          if (lastReadMessageIdsArray[mid] < readCountElement.dataset.messageId) {
            low = mid + 1;
          } else {
            high = mid;
          }
        }
        low += activeUsersCount
        if (low > 0) { readCountElement.textContent = `既読 ${low}` }
      });
    },

    handleJoined(data) {
      console.log(data)
      if (data.user_id != this.currentUserId) {
        const tmpLRMI = this.lastReadMessageIds[data.user_id]
        this.lastReadMessageIds[data.user_id] = 0;
        
        // 既読数計算処理
        // document.querySelectorAll('.read-count')のdataset.messageIdが、tmpLRMIより低いデータのtextContentを見て、既読の文字な無ければ既読、あれば既読 \dの\dを+1する
      }
    },

    handleLeaved(data) {
      this.lastReadMessageIds[data.user_id] = data.last_read_message_id;
    },

    handleMessage(data) {
      const messagesElement = document.getElementById('messages');
      messagesElement.innerHTML += data.message_element;

      if (messagesElement.lastElementChild.classList.contains('self')) {
        messagesElement.lastElementChild.querySelector('.read-count').textContent = `既読 ${this.activeUsersCount}`;
      }

      messagesElement.scrollTop = messagesElement.scrollHeight;
    },

    handleError(data) {
      alert(Array.isArray(data) ? data.join("\n") : data);
    }
  }
);

function sendMessage(obj, dmChannel) {
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
    sendMessage(messageInput, dmChannel);
  });

  messageInput.addEventListener("keydown", function(e) {
    if (e.ctrlKey && e.key === "Enter") {
      sendMessage(messageInput, dmChannel);
    }
  });
});