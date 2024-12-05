<template>
  <div class="menu-items">
    <h1>{{ category }}</h1>
    <div v-if="loading">Loading...</div>
    <ul v-if="!loading && filteredMenuItems.length" class="category">
      <!--loop through all items in each category-->
      <li v-for="(item, index) in filteredMenuItems" :key="item.menu_id" class="menu-item">
        <button :class="{ 'active-button': activeButtonIndex === index }"
        @click="handleButtonClick(index, item)">
          <picture>
            <source :srcset="item.image_url || `../../src/assets/menu/${item.menu_id}.avif`" type="image/avif">
            <img :src="item.image_url || `../../src/assets/menu/${item.menu_id}.avif`" :alt="item.menu_name">
          </picture>
          <h2>{{ item.menu_name }}</h2>
          <p v-if="item.price > 0">${{ item.price.toFixed(2) }}</p>
        </button>
      </li>
    </ul>
    <div v-if="!loading && !filteredMenuItems.length">No menu items available.</div>
  </div>
</template>

<script>
import api from '@/api';

export default {
  name: 'MealItems',
  props: {
    category: {
      type: String,
      required: true,
    },
  },

  // @vuese
  /**
   * @data
   * @description
   * Initial fields for the component.
   * 
   * - 'menuItems' holds the menu items.
   * - 'loading' is a boolean to show loading state.
   * - 'activeButtonIndex' is the index of the active button.
   */
  data() {
    return {
      menuItems: [],
      loading: true,
      activeButtonIndex: null,
    };
  },

  // @vuese
  /**
   * @computed
   * @description
   * Computed properties for the component.
   * 
   * - 'filteredMenuItems' filters the menu items by category.
   */
  computed: {
    filteredMenuItems() {
      return this.menuItems.filter(item => item.category === this.category);
    },
  },

  // @vuese
  /**
   * @mounted
   * @description
   * Fetches the menu items when the component is mounted.
   */
  mounted() {
    this.fetchMenuItems();
  },

  // @vuese
  /**
   * @methods
   * @description
   * Methods for the component.
   * 
   * - 'fetchMenuItems' fetches the menu items.
   * - 'selected' emits the selected item.
   * - 'handleButtonClick' handles the button click event.
   */
  methods: {
    // @vuese
    /**
     * @method fetchMenuItems
     * @description
     * Fetches the menu items.
     */
    async fetchMenuItems() {
      try {
        // Example usage of env var
        const response = await api.get('/menu_items');
        this.menuItems = response.data;
      } catch (error) {
        console.error('Error fetching menu items:', error);
      } finally {
        this.loading = false;
      }
    },

    // @vuese
    /**
     * @method selected
     * @description
     * Emits the selected item.
     * 
     * @param {Object} item - The selected item.
     */
    selected(item) {
      console.log('Selected New Item:', item); // Debugging log
      this.$emit('selected', item);
    },

    // @vuese
    /**
     * @method handleButtonClick
     * @description
     * Handles the button click event.
     * 
     * @param {number} index - The index of the button.
     * @param {Object} item - The selected item.
     */
    handleButtonClick(index, item) {
      this.activeButtonIndex = index;
      this.selected(item);
    },
  },
};
</script>

<style scoped>
.menu-items {
  padding: 20px;
  max-width: 100%;
  margin: auto;
}

.menu-item {
  display: flex;
  flex-direction: column;
  justify-content: space-between;
  align-items: center;
  border: 1px solid #ccc;
  border-radius: 4px;
  padding: 20px;
  margin: 10px;
  background-color: #f9f9f9;
  width: calc(20% - 20px); /* Adjust width to fit two items per row */
  box-sizing: border-box;
  height: auto; /* Set a fixed height for consistency */
}

.category{
  display: flex;
  flex-wrap: wrap;
  width: 100%;
  border: 1px solid black;
  border-radius: 4px;
  left: 50%;
  height: fit-content;
}

button{
  flex: 1 1 20%;
  margin: 10px;
  padding: 10px;
  border-radius: 5px;
  font-size: 16px;
  background-color: white;
  border: 1px solid black;
  color: black;
  max-width: 200px;
  min-width: 100px;
}
button:hover {
  background-color: var(--accentColorWeak);
  scale: 1.1;
}

button:active {
  scale: 1;
  background-color: var(--accentColor);
}
.active-button {
  background-color: red;
  color: white;
}
img{
  margin:auto;
}
</style>
