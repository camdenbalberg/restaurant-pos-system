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
  data() {
    return {
      selected_items: [],
    };
  },
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
  created() {
    this.initializeSelectedItems();
  },
  methods: {
    initializeSelectedItems() {
      //initialize selected_items array with number of entrees and sides
      this.selected_items = new Array(this.cat.length).fill(null);
      console.log(this.cat);
    },
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
</style>