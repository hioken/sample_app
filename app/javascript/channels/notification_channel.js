// import consumer from "channels/consumer"

// consumer.subscriptions.create("NotificationChannel", {
//   received(data) {
//     // 通知処理
//   }
// });


const testButton = document.getElementById('test-button');

testButton.addEventListener('click', () => {
  const container = document.getElementById("notification-container");
  const template = document.getElementById("notification-template");
  

  const notification = template.content.cloneNode(true);
  container.appendChild(notification);
})

alert('a')