import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["input", "cinema", "form"];

  connect() {
    this.element.addEventListener('flatpickr:change', this.cinema.bind(this));
  }

  cinema() {
    const dates = document.getElementById("dates").value;
    const checkboxes = this.element.querySelectorAll('input[type="checkbox"]');
    const checkedCinemas = Array.from(checkboxes)
      .filter(checkbox => checkbox.checked)
      .map(checkbox => checkbox.getAttribute("data-cinema"));
    const checkedLanguages = Array.from(checkboxes)
      .filter(checkbox => checkbox.checked)
      .map(checkbox => checkbox.getAttribute("data-language"));

    $.ajax({
      url: 'showings',
      method: 'GET',
      data: { cinemas: checkedCinemas, languages: checkedLanguages, dates: dates },
      success: function(response) {
        const movieCardsHtml = $(response).find('#search-results').html();
        const searchResultsDiv = document.getElementById('search-results');
        searchResultsDiv.innerHTML = movieCardsHtml;
      }
    });
  }
}
