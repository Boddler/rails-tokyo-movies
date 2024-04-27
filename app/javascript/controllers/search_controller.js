import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="search"
export default class extends Controller {
static targets = ["input", "cinema"];

  connect() {
    console.log("Hello");
  }

  cinema(event) {
    const checkboxes = this.element.querySelectorAll('input[type="checkbox"]');
    const checkedCinemas = Array.from(checkboxes)
      .filter(checkbox => checkbox.checked)
      .map(checkbox => checkbox.getAttribute("data-cinema"));
    const searchQuery = document.getElementById('search-box').value;

    console.log(checkedCinemas);
    console.log(searchQuery);

    $.ajax({
      url: 'movies/index',
      method: 'GET',
      data: { filters: checkedCinemas, search_query: searchQuery },
      success: function(response) {
        console.log(response);
        // Update the page with the new results
        // For example, update a div with id "results" with the new content
        // $('#results').html(response);
      }
    });

}}
