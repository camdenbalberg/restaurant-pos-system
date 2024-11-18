<template>
  <div class="container">
    <div @click="showKart" class="kart">
      <img src="../assets/shopping-cart.png" alt="kart" class="kart-picture">
    </div>
    <div :class="['button-container', { 'no-scroll': mealType }]">
      <div v-for="meal in filteredMenuItems" :key="meal">
        <button @click="handleShowMeal(meal)">
          <picture>
            <source :srcset="`../../src/assets/menu/${meal.menu_id}.avif`" type="image/avif">
            <img :src="`../../src/assets/menu/${meal.menu_id}.avif`" :alt="meal.menu_name">
          </picture>
          {{ meal.menu_name }}
        </button>
      </div>
      <button @click="handleShowMeal('drink')">
        <picture>
          <source :srcset="`../../src/assets/menu/drinks.avif`" type="image/avif">
          <img :src="`../../src/assets/menu/drinks.avif`" alt="drinks">
        </picture>
        Drinks
      </button>
      <button @click="handleShowMeal('appetizer')">
        <picture>
          <source :srcset="`../../src/assets/menu/appetizers.avif`" type="image/avif">
          <img :src="`../../src/assets/menu/appetizers.avif`" alt="appetizers">
        </picture>
        Appetizers
      </button>
    </div>
    <!--delete popup when dynamically made-->
    <MealPopup v-if="mealType" :menu_item="mealType" :cat="mealItems" @close="closeMeal" @add-to-kart="addToKart($event)"/>
    <Kart v-if="kartVisible" :orderedItems="orderedItems" @close="closeKart" @empty-kart="emptyKart"/>
    <AppOrDrinkPopup v-if="appOrDrinkType" :menu_item="appOrDrinkType" :cat="appOrDrinkItems" @close="closeAppOrDrink" @add-to-kart="addToKart($event)"/>
    <footer>
      <router-link to="/">Go to Home</router-link>
    </footer>
  </div>
</template>

<script>
//delete popup when dynamically made
import MealPopup from '../components/MealPopup.vue'; // Adjust path if necessary
import Kart from '../components/Kart.vue'; // Adjust path if necessary
import api from '@/api';
import AppOrDrinkPopup from '../components/AppOrDrinkPopup.vue';

export default {
  name: 'Customer',
  components: {
    MealPopup,
    Kart,
    AppOrDrinkPopup,
  },
  data() {
    return {
      mealType: null,
      mealItems: [],
      appOrDrinkType: null,
      appOrDrinkItems: [],
      kartVisible: false,
      orderedItems: [],
      menuItems: [],
      categories: [],
      drinks: [],
      appetizers: [],
    };
  },
  mounted() {
    this.fetchMenuItems();
  },
  computed: {
    filteredMenuItems() {
      return this.menuItems.filter(item => item.category === 'meal');
    },
  },
  methods: {
    async handleShowMeal(meal) {
      try {
        this.categories = [];
        if(typeof meal === 'string' && meal === 'drink'){
          console.log('Drinks');
          this.categories.push('drink');
          this.showAppOrDrink(meal, this.categories);
          return;
        } else if(typeof meal === 'string' && meal === 'appetizer'){
          console.log('Appetizers');
          this.categories.push('appetizer');
          this.showAppOrDrink(meal, this.categories);
          return;
        }
        else{
          const inv_ids = await this.getEntreesSides(meal);
          for(let inv_id of inv_ids){
            if(inv_id.inv_id === 55){
              for(let i = 0; i < inv_id.quantity; i++){
                this.categories.push('side');
              }
            } else if(inv_id.inv_id === 54){
              for(let i = 0; i < inv_id.quantity; i++){
                this.categories.push('entree'); 
              }
            }
          }
          console.log(this.categories);
          this.showMeal(meal, this.categories);
        }
      } catch (error) {
        console.error('Error showing popup:', error);
      }
    },
    showMeal(type, items) {
      this.mealType = type;
      this.mealItems = items;
    },
    closeMeal() {
      this.mealType = null;
      this.mealItems = [];
    },
    showAppOrDrink(type, items) {
      this.appOrDrinkType = type;
      this.appOrDrinkItems = items;
    },
    closeAppOrDrink() {
      this.appOrDrinkType = null;
      this.appOrDrinkItems = [];
    },
    showKart() {
      this.kartVisible = true;
    },
    closeKart() {
      this.kartVisible = false;
    },
    emptyKart() {
      this.orderedItems = [];
    },
    addToKart(items) {
      console.log('Adding to kart:', items);
      //create a list of items to be added to the kart
      let newItems = [];
      newItems.push(items[0]);
      for(let i = 1; i < items.length; i++){
        newItems.push(items[i]);
      }
      this.orderedItems.push(newItems);
    },
    async fetchMenuItems() {
      try {
          // Example usage of env var
          console.log(import.meta.env.VITE_API_BACKEND_URL);
          const response = await api.get('/menu_items');
          this.menuItems = response.data;
      } catch (error) {
          console.error('Error fetching menu items:', error);
      } finally {
          this.loading = false;
      }
    },
    async getEntreesSides(meal) {
        //get all items corresponding to the meal and put in a list
        console.log(meal);
        //gets the recipe for the meal
        const response = await api.get(`/recipes/${meal.menu_id}`);
        console.log(response.data);
        let entreesSides = response.data;
        //filter so only contains entrees and sides
        entreesSides = entreesSides.filter(item => item.inv_id === 55 || item.inv_id === 54);
        console.log(entreesSides);
        return entreesSides;
    },
  },
};
</script>

<style scoped>
.container {
  display: flex;
  flex-direction: column;
  height: 100vh;
}

.button-container {
  display: flex;
  justify-content: space-around;
  align-items: center;
  flex: 1;
  flex-wrap: wrap;
  padding: 20px;
  overflow-y: auto; /* Ensure the container is scrollable */
}

.button-container.no-scroll {
  overflow: hidden; /* Hide the scrollbar when the popup is visible */
}

.kart {
  position: absolute;
  bottom: 10px; /* Adjust as needed */
  right: 10px; /* Adjust as needed */
  width: 75px; /* Adjust as needed */
  height: 75px; /* Adjust as needed */
  border-radius: 50%;
  transition: scale 0.5s ease;
  transition: background-color 0.25s ease;
  background-color: var(--surfaceColor);
  border: 1px solid black;
}

.kart:hover {
  background-color: var(--accentColorWeak);
  cursor: hand;
  scale: 1.1;
}

.kart:active {
  scale: 1;
  background-color: var(--accentColor);
}

.kart-picture {
  width: 50px;
  height: 50px;
  top: 50%;
  left: 50%;
}

.circle:hover {
  background-color: var(--accentColorWeak);
  scale: 1.1;
}

.circle:active {
  scale: 1;
  background-color: var(--accentColor);
}

button {
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

footer {
  text-align: center;
  padding: 10px;
}
</style>