<template>
    <div>
      <div v-if="loading">Loading...</div>

      <div v-if="!loading && !menuItems.length">No menu items available.</div>

      <div v-if="!loading && meals.length" class="menu-category">
        <div class="menu-category-title">Meals</div>
        <ul class="cashier-selection-list">
          <li v-for="item in meals">
            <button @click="showPopup(item.menu_name, ['side', 'entree'])" class="menu-item" :id="item.menu_id">{{item.menu_name}}</button>
          </li>
        </ul>
      </div>

      <div v-if="!loading && appetizers.length" class="menu-category">
        <div class="menu-category-title">Appetizers</div>
        <ul class="cashier-selection-list">
          <li v-for="item in appetizers">
            <button class="menu-item" :id="item.menu_id">{{item.menu_name}}</button>
          </li>
        </ul>
      </div>

      <div v-if="!loading && drinks.length" class="menu-category">
        <div class="menu-category-title">Drinks</div>
        <ul class="cashier-selection-list">
          <li v-for="item in drinks" :key="item.menu_id">
            <button class="menu-item" :id="item.menu_id">{{item.menu_name}}</button>
          </li>
        </ul>
      </div>
    </div>

    <CashierPopup v-if="popup" :menu_item="selectedItem" :cat="mealItems" @close="closePopup" />
  </template>
  
  <script>
  import axios from 'axios';
  import CashierPopup from './CashierPopup.vue';
  
  export default {
    name: 'CashierMenuItems',
    components: {
      CashierPopup,
    },
    data() {
      return {
        loading: true,
        menuItems: [],
        meals: [],
        // entrees: [],
        // sides: [],
        appetizers: [],
        drinks: [],

        popup: false, 
        selectedItem: "",
        mealItems: [],
      };
    },
    mounted() {
      this.fetchMenuItems();
    },
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
          // this.entrees = this.menuItems.filter(item => item.category == "entree");
          // this.sides = this.menuItems.filter(item => item.category == "side");
          this.appetizers = this.menuItems.filter(item => item.category == "appetizer");
          this.drinks = this.menuItems.filter(item => item.category == "drink");

          this.loading = false;
        }
      },

      showPopup(menuItem, mealStructure) {
        this.popup = true;
        this.selectedItem = menuItem;
        this.mealItems = mealStructure;
      },

      closePopup() {
        this.popup = false;
        this.selectedItem = "";
        this.mealItems = [];
      },
    },
  };
  </script>
  
<style scoped>  
  .menu-category {
    margin-bottom: 2em;
  }

  .menu-category-title {
    text-align: left;
    margin-left: 0.5em;
    font-weight: 700;
    font-size: 150%;
  }

  .cashier-selection-list {
    display: grid;
    grid-template-columns: 1fr 1fr 1fr 1fr;
    grid-auto-rows: 1fr;
    gap: 1.5em 1em;
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
  
  