<template>
    <div class="kitchen-display">
        <h1>Order List</h1>
        <div v-if="loading">Loading...</div>
        <ul v-if="!loading && menuItems.length"></ul>
        <div class="order-list">
            <li v-for="item in menuItems" :key="item.menu_id" class="order-box">
                <h2>{{ item.menu_name }}</h2>
                <p>Order Number: ${{ item.price }}</p>
                <p>Contents: {{ item.category }}</p>
            </li>
        </div>
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
  .order-list {
      background-color: white;
      border-radius: 8px;
      box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
      padding: 20px;
      display: flex;
      flex-wrap: wrap;
      justify-content: center;
      gap: 15px; /* space between boxes */
  }

  .order-box {
      background-color: #e2e2e2;
      border-radius: 5px;
      padding: 20px;
      width: 150px; /* width of each box */
      text-align: center;
      transition: transform 0.3s;
  }

  .order-box:hover {
      transform: scale(1.05); /* scaling effect on hover */
  }
</style>