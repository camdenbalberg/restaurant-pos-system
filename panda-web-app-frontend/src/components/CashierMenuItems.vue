<template>
  <div>
    <div v-if="loading">Loading...</div>

    <div v-if="!loading && !menuItems.length">No menu items available.</div>

    <div v-if="!loading && meals.length" class="menu-category">
      <div class="menu-category-title">Meals</div>
      <ul class="cashier-selection-list">
        <li v-for="item in meals" :key="item.menu_id">
          <button class="menu-item" :id="item.menu_id" @click="handleShowMeal(item)">
            {{ item.menu_name }}
          </button>
        </li>
      </ul>
    </div>

    <div v-if="!loading && appetizers.length" class="menu-category">
      <div class="menu-category-title">Appetizers</div>
      <ul class="cashier-selection-list">
        <li v-for="item in appetizers" :key="item.menu_id">
          <button class="menu-item" :id="item.menu_id" @click="submitItem(item)">
            {{ item.menu_name }}
          </button>
        </li>
      </ul>
    </div>

    <div v-if="!loading && drinks.length" class="menu-category">
      <div class="menu-category-title">Drinks</div>
      <ul class="cashier-selection-list">
        <li v-for="item in drinks" :key="item.menu_id">
          <button class="menu-item" :id="item.menu_id" @click="submitItem(item)">
            {{ item.menu_name }}
          </button>
        </li>
      </ul>
    </div>

    <CashierPopup
      v-if="popup"
      :menu_item="selectedItem"
      :cat="mealItems"
      :maxSelections="maxSelections"
      :selectedItems="selectedItems"
      @cancel="closePopup"
      @submitMeal="submitMeal"
    />
  </div>
</template>

  
<script>
import api from '@/api';
import CashierPopup from './CashierPopup.vue';

// @vuese
// @group CashierView
export default {
  name: 'CashierMenuItems',
  components: {
    CashierPopup,
  },
  emits: ['submitItem', 'submitMeal'],

  // @vuese
  // Initial fields.
  data() {
    return {
      loading: true,
      menuItems: [],
      meals: [],
      appetizers: [],
      drinks: [],
      popup: false,
      selectedItem: null,
      mealItems: [],
      maxSelections: {}, // Tracks max selections for each category
      selectedItems: {}, // Tracks selected items by category
    };
  },
  mounted() {
    this.fetchMenuItems();
  },
  methods: {
    // @vuese
    // Fetches menu items from API
    async fetchMenuItems() {
      try {
        const response = await api.get('/menu_items');
        this.menuItems = response.data;
      } catch (error) {
        console.error('Error fetching menu items:', error);
      } finally {
        this.meals = this.menuItems.filter(item => item.category === "meal");
        this.appetizers = this.menuItems.filter(item => item.category === "appetizer");
        this.drinks = this.menuItems.filter(item => item.category === "drink");
        this.loading = false;
      }
    },

    // @vuese
    // Will open a meal popup when a meal is selected
    // @arg the meal as a menu_item
    async handleShowMeal(meal) {
      try {
        const mealStructure = await this.getEntreesSides(meal);

        this.mealItems = [...new Set(mealStructure.map(item => item.category))];
        this.maxSelections = mealStructure.reduce((acc, curr) => {
          acc[curr.category] = (acc[curr.category] || 0) + curr.quantity;
          return acc;
        }, {});

        console.log('Meal items:', this.mealItems);
        console.log('Max selections:', this.maxSelections);

        this.showPopup(meal);
      } catch (error) {
        console.error('Error showing meal:', error);
      }
    },

    // @vuese
    // Get the among of sides and entrees a meal has
    // @arg the meal as a menu_item
    async getEntreesSides(meal) {
      try {
        const response = await api.get(`/recipes/${meal.menu_id}`);
        console.log('Recipe response:', response.data); // Debug log

        // Map inventory IDs to categories
        const entreesSides = response.data
          .filter(item => item.inv_id === 54 || item.inv_id === 55)
          .map(item => ({
            category: item.inv_id === 54 ? 'entree' : 'side',
            quantity: item.quantity,
          }));

        console.log('Processed entrees and sides:', entreesSides);
        return entreesSides;
      } catch (error) {
        console.error('Error fetching entrees and sides:', error);
        return [];
      }
    },

    // @vuese
    // Opens a meal popup for a given meal
    // @arg the meal as a menu_item
    showPopup(menuItem) {
      this.popup = true;
      this.selectedItem = menuItem;
    },

    // @vuese
    // Close the meal popup
    closePopup() {
      this.popup = false;
      this.selectedItem = null;
      this.mealItems = [];
      this.maxSelections = {};
      this.selectedItems = {};
    },

    submitItem(item) {
      // Sends a non-meal item to CashierView
      // @arg a menu item
      this.$emit("submitItem", item);
    },

    submitMeal(meal) {
      // Sends a completed meal item to CashierView
      // @arg a completed meal from the popup menu
      this.$emit("submitMeal", meal);
      this.closePopup();
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
    font-size: 135%;
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
