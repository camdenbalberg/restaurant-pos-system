<!-- src/views/AboutView.vue -->
<template>
  <!-- Main container for the About view -->
  <body>
    <div>
      <!-- Transactions component renders the content -->
      <Transactions />
    </div>
  </body>
</template>


<script>
  /**
 * Imports the Transactions component from KitchenComponents.vue.
 * This component handles displaying or managing transactions data.
 */
  import Transactions from '../components/KitchenComponents.vue';
  export default { 
    name: 'HomeView',
    components: {
    Transactions, // Registers the Transactions component for use in the template
    },
  };
</script>

<style scoped>
  body {
      font-family: Arial, sans-serif;
      display: flex;
      justify-content: center;
      align-items: center;
      height: 100vh;
      margin: 0;
  }

  h1 {
      text-align: center;
      color: #333;
  }
</style>