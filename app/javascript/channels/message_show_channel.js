import consumer from "channels/consumer"
import { channelId } from "./channel_id";

const messageInput = document.getElementById("message-input");
const sendButton = document.getElementById("send-button");

const scrollMessage = function () {
  const element = document.getElementById('messages')
  return () => {
    if (element.scrollHeight - element.scrollTop <= element.clientHeight + 1000){
      element.scrollTo({ top: element.scrollHeight, behavior: "smooth" })
    }
  }
}()

const dmChannel = consumer.subscriptions.create(
  {channel: "MessageShowChannel", channel_id: channelId },
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
    isGroupChat: false,

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
      const draft = sessionStorage.getItem(`${channelId}:draft`);
      if (draft) {
        messageInput.value = draft
      }

      this.currentUserId = data.current_user_id;
      // delete data.last_read_message_ids[this.currentUserId]; 現在サーバー側でやる事にしている
      this.lastReadMessageIds = data.last_read_message_ids;
      for (const key of Object.keys(this.lastReadMessageIds)){
        if (this.lastReadMessageIds[key] == 0) { this.activeUsersCount += 1 }
      }

      const lastReadMessageIdsArray = Object.values(this.lastReadMessageIds).sort((a, b) => a - b);

      if (lastReadMessageIdsArray.length > 1) { this.isGroupChat = true }
      document.querySelectorAll('.read-count').forEach((readCountElement) => {
        const readCount = binarySearch(parseInt(readCountElement.dataset.messageId), lastReadMessageIdsArray) + this.activeUsersCount;
        if (readCount > 0) {
          readCountElement.textContent = this.isGroupChat ? `既読 ${readCount}` : '既読';
        }
        readCountElement.dataset.readCount = readCount;
      });

      console.log('##### connected #####')
      console.log(sessionStorage.getItem(`${channelId}:draft`))
      console.log(this.lastReadMessageIds);
      console.log(`currentUserId ${this.currentUserId}`);
      console.log(`activeUsersCount ${this.activeUsersCount}`);
    },

    handleJoined(data) {
      if (data.user_id != this.currentUserId) {
        const tmpLRMI = this.lastReadMessageIds[data.user_id]
        this.lastReadMessageIds[data.user_id] = 0; // fix_point_4 いる？
        this.activeUsersCount += 1;
        
        document.querySelectorAll('.read-count').forEach((readCountElement) => {
          if (parseInt(readCountElement.dataset.messageId) > tmpLRMI) {
            readCountElement.dataset.readCount = parseInt(readCountElement.dataset.readCount) + 1;
            readCountElement.textContent = this.isGroupChat ? `既読 ${readCountElement.dataset.readCount}` : '既読';
          }
        })
      }
      console.log('##### joined #####')
      console.log(this.lastReadMessageIds);
      console.log(`currentUserId ${this.currentUserId}`);
      console.log(`activeUsersCount ${this.activeUsersCount}`);
    },

    handleLeaved(data) {
      this.lastReadMessageIds[data.user_id] = data.last_read_message_id; // fix_point_4 ここもいる？
      this.activeUsersCount -= 1;
      console.log('##### leaved #####')
      console.log(this.lastReadMessageIds);
      console.log(`currentUserId ${this.currentUserId}`);
      console.log(`activeUsersCount ${this.activeUsersCount}`);
    },

    handleMessage(data) {
      const messagesElement = document.getElementById('messages');
      messagesElement.innerHTML += data.message_element;

      const lastReadCountElement = messagesElement.lastElementChild.querySelector('.read-count');
      if (lastReadCountElement && this.activeUsersCount > 0) {
        lastReadCountElement.dataset.readCount = this.activeUsersCount;
        lastReadCountElement.textContent = this.isGroupChat ? `既読 ${this.activeUsersCount}` : '既読';
      }
      scrollMessage();

      console.log('##### message #####');
      console.log(messagesElement.lastElementChild.querySelector('.read-count'));
      console.log(this.lastReadMessageIds);
      console.log(`currentUserId ${this.currentUserId}`);
      console.log(`activeUsersCount ${this.activeUsersCount}`);
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
    sessionStorage.removeItem(`${channelId}:draft`);
  }
}

function binarySearch(target, searchArray) {
  let low = 0, high = searchArray.length;
  while (low < high) {
    const mid = Math.floor((low + high) / 2);
    if (searchArray[mid] < target) {
      low = mid + 1;
    } else {
      high = mid;
    }
  }
  return searchArray.length - low;
}

sendButton.addEventListener("click", () => {
  sendMessage(messageInput, dmChannel);
});

messageInput.addEventListener("keydown", function(e) {
  if (e.ctrlKey && e.key === "Enter") {
    sendMessage(messageInput, dmChannel);
  }
});

// window.addEventListener("beforeunload",() => {
//   sessionStorage.setItem(`${channelId}:draft`, messageInput.value);
// });
document.addEventListener("visibilitychange", () => {
  if (document.hidden) sessionStorage.setItem(`${channelId}:draft`, messageInput.value);
});
window.addEventListener("pagehide", () => {
  sessionStorage.setItem(`${channelId}:draft`, messageInput.value);
});

  
  // document.getElementById('test-button').addEventListener("click",() => {
  //     const element = document.getElementById('messages')
  //     console.log(`height: ${element.scrollHeight}`)
  //     console.log(`top: ${element.scrollTop}`)
  //     console.log(`client: ${element.clientHeight}`)
  // });