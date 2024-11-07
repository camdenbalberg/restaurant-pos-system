<template>
    <div class="kitchen-display">
        <h1>Order List</h1>
        <div v-if="loading">Loading...</div>
        <ul v-if="!loading && transactions.length"></ul>
        <div class="order-list">
          <div v-for="item in transactions">
              <div v-if="!item.completed" :key="item.transaction_id" class="order-box">
                <h2>Order Number: #{{ item.transaction_id }}</h2>
                <p>Time: {{ item.formatted_transaction_time }}</p>
                <p>Contents:</p>
                <ul>
                    <li v-for="saleItem in item.sale_items" :key="saleItem.transaction_id">
                        {{ getMenuName(saleItem.menu_id) }} * {{ saleItem.quantity }}
                    </li>
                </ul>
                <button @click="bumpOrder(item.transaction_id)">Bump Order</button>
              </div>
            </div>
        </div>
      <div v-if="!loading && !transactions.length">No transactions available.</div>
    </div>
</template>

<script>
import api from '@/api';

export default {
  data() {
    return {
      transactions: [],
      loading: true,
      menuItems: {},
    };
  },
  mounted() {
    this.fetchTransactions();
    this.fetchMenuItems();
  },
  name: 'Transactions',
  methods: {
    async fetchTransactions() {
      try {
        console.log(import.meta.env.VITE_API_BACKEND_URL);
        // Current date is cast in YYYY-MM-DD format
        const today = new Date();
        const formattedDate = today.toISOString().split('T')[0]; 
        const response = await api.get(`/transactions/by_date/${formattedDate}`);
        // const response = await api.get(`/transactions/by_date/2023-10-24`); //temporary hardcoded value for testing
        this.transactions = response.data;

        // Fetch sale items for each transaction
        await Promise.all(this.transactions.map(async (transaction) => {
          const saleItemsResponse = await api.get(`/sale_items/by_transaction_id/${transaction.transaction_id}`);
          transaction.sale_items = saleItemsResponse.data;
        }));

      } catch (error) {
        console.error('Error fetching transactions:', error);
      } finally {
        this.loading = false;
      }
    },
    
    async fetchMenuItems() {
      try {
        const response = await api.get(`/menu_items`);
        this.menuItems = response.data.reduce((acc, item) => {
          console.log(item.menu_id + " : " + item.menu_name);
          acc[item.menu_id] = item.menu_name; // Create a mapping from menu_id to menu_name
          return acc;
        }, {});
      } catch (error) {
        console.error('Error fetching menu items:', error);
      }
    },

    getMenuName(menuId) {
      console.log(menuId);
      return this.menuItems[menuId] || 'Unknown Item'; // Return 'Unknown Item' if the menu_id is not found
    },

    async bumpOrder(transactionId) {
      this.transactions = this.transactions.filter(item => item.transaction_id !== transactionId);
      //process on the backend
      try {
            // Make a PATCH request to the Rails backend to toggle the completed status
            console.log("Passed 68 " + transactionId + "\n");
            const response = await api.patch(`/transactions/${transactionId}/toggle_completed`, {}, {
              headers:{
                'Content-Type': 'application/json',
              }
            });

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
      width: 250px; /* width of each box */
      text-align: center;
      transition: transform 0.3s;
  }

  .order-box:hover {
      transform: scale(1.05); /* scaling effect on hover */
  }
</style>
