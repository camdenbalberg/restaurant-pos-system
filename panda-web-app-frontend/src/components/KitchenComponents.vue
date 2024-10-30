<template>
    <div class="kitchen-display">
        <h1>Order List</h1>
        <div v-if="loading">Loading...</div>
        <ul v-if="!loading && transactions.length"></ul>
        <div class="order-list">
            <div v-for="item in transactions" :key="item.transaction_id" class="order-box">
                <h2>Order Number: #{{ item.transaction_id }}</h2>
                <p>Time: {{ formatTime(item.transaction_time) }}</p>
                <p>Contents: (Date until I fix it) {{ item.transaction_date }}</p>
            </div>
        </div>
      <div v-if="!loading && !transactions.length">No transactions available.</div>
    </div>
</template>

<script>
import axios from 'axios';

export default {
  data() {
    return {
      transactions: [],
      loading: true,
    };
  },
  mounted() {
    this.fetchTransactions();
  },
  name: 'Transactions',
  methods: {
    async fetchTransactions() {
      try {
        // Example usage of env var
        console.log(import.meta.env.VITE_API_BACKEND_URL);
        const response = await axios.get('/api/v1/transactions/by_date/2023-09-24');
        this.transactions = response.data;
      } catch (error) {
        console.error('Error fetching transactions:', error);
      } finally {
        this.loading = false;
      }
    },
    formatTime(isoTime) {
      const date = new Date(isoTime);
      return new Intl.DateTimeFormat('en-GB', {
        hour: '2-digit',
        minute: '2-digit',
        hour12: false,
      }).format(date);
    },
  },
};
</script>

<style>
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
</style>