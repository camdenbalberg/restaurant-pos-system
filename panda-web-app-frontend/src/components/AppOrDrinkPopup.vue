<template>
    <div class="popup">
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
  // Initial fields.
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
      type: String,
      required: true,
    },
    cat:{
      type: Array,
      required: true,
      validator(value) {
        return value.every(item => typeof item === 'string');
      }
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
   * - 'addToKart' emits the selected items to the parent component.
   * - 'currentItems' puts the selected entree or side in the selected_items array.
   */
  methods: {
    // @vuese
    /**
     * @method initializeSelectedItems
     * @description
     * Initializes the selected items array.
     */
    initializeSelectedItems() {
      //initialize selected_items array with number of entrees and sides
      this.selected_items = new Array(this.cat.length).fill(null);
      console.log(this.cat);
    },

    // @vuese
    /**
     * @method addToKart
     * @description
     * Emits the selected items to the parent component.
     */
    addToKart() {
      const allItemsSelected = this.selected_items.every(item => item !== null);
      if (allItemsSelected) {
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
     * Puts the selected entree or side in the selected_items array.
     * 
     * @param {number} index - The index of the selected item.
     * @param {Object} item - The selected item object.
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