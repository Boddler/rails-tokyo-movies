import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="search"
export default class extends Controller {
static targets = ["input", "cinema", "form"];

connect() {
  console.log("Hello from showing search");
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
      console.log(checkedCinemas);
      console.log(checkedLanguages);

    $.ajax({
      url: 'showings',
      method: 'GET',
      data: { cinemas: checkedCinemas, languages: checkedLanguages },
      success: function(response) {
        const movieCardsHtml = $(response).find('#search-results').html();
        const searchResultsDiv = document.getElementById('search-results');
        searchResultsDiv.innerHTML = movieCardsHtml;
      }
    });

}}
