import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="tmdb-api-search"
export default class extends Controller {
  static targets = ["newMovie"]

  connect() {
    const apiKey = document.querySelector("meta[name='api-key']").getAttribute("content");
    console.log(apiKey);
    console.log("Connected!");
  }

  search() {
    console.log("Connected at the search bit too!");
    this.newMovieTarget.innerText
}

}
