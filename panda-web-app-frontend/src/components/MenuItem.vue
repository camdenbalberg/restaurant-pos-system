<template>
  <div class="menu-items">
    <h1>Menu Items</h1>
    <div v-if="loading">Loading...</div>
    <ul v-if="!loading && filteredMenuItems.length" class="category">
      <li v-for="item in filteredMenuItems" :key="item.menu_id" class="menu-item">
        <picture>
          <source :srcset="`../assets/menu/${item.menu_name}.avif`" type="image/avif">
          <img :src="`../assets/menu/${item.menu_name}.avif`" :alt="item.menu_name">
        </picture>
        <h2>{{ item.menu_name }}</h2>
        <p>Price: ${{ item.price }}</p>
        <p>Category: {{ item.category }}</p>
      </li>
    </ul>
    <div v-if="!loading && !filteredMenuItems.length">No menu items available.</div>
  </div>
</template>

<script>
import axios from 'axios';

export default {
  name: 'MenuItems',
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
        console.log(import.meta.env.VITE_API_BACKEND_URL);
        const response = await axios.get('/api/v1/menu_items');
        this.menuItems = response.data;
      } catch (error) {
        console.error('Error fetching menu items:', error);
      } finally {
        this.loading = false;
      }
    },
  },
};
</script>

<style>
.menu-items {
  padding: 20px;
}

.menu-item {
  margin-bottom: 10px;
}

.category{
  border: 1px solid black;
  border-radius: 4px;
  overflow-y: scroll;
  left: 50%;
  height:350px;
}
</style>