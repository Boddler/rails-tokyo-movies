import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="search"
export default class extends Controller {
static targets = ["input", "results"];

connect() {
  this.movies = JSON.parse(this.data.get("movies"));
  console.log("Movies array:", this.movies);
  console.log("Connected to search controller.");
}


search(event) {
  event.preventDefault();
  console.log("Search submitted");
  console.log(this.inputTarget.value);

  if (Array.isArray(this.movies)) {
    const searchTerm = this.inputTarget.value.toLowerCase();
    console.log("Lowercased search term:", searchTerm);

    const filteredMovies = this.movies.filter(movie =>
      movie.name.toLowerCase().includes(searchTerm)
    );
    console.log("Filtered movies:", filteredMovies);

    // Update the HTML to display the search results
    this.updateSearchResults(filteredMovies);
  } else {
    console.warn("this.movies is not an array:", this.movies);
  }
}

updateSearchResults(results) {
  // Assuming you have an element with the id "search-results"
  const searchResultsElement = document.getElementById("search-results");

  // Clear existing content
  searchResultsElement.innerHTML = "";

  // Append each result to the element
  results.forEach(movie => {
    const movieCard = document.createElement("div");
    movieCard.classList.add("movie-card"); // Add the "movie-card" class

    // Assuming you have properties like "name", "director", etc.
    movieCard.innerHTML = `
      <div class="movie-card">
        <a href="/movies/${movie.id}">
          <div class="movie-poster">
            <img src="${movie.poster}" alt="Movie Poster">
          </div>
        </a>
        <div class="movie-card-text">
          <div class="movie-card-heading">
            <div>
              <h4>${movie.name}</h4>
            </div>
            <div class="language-tag">
              ${movie.language}
            </div>
          </div>
          <div>
            <p>${movie.year}</p>
            <p>Director: ${movie.director}</p>
            <p>Cast: ${movie.cast.join(', ')}</p>
          </div>
        </div>
      </div>
    `;

    searchResultsElement.appendChild(movieCard);
  });
}

}
