<template>
    <div class="popup">
      <p>{{ menu_item.menu_name }}</p>
      <ul>
        <!--loop through all categories passed into popup-->
        <li v-for="(item, index) in cat" :key="item">
          <MealItems :category="item" @selected="currentItems(index, $event)" />
        </li>
      </ul>
      <button @click="$emit('close')">Close</button>
      <button @click="addToKart(item)">Add To Order</button>
    </div>
</template>

<script>
import MealItems from './MealItems.vue'; // Adjust path if necessary

export default {
  name: 'MealPopup',
  components: {
    MealItems,
  },

  // @vuese
  /**
   * @data
   * @description
   * Initial fields for the component.
   * 
   * - 'selected_items' holds the selected items for meal.
   */
  data() {
    return {
      selected_items: [],
    };
  },

  // @vuese
  /**
   * @props
   * @description
   * Props for the component.
   * 
   * - 'menu_item' is the menu item object.
   * - 'cat' is the array of categories.
   */
  props: {
    menu_item: {
      type: Object,
      required: true,
    },
    cat:{
      type: Array,
      required: true,
      validator(value) {
        return value.every(item => typeof item === 'string');
      },
    },
  },

  // @vuese
  /**
   * @created
   * @description
   * Initializes the selected items array.
   */
  created() {
    this.initializeSelectedItems();
  },

  // @vuese
  /**
   * @methods
   * @description
   * Methods for the component.
   * 
   * - 'initializeSelectedItems' initializes the selected items array.
   * - 'addToKart' adds selected items to the cart.
   * - 'currentItems' puts respective entree or side in the selected_items array.
   */
  methods: {
    // @vuese
    /**
     * @method initializeSelectedItems
     * @description
     * Initializes the selected items array with number of entrees and sides.
     * 
     * @returns {void}
     */
    initializeSelectedItems() {
      this.selected_items = new Array(this.cat.length).fill(null);
      console.log(this.cat);
    },

    // @vuese
    /**
     * @method addToKart
     * @description
     * Adds selected items to the cart.
     * 
     * @returns {void}
     */
    addToKart() {
      const allItemsSelected = this.selected_items.every(item => item !== null);
      if (allItemsSelected) {
        this.selected_items.unshift(this.menu_item);
        console.log('Emitting add-to-kart:', this.selected_items);
        this.$emit('add-to-kart', this.selected_items);
        this.$emit('close');
      } else {
        console.log('Please select all items before adding to the cart.');
      }
    },

    // @vuese
    /**
     * @method currentItems
     * @description
     * Puts respective entree or side in the selected_items array.
     * 
     * @param {number} index - The index of the selected item.
     * @param {object} item - The selected item object.
     * 
     * @returns {void}
     */
    currentItems(index, item) {
      console.log('Selected Item:', item);
      console.log('Selected Index:', index);
      //puts respective entree or side in the selected_items array
      this.selected_items[index] = item;
    },
  },
};
</script>

<style scoped>
.popup {
  position: fixed;
  top: 50%;
  left: 50%;
  width: 90%;
  height: 90%;
  transform: translate(-50%, -50%);
  background-color: white;
  padding: 20px;
  border: 1px solid black;
  overflow-y:scroll;
}
.ul{
  display: flex;
  justify-content: space-around;
  align-items: center;
  flex: 1;
  flex-wrap: wrap;
  padding: 20px;
  overflow-y: auto; /* Ensure the container is scrollable */
}

.popup button {
  margin: 0.5em;
  padding: 0.5em 0.75em; 
  color: #242528;
  background-color: #C3C7D0;
}
</style>