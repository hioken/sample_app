import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["item"];

  connect() {
    console.log("connected conversationIndexController");
  }

  sortNewConversation(event) {
    console.log("-- sortNewConversation --")
    const { channel, message } = event.detail
    const boxId = `channel-${channel}`
    const messageBox = this.itemTargets.find((el) => el.id === boxId)
    if (!messageBox) {
      console.error("通知来たのにチャンネル一覧に対象がナッシング")
      return null
    }
    messageBox.querySelector('.unread-mark').classList.toggle('unread', true);
    messageBox.querySelector('.channel-message').textContent = message;
    console.log(messageBox);
    this.element.prepend(messageBox);
  }
}