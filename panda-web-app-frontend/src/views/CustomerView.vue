<template>
  <!--Holds buttons for meal items-->
  <div class="container">
    <div class="button-container">
      <!--Loop through all meals and preps the popus-->
      <div v-for="meal in filteredMenuItems" :key="meal">
        <button @click="handleShowMeal(meal)">
          <picture>
            <source :srcset="meal.image_url ||`../../src/assets/menu/${meal.menu_id}.avif`" type="image/avif">
            <img :src="meal.image_url || `../../src/assets/menu/${meal.menu_id}.avif`" :alt="meal.menu_name">
          </picture>
          {{ meal.menu_name }}
          <!--Only show price of meal if it is premium-->
          <p v-if="meal.price > 0">${{ meal.price.toFixed(2) }}</p>
        </button>
      </div>
      <!--Handle Drinks and Appetizers differently from meals as they are stored differently in database-->
      <button @click="handleShowMeal('drink')">
        <picture>
          <source :srcset="`https://i.imgur.com/JPUW4k4.jpeg`">
          <img :src="`https://i.imgur.com/JPUW4k4.jpeg`" alt="drinks">
        </picture>
        Drinks
      </button>
      <button @click="handleShowMeal('appetizer')">
        <picture>
          <source :srcset="`https://i.imgur.com/dFsyKuk.png`">
          <img :src="`https://i.imgur.com/dFsyKuk.png`" alt="appetizers">
        </picture>
        Appetizers
      </button>
      <!--Button for Kart-->
      <button @click="showRec" class="kart">
        <img src="../assets/shopping-cart.png" alt="kart" class="kart-picture">
        <p>Kart</p>
        <div v-if="orderedItems.length > 0" class="orderNum">{{ orderedItems.length }}</div>
      </button>
    </div>
    <!--All the different popups-->
    <MealPopup v-if="mealType" :menu_item="mealType" :cat="mealItems" @close="closeMeal" @add-to-kart="addToKart($event)"/>
    <Kart v-if="kartVisible" :orderedItems="orderedItems" @close="closeKart" @empty-kart="emptyKart" @remove-item="removeItem($event)"/>
    <AppOrDrinkPopup v-if="appOrDrinkType" :menu_item="appOrDrinkType" :cat="appOrDrinkItems" @close="closeAppOrDrink" @add-to-kart="addToKart($event)"/>
    <Recommendations v-if="recVisible" :menuItems="menuItems" :orderedItems="orderedItems" @close="closeRec" @add-to-kart="addToKart($event)" @handle-show-meal="handleShowMeal($event)"/>
  </div>
</template>

<script>
//All imports
import MealPopup from '../components/MealPopup.vue'; // Adjust path if necessary
import Kart from '../components/Kart.vue'; // Adjust path if necessary
import api from '@/api';
import AppOrDrinkPopup from '../components/AppOrDrinkPopup.vue';
import Recommendations from '../components/Recommendations.vue';
import shared from '../shared'

