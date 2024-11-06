<template>
    <div class="popup">
      <p>{{ menu_item }}</p>
      <ul>
        <!--loop through all categories passed into popup-->
        <li v-for="(item, index) in cat" :key="item">
          <MenuItem :category="item" @selected="currentItems(index, $event)" />
        </li>
      </ul>
      <button @click="$emit('close')">Close</button>
      <button @click="addToKart(item)">Add To Order</button>
    </div>
</template>

<script>
import MenuItem from './MealItems.vue'; // Adjust path if necessary

export default {
  name: 'Popup',
  components: {
    MenuItem,
  },
  data() {
    return {
      selected_items: [],
    };
  },
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
      },
    },
  },
  created() {
    this.initializeSelectedItems();
  },
  methods: {
    initializeSelectedItems() {
      this.selected_items = new Array(this.cat.length).fill(null);
    },
    addToKart() {
      const allItemsSelected = this.selected_items.every(item => item !== null);
      if (allItemsSelected) {
        this.selected_items.unshift(this.menu_item);
        console.log('Emitting add-to-kart:', this.selected_items);
        this.$emit('add-to-kart', this.selected_items);
      } else {
        console.log('Please select all items before adding to the cart.');
      }
      this.$emit('close');
    },
    currentItems(index, item) {
      console.log('Selected Item:', item);
      console.log('Selected Index:', index);
      //make it name instead of being menuItem so it dislpays for now
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
</style>