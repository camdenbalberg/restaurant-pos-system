<template>
  <div class="cashier-popup" v-if="menu_item">
    <div class="popup-name">{{ menu_item.menu_name }}</div>

    <div class="popup-items">
      <button @click="$emit('cancel')" class="cancel-button">Cancel</button>
      <button @click="submitMeal" class="submit-button">Submit</button>
    </div>

    <div class="popup-selections">
      <ul>
        <li v-for="(config, category) in categoryConfigs" :key="category">
          <div>
            <span>
              {{ category }}: {{ selectedItems[category]?.length || 0 }}/{{ config.max }}
            </span>
            <CashierSelection
              :category="category"
              :maxSelections="config.max"
              :selectedItems="selectedItems[category]"
              @selectItem="selectItem(category, $event)"
            />
          </div>
        </li>
      </ul>
    </div>
  </div>
  <div v-else>
    <p>Loading...</p>
  </div>
</template>


<script>
import CashierSelection from './CashierSelection.vue';

// @vuese
// @group CashierView
export default {
  name: 'CashierPopup',
  components: {
    CashierSelection,
  },
  props: {
    // The meal item this popup is building
    menu_item: {
      type: Object,
      required: true,
    },
    // The menu item categories that will be displayed
    cat: {
      type: Array,
      required: true,
      validator(value) {
        return value.every(item => typeof item === 'string');
      },
    },
    // The max selections of each category you can select for this popup
    maxSelections: {
      type: Object,
      required: true,
      // Validate maxSelections to ensure it matches categories in `cat`
      validator(value) {
        return Object.keys(value).every(key => typeof value[key] === 'number');
      },
    },
  },
  emits: ['cancel', 'submitMeal'],

  // @vuese
  // Initial fields.
  data() {
    return {
      categoryConfigs: {}, // Dynamically populated configurations
      selectedItems: {}, // Track selected items for each category
    };
  },
  created() {
    this.initializePopup();
  },
  methods: {
    // @vuese
    // Dynamically configure categories and initialize selectedItems
    initializePopup() {
      this.categoryConfigs = this.cat.reduce((acc, category) => {
        acc[category] = { max: this.maxSelections[category] || 0 };
        return acc;
      }, {});

      for (const category in this.categoryConfigs) {
        this.selectedItems[category] = [];
      }
    },

    // @vuese
    // Select a menu item from a category
    // @arg the menu category
    // @arg the selected item
    selectItem(category, item) {
      const maxSelections = this.categoryConfigs[category].max;
      const selected = this.selectedItems[category];

      if (selected.length < maxSelections /*&& !selected.includes(item)*/) {
        selected.push(item);
      } else if (selected.includes(item)) {
        // Deselect the item if it's already selected
        this.selectedItems[category] = selected.filter(i => i !== item);
      } else {
        alert(`You can only select up to ${maxSelections} items for ${category}.`);
      }
    },

    submitMeal() {
      const allCategoriesSelected = Object.keys(this.categoryConfigs).every(
        category => this.selectedItems[category].length === this.categoryConfigs[category].max
      );

      if (allCategoriesSelected) {
        const completeMeal = {
          menuItem: this.menu_item,
          selections: this.selectedItems,
        };
        console.log('Submitting meal:', completeMeal);

        // Once finished, sends the completed meal to CashierView
        // @arg the completed meal
        this.$emit('submitMeal', completeMeal);
      } else {
        alert('Please complete all selections before submitting.');
      }
    },
  },
};
</script>

<style scoped>
.cashier-popup {
  position: fixed;
  top: calc(50% + 70px);
  left: 50%;
  height: calc(90% - 70px);
  width: 90%;
  transform: translate(-50%, calc(-50% - 35px));
  padding: 1.5em;

  background-color: white;
  border: 2px solid #888;
  border-radius: 0.25em;
  box-shadow: 1em black;

  overflow-y: scroll;
}

.popup-name {
  text-align: center;
  font-size: 133%;
  font-weight: 700;
  width: 100%;
}

.popup-items {
  width: 18%;
  float: right;
}

.cancel-button,
.submit-button {
  margin: 0.5em;
  padding: 0.5em 0.75em;
  color: #242528;
  background-color: #C3C7D0;
}
</style>
