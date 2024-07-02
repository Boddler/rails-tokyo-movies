import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="menu-btn"
export default class extends Controller {
  static targets = ["navbarMenuBoxes", "navbarMenuBtn"];

  toggle() {
    this.navbarMenuBoxesTarget.classList.toggle("show");
    this.navbarMenuBtnTarget.classList.toggle("bottom");
  }
}
