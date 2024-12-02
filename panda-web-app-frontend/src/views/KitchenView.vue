<!-- src/views/AboutView.vue -->
<template>
  <body>
    <div>
      <Transactions />
    </div>
  </body>
</template>


<script>
 
  import Transactions from '../components/KitchenComponents.vue';
  export default { 
    name: 'HomeView',
    components: {
    Transactions,
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