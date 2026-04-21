import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["item"];

  connect() {
    console.log('-- connect notification --')
    // this.loadNotificationsFromSession();
  }

  // loadNotificationsFromSession() {
  //   const notifications = JSON.parse(sessionStorage.getItem("notifications")) || [];
  //   notifications.forEach(sessionItem => { notification(sessionItem) });
  // }

  // DMルーム一覧画面へのイベント
  itemTargetConnected(elem) {
    const ev = new CustomEvent("app:notification", {
      detail: {
        channel: elem.dataset.channel,
        message: elem.dataset.message
      }
    });

    window.dispatchEvent(ev);
  }

  close(event) {
    console.log('-- close --')
    event.stopPropagation();
    event.preventDefault();
    event.target.closest(".notification").remove();
  }
}

// コメント部分, 通知引継ぎ機能は一旦放置

// const sessionStorageKey = 'notifications';
// let notificationClicked = true;

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