<!-- src/views/AboutView.vue -->
<template>
  <div>
    <button @click="showPopup('bowl')">Bowl</button>
    <button @click="showPopup('plate')">Plate</button>
    <button @click="showPopup('biggerPlate')">Bigger Plate</button>
    <button @click="showPopup('entree')">A La Carte Entree</button>
    <button @click="showPopup('side')">A La Carte Side</button>
    <router-link to="/">Go to Home</router-link>

    <div v-if="popupType" class="popup">
      <p>{{ popupType }} selected</p>
      <button @click="closePopup">Confirm</button>
    </div>
  </div>
</template>

<script>
import MenuItem from '../components/MenuItem.vue'; // Adjust path if necessary
import Popup from '../components/Popup.vue'; // Adjust path if necessary

export default {
  name: 'Customer',
  components: {
    MenuItem,
  },
  data() {
    return {
      popupType: null,
    };
  },
  methods: {
    showPopup(type) {
      this.popupType = type;
    },
    closePopup() {
      this.popupType = null;
    },
  },
};
</script>
