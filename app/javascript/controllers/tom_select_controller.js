import { Controller } from "@hotwired/stimulus";
import * as TomSelectModule from "tom-select";
export default class extends Controller {
  connect() {
    console.log(12);

    new TomSelect(this.element, {
      sortField: 'text',
      create: false,
      onItemAdd: function(value, item) {
        this.setTextboxValue('');
      }
    });
  }
}
