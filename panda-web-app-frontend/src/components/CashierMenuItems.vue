<template>
    <div>
      <div v-if="loading">Loading...</div>
      <ul v-if="!loading && menuItems.length" class="menu-category">
        <li v-for="item in menuItems" :key="item.menu_id">
          <button class="menu-item">{{item.menu_name}}</button>
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
    name: 'CashierMenuItems',
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
  
<style scoped>  
  .menu-category {
    display: grid;
    grid-template-columns: auto auto auto auto;
    gap: 1em;
  }

  .menu-item {
    border: 1px solid #ccc;
    border-radius: 4px;
    padding: 1em;
    background-color: #f9f9f9;
  }
  
  .menu-item h2 {
    margin: 0;
  }
  
  .menu-item p {
    margin: 5px 0;
  }
</style>
  
  