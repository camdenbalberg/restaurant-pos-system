<template>
  <div class="container">
    <div @click="showKart" class="kart">
      Kart
    </div>
    <div :class="['button-container', { 'no-scroll': popupType }]">
      <button @click="showPopup('Bowl', ['entree', 'side'])">
        <picture>
          <source srcset="../assets/menu/bowl.avif" type="image/avif">
          <img src="../assets/menu/bowl.avif" alt="bowl">
        </picture>
        Bowl
      </button>
      <button @click="showPopup('Plate', ['entree', 'entree', 'side'])">
        <picture>
          <source srcset="../assets/menu/plate.avif" type="image/avif">
          <img src="../assets/menu/plate.avif" alt="bowl">
        </picture>
        Plate
      </button>
      <button @click="showPopup('Bigger Plate', ['entree', 'entree', 'entree', 'side'])">
        <picture>
          <source srcset="../assets/menu/biggerPlate.avif" type="image/avif">
          <img src="../assets/menu/biggerPlate.avif" alt="bowl">
        </picture>
        Bigger Plate
      </button>
      <button @click="showPopup('Appetizer', ['appetizer'])">
        <picture>
          <source srcset="../assets/menu/bowl.avif" type="image/avif">
          <img src="../assets/menu/bowl.avif" alt="bowl">
        </picture>
        Appetizer
      </button>
      <button @click="showPopup('A La Carte', ['entree', 'side'])">
        <picture>
          <source srcset="../assets/menu/aLaCarte.avif" type="image/avif">
          <img src="../assets/menu/aLaCarte.avif" alt="bowl">
        </picture>
        A La Carte
      </button>
      <button @click="showPopup('Drinks', ['drink1', 'drink2'])">
        <picture>
          <source srcset="../assets/menu/drinks.avif" type="image/avif">
          <img src="../assets/menu/drinks.avif" alt="bowl">
        </picture>
        Drink
      </button>
    </div>
    <!--delete popup when dynamically made-->
    <Popup v-if="popupType" :menu_item="popupType" :cat="popupItems" @close="closePopup" @add-to-kart="addToKart($event)"/>
    <Kart v-if="kartVisible" :orderedItems="orderedItems" @close="closeKart"/>

    <footer>
      <router-link to="/">Go to Home</router-link>
    </footer>
  </div>
</template>

<script>
//delete popup when dynamically made
import Popup from '../components/Popup.vue'; // Adjust path if necessary
import Kart from '../components/Kart.vue'; // Adjust path if necessary
import Meals from '../components/Meals.vue'; // Adjust path if necessary

export default {
  name: 'Customer',
  components: {
    Popup,
    Meals,
    Kart,
  },
  data() {
    return {
      popupType: null,
      popupItems: [],
      kartVisible: false,
      orderedItems: [],
    };
  },
  methods: {
    showPopup(type, items) {
      this.popupType = type;
      this.popupItems = items;
    },
    closePopup() {
      this.popupType = null;
      this.popupItems = [];
    },
    showKart() {
      this.kartVisible = true;
    },
    closeKart() {
      this.kartVisible = false;
    },
    addToKart(items) {
      //Doesn't quite work because meal is just a string and not a menu_item at the moment
      console.log('Adding to kart:', items);
      let newItems = [];
      for(let i = 1; i < items.length; i++){
        newItems.push(items[i].menu_name);
      }
      this.orderedItems.push(newItems);
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
  top: 10px; /* Adjust as needed */
  right: 10px; /* Adjust as needed */
  width: 50px; /* Adjust as needed */
  height: 50px; /* Adjust as needed */
  border-radius: 50%;
  background-color: white;
  border: 1px solid black;
}

.kart:hover {
  background-color: var(--accentColorWeak);
  cursor: hand;
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