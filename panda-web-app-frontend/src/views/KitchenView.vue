<!-- src/views/AboutView.vue -->
<template>
  <div>
    <h1>Order List</h1>
    <router-link to="/">Go to Home</router-link>

    <div>
      <input v-model="newOrder" placeholder="Enter new order" />
      <button @click="addOrder">Add Order</button>
    </div>

    <div class="order-list">
      <div 
        class="order-box" 
        v-for="(order, index) in orders" 
        :key="index"
      >
        {{ order }}
      </div>
    </div>
  </div>
</template>


<script>
export default {
  data() {
    return {
      newOrder: '',
      orders: [
        'Order #1: Burger & Fries',
        'Order #2: Chicken Sandwich',
        'Order #3: Veggie Wrap',
        'Order #4: Soft Drink',
        'Order #5: Ice Cream'
      ]
    };
  },
  methods: {
    addOrder() {
      if (this.newOrder) {
        this.orders.push(this.newOrder);
        this.newOrder = ''; // Clear the input field
      }
    }
  }
};
</script>

<style>
  body {
      font-family: Arial, sans-serif;
      background-color: #f4f4f4;
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