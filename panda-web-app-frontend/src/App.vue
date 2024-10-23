<template>
  <div id="app">
    <MenuItems />
  </div>
</template>

<script>
import MenuItems from './components/MenuItems.vue';

export default {
  components: {
    MenuItems,
  },
};
</script>

<style>
/* Global styles */
body {
  font-family: Arial, sans-serif;
  background-color: #f4f4f4;
  color: #333;
}
</style>

