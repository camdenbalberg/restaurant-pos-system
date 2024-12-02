<template>
  <div class="kitchen-display">
      <h1>Order List</h1>
      <div v-if="loading">Loading...</div>
      <div class="order-list">
        <div v-for="item in transactions">
            <div v-if="!item.completed" :key="item.transaction_id" class="order-box">
              <h2>Order Number: #{{ item.transaction_id }}</h2>
              <p>Time: {{ item.formatted_transaction_time }}</p>
              <div class = "contents-box">
                <p>Contents:</p>
                <ul>
                  <table>
                    <tbody>
                      <tr v-for="saleItem in item.sale_items" :key="saleItem.transaction_id">
                        <td>
                          <span v-if="isCombo(saleItem.menu_id)" style="font-weight: bold;">
                            {{ getMenuName(saleItem.menu_id) }}
                          </span>
                          <span v-else>
                            &nbsp;&nbsp;- {{ getMenuName(saleItem.menu_id) }}
                          </span>
                        </td>
                        <td>{{ saleItem.quantity }}</td>
                      </tr>
                    </tbody>
                  </table>
                </ul>
              </div>
              <button 
                :disabled="loading" 
                :class="{ 'disabled-button': loading }" 
                @click="bumpOrder(item.transaction_id)">
                Bump Order
              </button>
            </div>
          </div>
      </div>
    <div v-if="!loading && !transactions.length">No transactions available.</div>
  </div>
</template>

<script>
import shared from '../shared'

import api from '@/api';
import axios from 'axios';
import { fetchTransactions } from '../api/transactionService';
import { fetchMenuItems } from '../api/menuService';

export default {
  data() {
    return {
      transactions: [],
      loading: true,
      menuItems: {},
    };
  },
  mounted() {
    this.loadTransctions();
    this.loadMenuItems();
  },

  created() {
    this.flashScaffolding = shared.flashScaffolding
  },

  methods: {
    async loadTransctions() {
      try {
        this.transactions = await fetchTransactions();
      } catch (error) {
        console.error('Error loading transactions:', error);
      } finally {
        this.loading = false;
      }
    },

    async loadMenuItems() {
      try {
        const menuData = await fetchMenuItems();  // Fetch menu items from API
        this.menuItems = menuData.reduce((acc, item) => {
          acc[item.menu_id] = {
            name: item.menu_name,
            category: item.category
          }; // Create a mapping from menu_id to menu_name
          this.flashScaffolding();
          return acc;
        }, {});
      } catch (error) {
        console.error('Error loading menu items:', error);
      }
    },

    getMenuName(menuId) {
      // console.log(menuId);
      return this.menuItems[menuId].name || 'Unknown Item'; // Return 'Unknown Item' if the menu_id is not found
    },

    async bumpOrder(transactionId) {
      this.loading = true;
      this.transactions = this.transactions.filter(item => item.transaction_id !== transactionId);
      //process on the backend
      try {
            // Make a PATCH request to the Rails backend to toggle the completed status
            const response = await api.patch(`/transactions/${transactionId}/toggle_completed`);

            if (response.status === 200) {
                // Optionally, you can fetch the updated transactions list again
                await this.loadTransctions(); // or just update the local state if needed
            }
            this.loading = false;
            this.flashScaffolding();
        } catch (error) {
            console.error('Error bumping order:', error);
            this.loading = false;
        }
  },

  isCombo(menuId){
    const category = this.menuItems[menuId]?.category;
    console.log(menuId, this.menuItems[menuId], this.menuItems[menuId]?.name, category);

    // Display appetizers, meals, drinks, anything that isnt a subset of a meal as bold
    return category !== 'entree' && category !== 'side';
  }
},
};
</script>

<style>
h1 {
    margin: 0;
    padding-bottom: 10px; 
}

.kitchen-display {
    margin: 0;
    padding: 0; 
}

.order-list {
    background-color: white;
    border-radius: 8px;
    box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
    padding: 20px;
    display: flex;
    flex-wrap: wrap;
    justify-content: flex-start; /* Align items to the left */
    /* gap: 15px;  */
    overflow-y: auto; 
    max-height: 80vh; 
}

.order-box {
    background-color: #e2e2e2;
    border-radius: 5px;
    padding: 20px;
    width: 250px; /* width of each box */
    text-align: center;
    margin: 0 15px 15px 0;
    transition: transform 0.3s;
}

.order-box:hover {
    transform: scale(1.05); /* scaling effect on hover */
}

.disabled-button {
  background-color: gray;
  cursor: not-allowed;
}

.order-box button {
  color: white;
  background-color: darkgreen;
  padding: 0.25em;
  margin-top: 15px; /* Add margin to create space between the button and contents */
}

.order-box button:hover {
  background-color: rgb(57, 149, 57);
  color: black;
}

.contents-box {
    background-color: #f5f5f5; /* lighter background for contrast */
    padding: 10px;
    border-radius: 5px;
    margin-top: 10px;
    color: #333; /* darker text for better readability */
    font-size: 0.95em;
    padding-bottom: 0.25em;
}

.contents-box p {
  font-weight: bold;
  margin-bottom: 5px;
}

.order-box p {
  color: black;
}

.order-box h2 {
  color: black;
}

table {
    width: 100%;
    margin-top: 10px;
    border-collapse: collapse;
  }

  table td {
    padding: 8px;
    border: 1px solid #ddd;
    text-align: left;
  }
</style>
