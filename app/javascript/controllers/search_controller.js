import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="search"
export default class extends Controller {
static targets = ["input", "cinema", "form"];

  connect() {
    console.log("Hello");
  }

  cinema(event) {
    // event.preventDefault()
    const checkbox = event.target;
    // checkbox.checked = !checkbox.checked;
    const checkboxes = this.element.querySelectorAll('input[type="checkbox"]');
    const checkedCinemas = Array.from(checkboxes)
      .filter(checkbox => checkbox.checked)
      .map(checkbox => checkbox.getAttribute("data-cinema"));
    const searchQuery = document.getElementById('search-box').value;
    console.log(checkedCinemas);
    console.log(searchQuery);

    $.ajax({
      url: 'movies',
      method: 'GET',
      data: { filters: checkedCinemas, search_query: searchQuery },
      success: function(response) {
        const movieCardsHtml = $(response).find('#search-results').html();

        // Update the search results div with the movie cards HTML
        const searchResultsDiv = document.getElementById('search-results');
        searchResultsDiv.innerHTML = movieCardsHtml;

      }
    });

}}
