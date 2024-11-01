<template>
    <div>
      <div v-if="loading">Loading...</div>

      <div v-if="!loading && meals.length" class="menu-category">
        <div class="menu-category-title">Meals</div>
        <ul>
          <li v-for="item in meals" :key="item.menu_id">
            <button class="menu-item" id={{item.menu_id}}>{{item.menu_name}}</button>
          </li>
        </ul>
      </div>

      <div v-if="!loading && appetizers.length" class="menu-category">
        <div class="menu-category-title">Appetizers</div>
        <ul>
          <li v-for="item in appetizers" :key="item.menu_id">
            <button class="menu-item" id={{item.menu_id}}>{{item.menu_name}}</button>
          </li>
        </ul>
      </div>

      <div v-if="!loading && drinks.length" class="menu-category">
        <div class="menu-category-title">Drinks</div>
        <ul>
          <li v-for="item in drinks" :key="item.menu_id">
            <button class="menu-item" id={{item.menu_id}}>{{item.menu_name}}</button>
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

        meals: [],
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
          console.log(import.meta.env.VITE_API_BACKEND_URL);
          const response = await axios.get('/api/v1/menu_items');
          this.menuItems = response.data;
        } catch (error) {
          console.error('Error fetching menu items:', error);
        } finally {
          this.meals = this.menuItems.filter(item => item.category == "meal");
          this.entrees = this.menuItems.filter(item => item.category == "entree");
          this.sides = this.menuItems.filter(item => item.category == "side");
          this.appetizers = this.menuItems.filter(item => item.category == "appetizer");
          this.drinks = this.menuItems.filter(item => item.category == "drink");

          this.loading = false;
        }
      },
    },
  };
  </script>
  
<style scoped>  
  .menu-category {
    margin-bottom: 2em;
  }

  .menu-category ul {
    display: grid;
    grid-template-columns: 30vh 30vh 30vh 30vh;
    grid-auto-rows: 1fr;
    gap: 1.5em 1em;
  }

  .menu-category-title {
    text-align: left;
    margin-left: 0.5em;
    font-weight: 700;
    font-size: 150%;
  }

  .menu-item {
    width: 100%;
    height: 100%;
    margin: 0;
    padding: 0.5em;
    border: 1px solid #ccc;
    border-radius: 4px;
    background-color: #f9f9f9;
  }
</style>
  
  