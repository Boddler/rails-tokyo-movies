import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="tmdb-api-search"
export default class extends Controller {
  static targets = ["newMovie", "input"]

  connect() {
    const apiKey = document.querySelector("meta[name='api-key']").getAttribute("content");
    console.log(apiKey);
    console.log("Connected!");
  }

  search() {
    const apiKey = document.querySelector("meta[name='api-key']").getAttribute("content");
    fetch(`https://api.themoviedb.org/3/movie/${this.inputTarget.value}?api_key=${apiKey}`)
    .then(response => response.json())
    .then((data) => {
      console.log(data);
      this.addMovie(data);
    })
}

addMovie(data) {
  const searchResultsElement = this.newMovieTarget;
  console.log("OK?");
  console.log(data.title);
  searchResultsElement.innerHTML = `
  <div class="movie-card">
    <div class="movie-poster">
      <img src="https://image.tmdb.org/t/p/w185/${data.backdrop_path}" alt="Movie Poster" style="height: 171px;">
    </div>
  </a>
  <div class="movie-card-text">
    <div class="movie-card-heading">
      <div>
        <h4>${data.title}</h4>
      </div>
      <div class="language-tag">
        ${data.spoken_languages[0].english_name}
      </div>
    </div>
    <div>
      <p>Release Date: ${data.release_date}</p>
    </div>
  </div>
</div>
`;
// debugger
}

}
