<template>
  <div class="container">
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
      <button @click="showPopup('A La Carte', ['entree', 'sides'])">
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
    <Popup v-if="popupType" :menu_item="popupType" :cat="popupItems" @close="closePopup" />
    <footer>
      <router-link to="/">Go to Home</router-link>
    </footer>
  </div>
</template>

<script>
import Popup from '../components/Popup.vue'; // Adjust path if necessary

export default {
  name: 'Customer',
  components: {
    Popup,
  },
  data() {
    return {
      popupType: null,
      popupItems: [],
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
  },
};
</script>

<style>
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