<template>
    <div class="kitchen-display">
        <h1>Order List</h1>
        <div v-if="loading">Loading...</div>
        <ul v-if="!loading && transactions.length"></ul>
        <div class="order-list">
          <div v-for="item in transactions" :key="item.transaction_id" class="order-box">
                <h2>Order Number: #{{ item.transaction_id }}</h2>
                <p>Time: {{ item.formatted_transaction_time }}</p>
                <p>Contents:</p>
                <ul>
                    <li v-for="saleItem in item.sale_items" :key="saleItem.transaction_id">
                        {{ saleItem.menu_id }} * {{ saleItem.quantity }} Cost: $ {{ saleItem.price }}
                    </li>
                </ul>
                <button @click="bumpOrder(item.transaction_id)">Bump Order</button>
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
        console.log(import.meta.env.VITE_API_BACKEND_URL);
        // Current date is cast in YYYY-MM-DD format
        // const today = new Date();
        // const formattedDate = today.toISOString().split('T')[0]; 
        // const response = await axios.get(`/api/v1/transactions/by_date/${formattedDate}`);
        const response = await axios.get(`/api/v1/transactions/by_date/2023-09-24`); //temporary hardcoded value for testing
        this.transactions = response.data;

        // Fetch sale items for each transaction
        await Promise.all(this.transactions.map(async (transaction) => {
          const saleItemsResponse = await axios.get(`/api/v1/sale_items/by_transaction_id/${transaction.transaction_id}`);
          transaction.sale_items = saleItemsResponse.data;
        }));

      } catch (error) {
        console.error('Error fetching transactions:', error);
      } finally {
        this.loading = false;
      }
    },
    
    async bumpOrder(transactionId) {
      this.transactions = this.transactions.filter(item => item.transaction_id !== transactionId);
      //process on the backend
      try {
            // Make a PATCH request to the Rails backend to toggle the completed status
            const response = await axios.patch(`/transactions/${transactionId}/toggle_completed`);

            if (response.status === 200) {
                // Optionally, you can fetch the updated transactions list again
                await this.fetchTransactions(); // or just update the local state if needed
            }
        } catch (error) {
            console.error('Error bumping order:', error);
        }

    }
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