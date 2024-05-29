import { Controller } from "@hotwired/stimulus";
import flatpickr from "flatpickr";

export default class extends Controller {
  connect() {
    flatpickr(this.element, {
      mode: 'range',
      minDate: "today",
      onChange: this.dateChanged.bind(this),
      dateFormat: "D - Y-m-d",
      locale: {
        firstDayOfWeek: 1 // Monday
      },
      onReady: function(selectedDates, dateStr, instance) {
        const days = instance.days.childNodes;
        days.forEach(day => {
          const date = day.dateObj;
          if (date.getDay() === 0 || date.getDay() === 6) { // Sunday or Saturday
            day.classList.add('weekend');
          }
        });
      },
      onMonthChange: function(selectedDates, dateStr, instance) {
        const days = instance.days.childNodes;
        days.forEach(day => {
          const date = day.dateObj;
          if (date.getDay() === 0 || date.getDay() === 6) { // Sunday or Saturday
            day.classList.add('weekend');
          }
        });
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
