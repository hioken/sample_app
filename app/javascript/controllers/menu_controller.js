import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    console.log("-- connected menuController --");
  }

  toggleMenu(event) {
    console.log("-- toggleMenu --")
    event.preventDefault();
    const elem = event.target
    const menu = elem.parentElement.querySelector("ul");
    console.log(menu)
    menu.classList.toggle(elem.dataset.toggleClass)
  }
}
