import { Controller } from "@hotwired/stimulus"

let timerId;

export default class extends Controller {
  static targets = ["input", "suggest"];

  connect() {
    console.log("-- connected addMemberController --");
  }

  onInput(event) {
    const input =  event.target;
    console.log("-- onInput --")
    console.log(input)
    clearTimeout(timerId);
    if (input.value !== '' && input.value !== '@') {
      timerId = setTimeout(() => {
        this.getSuggest(input.value);
      }, 498);
    } else {
      this.suggestTarget.replaceChildren();
    }
  }

  clickSuggest(event) {
    console.log("-- clickSuggest --")
    this.inputTarget.value = event.currentTarget.dataset.uid
  }

  async getSuggest(word) {
    try {
      console.log('-- suggest request --');
      const res = await fetch(`/suggest/${word}`, {method: 'GET'});
      // const data = await res.json();
      // console.log(data);
      // this.showSuggest(data);
      const html = await res.text();
      Turbo.renderStreamMessage(html);
    } catch(err) {
      console.error('サジェストエラー', err);
      return null;
    }
  }
}

// サジェストリクエストと受取処理
// 受け取る時に、既にhiddenがあるならアラートして削除



