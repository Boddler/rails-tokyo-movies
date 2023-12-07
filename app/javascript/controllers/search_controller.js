import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="search"
export default class extends Controller {
static targets = ["input", "results"];

connect() {
  console.log("Class:", typeof("movies"));
  this.movies = JSON.parse(this.data.get("movies"));
  console.log("Class:", typeof(this.movies));
  console.log("Movies array:", this.movies);
  console.log("Connected to search controller.");
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
