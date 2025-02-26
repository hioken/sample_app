import consumer from "channels/consumer"
const notificationContainer = document.getElementById("notification-container");
const notificationTemplate = document.getElementById("notification-template");

function notification (data) {
  const notificationElement = notificationTemplate.content.cloneNode(true).firstElementChild;
  console.log(data.message);
  console.log(data.channel_id);
  console.log(notificationElement);

  notificationElement.querySelector(".notification-sender").textContent = `user: ${data.user_name}`;
  notificationElement.querySelector(".notification-message").textContent = data.message;
  notificationElement.querySelector(".notification-link").href = `channels/${data.channel_id}`;
  notificationContainer.appendChild(notificationElement);
}

consumer.subscriptions.create("NotificationChannel", {
  received(data) {
    notification(data);
  }
});

notificationContainer.addEventListener("click", (event) => {
  if (event.target.matches(".notification-close")) { event.target.closest(".notification").remove() }
});


const testButton = document.getElementById('test-button');
let testIdx = 0;
testButton.addEventListener('click', () => {
  const notification = notificationTemplate.content.cloneNode(true).firstElementChild;
  notification.querySelector(".notification-sender").textContent = 'アーサー' + testIdx;
  notification.querySelector(".notification-message").textContent = 'テストメッセージ' + testIdx;
  notification.querySelector(".notification-link").href = '/users';
  console.log(notification)
  notificationContainer.appendChild(notification);
  testIdx++;

})