export default {
  //All imported components
  name: 'Customer',
  components: {
    MealPopup,
    Kart,
    AppOrDrinkPopup,
    Recommendations,
  },

  // @vuese
  /**
   * @data
   * @description
   * Initial fields for the component.
   * 
   * - 'mealType': Stores the type of meal i.e bowl, plate, etc.
   * - 'mealItems': Stores all the items in a meal i.e. sides and entrees
   * - 'appOrDrinkType': Stores the type of meal i.e. drink, appetizer
   * - 'appOrDrinkItems': Stores all the items in a drink or appetizer
   * - 'kartVisible': Stores if the kart is visible
   * - 'orderedItems': Stores all the items in the kart
   * - 'menuItems': Stores all the menu items
   * - 'categories': Stores the categories of the meal
   * - 'drinks': Stores all the drinks
   * - 'appetizers': Stores all the appetizers
   * - 'recVisible': Stores if the recommendations are visible
   * - 'isLocked':
   * - 'passkey':
   */
  data() {
    return {
      isLocked: false,
      passkey: "",
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
      recVisible: false, 
    };
  },
  // @vuese
  // Initial fields.
  mounted() {
    this.fetchMenuItems(); //fetch all menu items
    this.checkScreenLockStatus(); //check if the screen is locked
  },

  // @vuese
  // Enable flash scaffolding functionality from a shared js file.
  created() {
    this.flashScaffolding = shared.flashScaffolding
  },
  computed: {
    filteredMenuItems() {
      return this.menuItems.filter(item => item.category === 'meal');
    },
  },

  beforeRouteLeave(to, from, next) {
    if (!this.isLocked) {
      next();  // Allow navigation if the screen is not locked
    } else {
      const enteredPasskey = prompt("Please enter the passcode to leave the page.");
      console.log(this.passkey); //remove later
      if (enteredPasskey === this.passkey) {
        this.flashScaffolding();
        this.isLocked = false;
        this.handleUnlock();
        next();
      } else {
        alert("Incorrect passkey. You cannot leave the page.");
        next(false);  // Prevent navigation if passkey is incorrect
      }
    }
  },
  methods: {
    async handleUnlock() {
      try {
        const response = await api.unlockScreen({
          screen: {
            screenType: 'Customer',
            passkey: this.passkey,
          },
        });

        // Check if the response contains a success message
        if (response.message) {
          this.isLocked = false;  // Update the locked state after unlocking
          console.log('Screen unlocked successfully');
        } else {
          console.error('Unexpected response format:', response);
          alert('Failed to unlock the screen. No message received.');
        }
      } catch (error) {
        console.error("Error unlocking the screen:", error);
        alert('Failed to unlock the screen. Please check your passkey.');
      }
    },
    
    async checkScreenLockStatus() {
      try {
        const response = await api.get('screen_status', {
          params: { screen_type: 'Customer' }
        });
        if (response.data.locked) {
          this.isLocked = true;
          this.passkey = response.data.passkey || "";  // Optionally, store the passkey if returned
        } else {
          this.isLocked = false;
        }
      } catch (error) {
        console.error("Error fetching screen lock status:", error);
      }
    },

     /**
     * @method handleShowMeal
     * @description
     * This method shows the meal popup for the selected meal. It also checks if the meal is a drink or appetizer
     * and shows the respective popup.
     * 
     * @param {string} or {Object} meal - The meal to show the popup for.
     * @returns {void}
     */
    async handleShowMeal(meal) {
      try {
        console.log('Showing meal:', meal);
        this.categories = [];
        //check if the meal is a drink or appetizer
        if(typeof meal === 'string' && meal === 'drink'){
          this.categories.push('drink');
          console.log(this.categories);
          this.showAppOrDrink(meal, this.categories);
          return;
        } else if(typeof meal === 'string' && meal === 'appetizer'){
          this.categories.push('appetizer');
          this.showAppOrDrink(meal, this.categories);
          return;
        }
        else{
          //get all the entrees and sides for the meal
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

     /**
     * @method showMeal
     * @description
     * Handle showing the meal popup.
     * 
     * @param {Object} type - The type of meal i.e bowl, plate, etc.
     * @param {Array} items - The items in the meal i.e sides and entrees
     * @returns {void}
     */
    showMeal(type, items) {
      this.mealType = type;
      this.mealItems = items;
    },

    /**
     * @method closeMeal
     * @description
     * Handle closing the meal popup.
     * 
     * @returns {void}
     */
    closeMeal() {
      this.mealType = null;
      this.mealItems = [];
    },

    /**
     * @method showAppOrDrink
     * @description
     * Handle showing the drink or appetizer popup.
     * 
     * @param {Object} type - The type of drink or appetizer
     * @param {Array} items - The items in the drink or appetizer
     * @returns {void}
     */
    showAppOrDrink(type, items) {
      this.appOrDrinkType = type;
      this.appOrDrinkItems = items;
    },

    /**
     * @method closeAppOrDrink
     * @description
     * Handle closing the drink or appetizer popup.
     * 
     * @returns {void}
     */
    closeAppOrDrink() {
      this.appOrDrinkType = null;
      this.appOrDrinkItems = [];
    },

    /**
     * @method showKart
     * @description
     * Handle showing the kart popup.
     * 
     * @returns {void}
     */
    showKart() {
      this.kartVisible = true;
    },

    /**
     * @method closeKart
     * @description
     * Handle closing the kart popup.
     * 
     * @returns {void}
     */
    closeKart() {
      this.kartVisible = false;
    },

    /**
     * @method emptyKart
     * @description
     * Handle emptying the kart.
     * 
     * @returns {void}
     */
    emptyKart() {
      this.orderedItems = [];
    },

    /**
     * @method showRec
     * @description
     * Handle showing the recommendations popup
     * 
     * @returns {void}
     */
    showRec(){
      this.recVisible = true;
    },
    
    /**
     * @method closeRec
     * @description
     * Handle closing the recommendations popup
     * 
     * @returns {void}
     */
    closeRec() {
      this.recVisible = false;
      this.showKart();
    },

    /**
     * @method addToKart
     * @description
     * Handle adding items to the kart
     * 
     * @param {Array{Array{Object}}} items - The items to be added to the kart
     * @returns {void}
     */
    addToKart(items) {
      console.log('Adding to kart:', items);
      //create a list of items to be added to the kart
      let newItems = [];
      newItems.push(items[0]);
      for(let i = 1; i < items.length; i++){
        newItems.push(items[i]);
      }
      //add the items to the kart
      this.orderedItems.push(newItems);
      this.flashScaffolding();
    },

  /**
     * @method fetchMenuItems
     * @description
     * Handle fetching all menu items
     * 
     * @returns {void}
     */
    async fetchMenuItems() {
      try {
          // Example usage of env var
          console.log(import.meta.env.VITE_API_BACKEND_URL);
          const response = await api.get('/menu_items');
          this.menuItems = response.data;
          this.flashScaffolding();
      } catch (error) {
          console.error('Error fetching menu items:', error);
      } finally {
          this.loading = false;
      }
    },

    /**
     * @method getEntreesSides
     * @description
     * Handle getting all entrees and sides for a meal
     * 
     * @returns {void}
     */
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
        this.flashScaffolding();
        return entreesSides;
    },

    /**
     * @method removeItem
     * @description
     * Handle removing an item from the kart
     * 
     * @param {number} index - The index of the item to be removed
     * @returns {void}
     */
    removeItem(index) {
      console.log('Removing item:', index);
      this.orderedItems.splice(index, 1);
      this.flashScaffolding();
    },
  },
};
</script>

<style scoped>
.container {
  min-width: 100%;
  height: 100%;
  display: flex;
  flex-direction: column;
}

.button-container {
  display: flex;
  justify-content: flex-start;
  align-items: normal;
  flex: 1;
  flex-wrap: wrap;
  padding: 20px;
}

.kart {
  display: flex;
  flex-wrap: wrap;
  flex-direction: column;
  justify-content: center;
  align-content: center;
  align-items: center;
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

.orderNum {
  justify-content: center;
  align-items: center;
  text-align: center;
  background-color:crimson;
  color: white;
  border-radius: 50%;
  font-size: 16px;
  width: 25px;
  height: 25px;
  border: 1px solid black;
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
  min-width: 200px;
}

footer {
  text-align: center;
  padding: 10px;
}
</style>