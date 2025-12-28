import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="sandbox"
export default class extends Controller {
  static targets = ["name", "template", "box"];

  connect() {
    console.log("helloコントローラが接続されました");
  }

  greet() {
    alert(`こんにちは、${this.nameTarget.value} さん`);
  }

  templateComfirm() {
    console.log(this.templateTarget)
    let flag = this.templateTarget.content.cloneNode(true)
    // console.log(this.templateTarget.content.cloneNode(true))
    this.element.append(flag);
  }
}

// console.log(document.getElementById('testH1'))