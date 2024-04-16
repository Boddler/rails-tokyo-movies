import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="tmdb-api-search"
export default class extends Controller {
  static targets = ["newMovie", "input", "name"]

  connect() {
    const apiKey = document.querySelector("meta[name='api-key']").getAttribute("content");
    console.log("Connected!");
  }

  search() {
    console.log("Connected to the ID");
    const apiKey = document.querySelector("meta[name='api-key']").getAttribute("content");
    fetch(`https://api.themoviedb.org/3/movie/${this.inputTarget.value}?api_key=${apiKey}`)
    .then(response => response.json())
    .then((data) => {
      this.addMovie(data);
    })
  }
  name() {
    console.log("Connected to the name!");
    console.log(this.nameTarget.value);
    const apiKey = document.querySelector("meta[name='api-key']").getAttribute("content");
    fetch(`https://api.themoviedb.org/3/search/movie?api_key=${apiKey}&query=${this.nameTarget.value}`)
    .then(response => response.json())
    .then((data) => {
      console.log(data);
      this.addMovies(data);
    })
}


addMovie(data) {
  const searchResultsElement = this.newMovieTarget;
  searchResultsElement.innerHTML = `
  <div class="movie-card">
    <div class="movie-poster">
      <img src="https://image.tmdb.org/t/p/w500/${data.poster_path}" alt="Movie Poster" style="height: 171px; object-fit: cover;">
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
}

addMovies(data) {
  const searchResultsElement = this.newMovieTarget;
  data.results.forEach(element => {
    searchResultsElement.insertAdjacentHTML("afterbegin", `
      <div class="movie-card">
        <div class="movie-poster">
          <img src="https://image.tmdb.org/t/p/w500/${element.poster_path}" alt="Movie Poster" style="height: 171px; object-fit: cover;">
        </div>
        <div class="movie-card-text">
          <div class="movie-card-heading">
            <div>
              <h4>${element.title}</h4>
            </div>
            <div class="language-tag">
              ${element.original_language}
            </div>
          </div>
          <div>
            <p>Release Date: ${element.release_date}</p>
          </div>
        </div>
      </div>
    `);
  });
}




}
