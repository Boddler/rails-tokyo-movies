import { Controller } from "@hotwired/stimulus";
import flatpickr from "flatpickr";

export default class extends Controller {
  connect() {
    flatpickr(this.element, {
      mode: 'range',
      minDate: "today",
      onChange: this.dateChanged.bind(this),
      locale: {
        firstDayOfWeek: 1
      }
    });
  }

  dateChanged(selectedDates, dateStr, instance) {
    const event = new CustomEvent('flatpickr:change', {
      detail: { dateStr },
      bubbles: true
    });
    this.element.dispatchEvent(event);
  }
}
