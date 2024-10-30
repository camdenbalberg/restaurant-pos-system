<!-- src/views/AboutView.vue -->
<template>
  <div>
    <Transactions />
    <router-link to="/">Go to Home</router-link>
  </div>
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

<style>
  body {
      font-family: Arial, sans-serif;
      display: flex;
      justify-content: center;
      align-items: center;
      height: 100vh;
      margin: 0;
  }

  .order-list {
      background-color: white;
      border-radius: 8px;
      box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
      padding: 20px;
      display: flex;
      flex-wrap: wrap;
      justify-content: center;
      gap: 15px; /* space between boxes */
  }

  .order-box {
      background-color: #e2e2e2;
      border-radius: 5px;
      padding: 20px;
      width: 150px; /* width of each box */
      text-align: center;
      transition: transform 0.3s;
  }

  .order-box:hover {
      transform: scale(1.05); /* scaling effect on hover */
  }

  h1 {
      text-align: center;
      color: #333;
  }
</style>