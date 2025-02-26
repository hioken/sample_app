import consumer from "channels/consumer"

consumer.subscriptions.create("NotificationChannel", {
  received(data) {
    // 通知処理
  }
});


const testButton = document.getElementById('test-button');
let testIdx = 0;

testButton.addEventListener('click', () => {
  const container = document.getElementById("notification-container");
  const template = document.getElementById("notification-template");
  console.log(container)
  console.log(template)
  

  const notification = template.content.cloneNode(true).firstElementChild;
  notification.querySelector(".notification-sender").textContent = 'アーサー' + testIdx;
  notification.querySelector(".notification-message").textContent = 'テストメッセージ' + testIdx;
  const closeButton = notification.querySelector(".notification-close");
  console.log(notification)
  container.appendChild(notification);
  testIdx++;

  closeButton.addEventListener('click', () => notification.remove() ); // ココがtype error
  
})



