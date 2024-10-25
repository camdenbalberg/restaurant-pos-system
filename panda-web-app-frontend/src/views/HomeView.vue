<!-- src/views/HomeView.vue -->
<template>
  <div>
    <h1>Home View</h1>
    <MenuItems />
  </div>
</template>

<script>
import MenuItems from '../components/MenuItems.vue'; // Adjust path if necessary

export default {
  name: 'HomeView',
  components: {
    MenuItems,
  },
};
</script>

