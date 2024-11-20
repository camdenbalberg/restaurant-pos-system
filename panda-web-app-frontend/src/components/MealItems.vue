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
          <p>Price: ${{ item.price }}</p>
          <p>Category: {{ item.category }}</p>
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
  data() {
    return {
      menuItems: [],
      loading: true,
      activeButtonIndex: null,
    };
  },
  computed: {
    filteredMenuItems() {
      return this.menuItems.filter(item => item.category === this.category);
    },
  },
  mounted() {
    this.fetchMenuItems();
  },
  methods: {
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
    selected(item) {
      console.log('Selected New Item:', item); // Debugging log
      this.$emit('selected', item);
    },
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
  max-width: 600px;
  margin: auto;
}

.menu-item {
  border: 1px solid #ccc;
  border-radius: 4px;
  padding: 15px;
  margin: 10px 0;
  background-color: #f9f9f9;
}

.category{
  border: 1px solid black;
  border-radius: 4px;
  overflow-y: scroll;
  left: 50%;
  height:350px;
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
</style>
