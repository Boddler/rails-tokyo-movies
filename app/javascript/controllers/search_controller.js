import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="search"
export default class extends Controller {
static targets = ["input", "results"];

connect() {
  this.movies = JSON.parse(this.data.get("movies"));
  console.log(this.movies)
}


  search(event) {
  event.preventDefault();
  console.log("Search submitted")
  console.log(this.inputTarget.value)

  const searchTerm = this.inputTarget.value.toLowerCase();
  console.log(searchTerm)

  const filteredMovies = this.movies.filter(movie =>
    movie.name.toLowerCase().includes(searchTerm)
    );
    console.log(filteredMovies)

  // debugger
}
}
