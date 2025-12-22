import { Controller } from "@hotwired/stimulus"
import consumer from "channels/consumer"

// const notificationTemplate = document.getElementById("notification-template");
const notificationContainer = document.getElementById("notification-container");
// const sessionStorageKey = 'notifications';


// コメント部分, 通知引継ぎ機能は一旦放置

// let notificationClicked = true;

export default class extends Controller {
  static targets = ["template"];

  connect() {
    console.log('connect message_notification')
    // this.loadNotificationsFromSession();

    this.channel = consumer.subscriptions.create( "NotificationChannel", {
      received: (data) => {
        this.notification(data);
        const messageBox = document.getElementById(`channel-${data.channel_id}-message-box`)
        if (messageBox) {
          messageBox.querySelector('.unread-mark').classList.toggle('unread', true);
          messageBox.querySelector('.channel-message').textContent = data.message;
          console.log(messageBox);
          const parent = document.getElementById('channels-container');
          parent.insertBefore(messageBox.closest('a'), parent.firstChild);
        }
      }
    });
  }

  // loadNotificationsFromSession() {
  //   const notifications = JSON.parse(sessionStorage.getItem("notifications")) || [];
  //   notifications.forEach(sessionItem => { notification(sessionItem) });
  // }

  notification(data) {
    console.log(data)
    // const notificationElement = notificationTemplate.content.cloneNode(true).firstElementChild;
    const notificationElement = this.templateTarget.content.cloneNode(true).firstElementChild;
    notificationElement.dataset.user_name = data.user_name;
    notificationElement.dataset.message = data.message
    notificationElement.dataset.channelId = data.channel_id
    notificationElement.querySelector(".notification-sender").textContent = `user: ${data.user_name}`;
    notificationElement.querySelector(".notification-message").textContent = data.message;
    notificationElement.querySelector(".notification-link").href = `channels/${data.channel_id}`;

    notificationContainer.appendChild(notificationElement);
  }

  close(event) {
    console.log('close')
    event.stopPropagation();
    event.preventDefault();
    event.target.closest(".notification").remove();
  }
}

// document.addEventListener("click", (event) => {
  // if (event.target.closest(".notification-link")) {
    // notificationClicked = false;
    // sessionStorage.removeItem(sessionStorageKey);
  // }
// });


// function addNotificationToSession () {
//   sessionStorage.removeItem(sessionStorageKey);

//   const sessionItem = [];
//   for (const childElement of notificationContainer.children) {
//     sessionItem.push({
//       user_name: childElement.dataset.user_name,
//       message: childElement.dataset.message,
//       channel_id: childElement.dataset.channelId
//     });
//   }
//   sessionStorage.setItem(sessionStorageKey, JSON.stringify(sessionItem));
// }

// document.addEventListener("visibilitychange", () => {
//   if (notificationClicked && document.hidden) {
//     addNotificationToSession();
//   }
// });
// window.addEventListener("pagehide", () => {
//   if (notificationClicked) {
//     addNotificationToSession();
//   }
// });

// document.addEventListener("visibilitychange", () => {
//   if (document.hidden) { addNotificationToSession() };
// });
// window.addEventListener("pagehide", () => {
//   addNotificationToSession();
// });



// テスト用
// const testButton = document.getElementById('test-button');
// let testIdx = 0;
// testButton.addEventListener('click', () => {
//   notification({
//     user_name: 'アーサー' + testIdx,
//     message: 'テストメッセージ' + testIdx,
//     channel_id: 1
//   })
//   testIdx++;
//   sessionStorage.removeItem(sessionStorageKey)
// })