<!-- src/views/AboutView.vue -->
<template>
  <div>
    <h1>Customer View</h1>
    <MenuItems />
    <router-link to="/">Go to Home</router-link>
  </div>
</template>

<script>
import MenuItems from '../components/MenuItems.vue'; // Adjust path if necessary

export default {
  name: 'Customer',
  components: {
    MenuItems,
  },
};
</script>
