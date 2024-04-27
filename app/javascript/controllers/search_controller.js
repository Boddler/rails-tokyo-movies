import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="search"
export default class extends Controller {
static targets = ["input", "cinema"];

connect() {
  // this.movies = JSON.parse(this.data.get("movies"));
  console.log("Hello");
  // console.log("Connected to search controller.");
}

cinema(event) {
  console.log(this);
  console.log(event.target.getAttribute("data-cinema"));
}

}
