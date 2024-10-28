<!-- src/views/AboutView.vue -->
<template>
  <div>
    <h1>Kitchen View</h1>
    <router-link to="/">Go to Home</router-link>

    <table>
      <thead>
        <tr>
          <th>Order #</th>
          <th>Order Contents</th>
          <th>Time</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="order in orders" :key="order.id">
          <td>{{ order.id }}</td>
          <td>{{ order.contents }}</td>
          <td>{{ order.time }}</td>
        </tr>
      </tbody>
    </table>

  </div>
</template>

<script>
export default {
  data() {
    return {
      orders: [
        { id: 1, contents: 'Pizza', time: '12:00 PM' },
        { id: 2, contents: 'Burger', time: '12:15 PM' },
        { id: 3, contents: 'Salad', time: '12:30 PM' },
        // Add more orders as needed
      ],
    };
  },
};
</script>


<style>
table {
  width: 100%;
  border-collapse: collapse;
}

th, td {
  border: 1px solid #ddd;
  padding: 8px;
  text-align: left;
  color: white;
}

th {
  background-color: black;
}
</style>