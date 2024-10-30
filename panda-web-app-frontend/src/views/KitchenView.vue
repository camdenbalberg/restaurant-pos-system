<!-- src/views/AboutView.vue -->
<template>
  <div>
    <h1>Order List</h1>
    <router-link to="/">Go to Home</router-link>

    <table>
      <thead>
        <tr>
          <th>Order #</th>
          <th>Order Contents</th>
          <th>Time</th>
        </tr>
      </thead>
      <body>
        <div class="order-list">
          <!-- Implement adding new orders in the future -->
            <div class="order-box">Order #1: Burger & Fries</div>
            <div class="order-box">Order #2: Chicken Sandwich</div>
            <div class="order-box">Order #3: Veggie Wrap</div>
            <div class="order-box">Order #4: Soft Drink</div>
            <div class="order-box">Order #5: Ice Cream</div>
        </div>
      </body>
    </table>

  </div>
</template>

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