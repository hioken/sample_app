// 定義
import consumer from "channels/consumer"
const notificationContainer = document.getElementById("notification-container");
const notificationTemplate = document.getElementById("notification-template");
const sessionStorageKey = 'notifications';

function notification (data) {
  console.log(data)
  const notificationElement = notificationTemplate.content.cloneNode(true).firstElementChild;
  notificationElement.dataset.user_name = data.user_name;
  notificationElement.dataset.message = data.message
  notificationElement.dataset.channelId = data.channel_id
  notificationElement.querySelector(".notification-sender").textContent = `user: ${data.user_name}`;
  notificationElement.querySelector(".notification-message").textContent = data.message;
  notificationElement.querySelector(".notification-link").href = `channels/${data.channel_id}`;

  notificationContainer.appendChild(notificationElement);
}

function loadNotificationsFromSession () {
  const notifications = JSON.parse(sessionStorage.getItem("notifications")) || [];
  notifications.forEach(sessionItem => { notification(sessionItem) });
}

function addNotificationToSession () {
  sessionStorage.removeItem(sessionStorageKey);

  const sessionItem = [];
  for (const childElement of notificationContainer.children) {
    sessionItem.push({
      user_name: childElement.dataset.user_name,
      message: childElement.dataset.message,
      channel_id: childElement.dataset.channelId
    });
  }
  sessionStorage.setItem(sessionStorageKey, JSON.stringify(sessionItem));
}


// 実行
loadNotificationsFromSession();

consumer.subscriptions.create(
  "NotificationChannel",
  {
    received(data) {
      notification(data);
    }
  }
);

notificationContainer.addEventListener("click", (event) => {
  if (event.target.matches(".notification-close")) { event.target.closest(".notification").remove() }
});

let notificationClicked = true;
document.addEventListener("click", (event) => {
  if (event.target.closest(".notification-link")) {
    notificationClicked = false;
    sessionStorage.removeItem(sessionStorageKey);
  }
});
document.addEventListener("visibilitychange", () => {
  if (notificationClicked && document.hidden) {
    addNotificationToSession();
  }
});
window.addEventListener("pagehide", () => {
  if (notificationClicked) {
    addNotificationToSession();
  }
});


// document.addEventListener("visibilitychange", () => {
//   if (document.hidden) { addNotificationToSession() };
// });
// window.addEventListener("pagehide", () => {
//   addNotificationToSession();
// });


const testButton = document.getElementById('test-button');
let testIdx = 0;
testButton.addEventListener('click', () => {
  notification({
    user_name: 'アーサー' + testIdx,
    message: 'テストメッセージ' + testIdx,
    channel_id: 1
  })
  testIdx++;
  sessionStorage.removeItem(sessionStorageKey)
})