import { Controller } from "@hotwired/stimulus"

let timerId;

export default class extends Controller {
  static targets = ["input"];

  connect() {
    console.log("-- connected addMemberController --");
  }

  onInput(event) {
    const input =  event.target;
    console.log("-- onInput --")
    console.log(input)
    clearTimeout(timerId);
    if (input.value !== '' && input.value !== '@') {
      timerId = setTimeout(() => this.getSuggest(input.value), 498);
    }
  }

  clickSuggest(event) {
    console.log("-- clickSuggest --")
    this.inputTarget.value = event.currentTarget.dataset.uid
  }

  async getSuggest(word) {
    try {
      console.log('-- suggest request --');
      console.log(`word!!!!!!: ${word}`)
      const res = await fetch(`/suggest/${word}`, {method: 'GET'});
      console.log(res);
      // const data = await res.json();
      // console.log(data);
      // this.showSuggest(data);
      const html = await res.text();
      console.log(html);
      Turbo.renderStreamMessage(html);
    } catch(err) {
      console.error('サジェストエラー', err);
      return null;
    }
  }
}

// サジェストリクエストと受取処理
// 受け取る時に、既にhiddenがあるならアラートして削除



