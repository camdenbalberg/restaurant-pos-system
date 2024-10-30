<template>
    <div>
      <div v-if="loading">Loading...</div>

      <div v-if="!loading && menuItems.length" class="menu-category">
        I am a category title!
        <ul>
          <li v-for="item in menuItems">
            <button class="menu-item" :key="item.menu_id">{{item.menu_name}}</button>
          </li>
        </ul>
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

        combos: [],
        entrees: [],
        sides: [],
        appetizers: [],
        drinks: [],
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

          for (item in this.menuItems) {
            if (item.category == "meal") {
              this.combos += item;
            }
          }

        }
      },
    },
  };
  </script>
  
<style scoped>  
  .menu-category ul {
    display: grid;
    grid-template-columns: auto auto auto auto;
    gap: 1.5em 1em;
  }

  .menu-item {
    border: 1px solid #ccc;
    border-radius: 4px;
    padding: 0.5em;
    background-color: #f9f9f9;

    width: 100%;
    height: 100%;
  }
</style>
  
  