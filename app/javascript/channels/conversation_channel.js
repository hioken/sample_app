import consumer from "channels/consumer"
import { conversationId } from "./conversation_id";

const messageInput = document.getElementById("message-input");
const sendButton = document.getElementById("send-button");
const draft = sessionStorage.getItem(`${conversationId}:draft`);
const messagesContainer = document.getElementById('messages');

const scrollMessage = function () {
  return () => {
    if (messagesContainer.scrollHeight - messagesContainer.scrollTop <= messagesContainer.clientHeight + 1000){
      messagesContainer.scrollTo({ top: messagesContainer.scrollHeight, behavior: "smooth" })
    }
  }
}()

function sendMessage(obj, conversationChannel) {
  let message = obj.value.trim();
  if (message.length > 0) {
    conversationChannel.sending(message);
    obj.value = "";
    sessionStorage.removeItem(`${conversationId}:draft`);
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

function read_id() {
  return messagesContainer.lastElementChild.dataset.messageId;
}

console.log('draft!!!: ' + draft);
console.log(sessionStorage.getItem(`${conversationId}:draft`))
if (draft) {
  messageInput.value = draft
}

const conversationChannel = consumer.subscriptions.create(
  {channel: "ConversationChannel", conversation_id: conversationId },
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
      this.perform('activate', {read_id: read_id()});

      console.log('##### connected #####')
      console.log(`read_id: ${read_id()}`)
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
      messagesContainer.innerHTML += data.message_element;

      const lastReadCountElement = messagesContainer.lastElementChild.querySelector('.read-count');
      if (lastReadCountElement && this.activeUsersCount > 0) {
        lastReadCountElement.dataset.readCount = this.activeUsersCount;
        lastReadCountElement.textContent = this.isGroupChat ? `既読 ${this.activeUsersCount}` : '既読';
      }
      scrollMessage();

      console.log('##### message #####');
      console.log(messagesContainer.lastElementChild.querySelector('.read-count'));
      console.log(this.lastReadMessageIds);
      console.log(`currentUserId ${this.currentUserId}`);
      console.log(`activeUsersCount ${this.activeUsersCount}`);
    },

    handleError(data) {
      alert(Array.isArray(data) ? data.join("\n") : data);
    }
  }
);


sendButton.addEventListener("click", () => {
  sendMessage(messageInput, conversationChannel);
});

messageInput.addEventListener("keydown", function(e) {
  if (e.ctrlKey && e.key === "Enter") {
    sendMessage(messageInput, conversationChannel);
  }
});

// window.addEventListener("beforeunload",() => {
//   sessionStorage.setItem(`${conversationId}:draft`, messageInput.value);
// });
document.addEventListener("visibilitychange", () => {
  // consumer.subscriptions.remove(conversationChannel);
  if (document.hidden) sessionStorage.setItem(`${conversationId}:draft`, messageInput.value);
});
window.addEventListener("pagehide", () => {
  // consumer.subscriptions.remove(conversationChannel);
  sessionStorage.setItem(`${conversationId}:draft`, messageInput.value);
});

document.getElementById('test-button').addEventListener("click",() => {
  // スクロールテスト 
  //     const element = document.getElementById('messages')
  //     console.log(`height: ${element.scrollHeight}`)
  //     console.log(`top: ${element.scrollTop}`)
  //     console.log(`client: ${element.clientHeight}`)

  // 接続遮断テスト
  consumer.subscriptions.remove(conversationChannel);
});
