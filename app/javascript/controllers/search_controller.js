import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
static targets = ["input", "cinema", "form"];

connect() {
  console.log("search controller connected");

}

  cinema(event) {
    const checkbox = event.target;
    const checkboxes = this.element.querySelectorAll('input[type="checkbox"]');
    const checkedCinemas = Array.from(checkboxes)
      .filter(checkbox => checkbox.checked)
      .map(checkbox => checkbox.getAttribute("data-cinema"));
      const checkedLanguages = Array.from(checkboxes)
      .filter(checkbox => checkbox.checked)
      .map(checkbox => checkbox.getAttribute("data-language"));
    const searchQuery = document.getElementById('search-box').value;

    $.ajax({
      url: 'movies',
      method: 'GET',
      data: { cinemas: checkedCinemas, languages: checkedLanguages, query: searchQuery },
      success: function(response) {
        const movieCardsHtml = $(response).find('#search-results').html();
        const searchResultsDiv = document.getElementById('search-results');
        searchResultsDiv.innerHTML = movieCardsHtml;
      }
    });

}}
