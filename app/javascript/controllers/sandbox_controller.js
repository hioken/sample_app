import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="sandbox"
export default class extends Controller {
  static targets = ["name"];

  connect() {
    console.log("helloコントローラが接続されました");
  }

  greet() {
    alert(`こんにちは、${this.nameTarget.value} さん`);
  }
}

// console.log(document.getElementById('testH1'))