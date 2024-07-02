import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="menu-btn"
export default class extends Controller {
  static targets = ["navbarMenuBtn"];

  toggle() {
    this.navbarMenuBtnTarget.classList.toggle("show");
  }
}
