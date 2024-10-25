<template>
  <div class="menu-items">
    <h1>Menu Items</h1>
    <div v-if="loading">Loading...</div>
    <ul v-if="!loading && menuItems.length">
      <li v-for="item in menuItems" :key="item.menu_id" class="menu-item">
        <h2>{{ item.menu_name }}</h2>
        <p>Price: ${{ item.price }}</p>
        <p>Category: {{ item.category }}</p>
      </li>
    </ul>
    <div v-if="!loading && !menuItems.length">No menu items available.</div>
  </div>
</template>

<script>
import axios from 'axios';

export default {
  data() {
    return {
      menuItems: [],
      loading: true,
    };
  },
  mounted() {
    this.fetchMenuItems();
  },
  name: 'MenuItems',
  methods: {
    async fetchMenuItems() {
      try {
        const response = await axios.get('${import.meta.env.VITE_API_BACKEND_URL}/v1/menu_items');
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

.menu-item h2 {
  margin: 0;
}

.menu-item p {
  margin: 5px 0;
}
</style>

