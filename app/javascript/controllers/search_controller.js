import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="search"
export default class extends Controller {
static targets = ["input", "results"];

  search(event) {
  event.preventDefault();
  console.log("Search submitted")
  console.log(this.inputTarget.value)
  // debugger
}
}
