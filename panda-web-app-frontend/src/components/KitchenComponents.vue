<template>
  <div class="kitchen-display">
    <h1>Order List</h1>

    <!-- @vuese: loading -->
    <!-- Displays a loading message when data is being fetched -->
    <div v-if="loading">Loading...</div>

    <!-- @vuese: order-list -->
    <!-- Displays the list of transactions -->
    <div class="order-list">
      <!-- @vuese: transaction -->
      <!-- Loops through each transaction and shows incomplete orders -->
      <div v-for="item in transactions" :key="item.transaction_id">
        <div v-if="!item.completed" class="order-box">
          <!-- @vuese: order-details -->
          <!-- Displays details of an individual order -->
          <h2>Order Number: #{{ item.transaction_id }}</h2>
          <p>Time: {{ item.formatted_transaction_time }}</p>

          <!-- @vuese: order-contents -->
          <!-- Displays the contents of the order -->
          <div class="contents-box">
            <p>Contents:</p>
            <ul>
              <table>
                <tbody>
                  <!-- @vuese: sale-item -->
                  <!-- Loops through sale items within the order -->
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

          <!-- @vuese: bump-order-button -->
          <!-- Button to mark the order as completed -->
          <button 
            :disabled="loading" 
            :class="{ 'disabled-button': loading }" 
            @click="bumpOrder(item.transaction_id)">
            Bump Order
          </button>
        </div>
      </div>
    </div>

    <!-- @vuese: no-transactions -->
    <!-- Displays a message when no transactions are available -->
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
  // @vuese: KitchenDisplay
  // Displays the kitchen orders and allows the user to mark them as completed.
  name: "KitchenDisplay",

  // @vuese
  // Data properties used within the component
  data() {
    return {
      transactions: [],
      loading: true,
      menuItems: {},
      inventoryItems: {},
    };
  },

  // @vuese: mounted
  // Lifecycle hook: loads transactions and menu items when the component is mounted.
  mounted() {
    this.loadTransctions();
    this.loadMenuItems();
    this.fetchInventoryItems();
  },

  // @vuese
  // Enable flash scaffolding functionality from a shared js file.
  created() {
    this.flashScaffolding = shared.flashScaffolding
  },

  methods: {
    /**
     * @vuese: loadTransctions
     * Fetches the list of transactions from the API.
     */
    async loadTransctions() {
      try {
        this.transactions = await fetchTransactions();
      } catch (error) {
        console.error('Error loading transactions:', error);
      } finally {
        this.loading = false;
      }
    },

    /**
     * @vuese: loadMenuItems
     * Fetches the list of menu items and maps them by their menu ID.
     */
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
    /**
 * @function fetchInventoryItems
 * @description Retrieves inventory items from the backend and maps them for quick access.
 * 
 * @async
 * @example
 * await fetchInventoryItems();
 * 
 * @details
 * - Sends a GET request to the `/inventory_items` endpoint.
 * - Transforms the response data into an object where each key is the `inv_id` and the value is the corresponding `inv_name`.
 * - Stores the transformed data in the `inventoryItems` property.
 * - Sets a loading state (`this.loading`) to `true` during the fetch and resets it after completion.
 * 
 * @throws Will log errors if:
 * - The API call fails (e.g., network issues or server errors).
 * 
 * @returns {void}
 */
    async fetchInventoryItems() {
      this.loading = true;
      try {
        const response = await api.get('/inventory_items');
        const inventoryData = response.data;
        this.inventoryItems = inventoryData.reduce((acc, item) => {
          acc[item.inv_id] = item.inv_name;
          return acc;
        }, {});
        console.log("Inv: ", this.inventoryItems);
      } catch (error) {
        console.error('Error fetching inventory items:', error);
      }
    },

/**
     * @vuese: getMenuName
     * Retrieves the name of a menu item by its ID.
     * @param {Number} menuId - The ID of the menu item.
     * @returns {String} - The name of the menu item.
     */
    getMenuName(menuId) {
      // console.log(menuId);
      return this.menuItems[menuId].name || 'Unknown Item'; // Return 'Unknown Item' if the menu_id is not found
    },

    /**
     * @vuese: bumpOrder
     * Marks an order as completed and removes it from the list.
     * @param {Number} transactionId - The ID of the transaction to complete.
     */
    async bumpOrder(transactionId) {
      this.loading = true;
      await this.takeFromInventory(transactionId);
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
/**
 * @function takeFromInventory
 * @description Adjusts inventory stock based on a specific transaction's sale items.
 * 
 * @param {string} transactionId - The ID of the transaction used to identify sale items.
 * 
 * @async
 * @example
 * await takeFromInventory('transaction123');
 * 
 * @details
 * - This method retrieves a transaction by `transactionId` from the `transactions` array.
 * - It aggregates the quantities of items sold based on their `menu_id`.
 * - It fetches recipe details for each menu item using the `menu_id` and calculates the total amount of ingredients used.
 * - The inventory stock is updated by sending a PATCH request to the backend for each `inventory_item`.
 * 
 * @throws Will log errors if:
 * - The `transactionId` does not match any transactions in the `transactions` array.
 * - The API calls fail (e.g., `GET recipes/{menuId}` or `PATCH inventory_items/{inventoryId}/update_stock`).
 * 
 * @returns {void}
 */
  async takeFromInventory(transactionId) {
    try {
      console.log("Taking from inventory: ", this.transactions, transactionId);
      // Filter transactions to find the correct one by transaction_id
      const transaction = this.transactions.find(item => item.transaction_id === transactionId);
      
      // Ensure sale_items exists on the transaction
      if (transaction && transaction.sale_items) {
        const menuItemCounts = {};

        // Aggregate quantities of the sale items
        transaction.sale_items.forEach(saleItem => {
          const menuId = saleItem.menu_id;
          const quantity = saleItem.quantity;
          menuItemCounts[menuId] = (menuItemCounts[menuId] || 0) + quantity;
        });

        // Loop through all items to adjust the inventory
        for (const menuId of Object.keys(menuItemCounts)) {
          const recipeResponse = await api.get(`recipes/${menuId}`);
          const recipes = recipeResponse.data;

          // Loop through the recipes and subtract the quantity from inventory
          for (const recipe of recipes) {
            const inventoryId = recipe.inv_id;
            const recipeQuantity = recipe.quantity;
            const totalUsed = menuItemCounts[menuId] * recipeQuantity;
            console.log(inventoryId, recipeQuantity, totalUsed);
            // Update the inventory stock in the backend
            await api.patch(`/inventory_items/${inventoryId}/update_stock`, {
              quantity_used: totalUsed
            });
          }
        }
      } else {
        console.log("Transaction not found or no sale items available.");
      }
    } catch (error) {
      console.error('Error subtracting inventory:', error);
    }

  },

/**
     * @vuese: isCombo
     * Determines if a menu item is part of a combo.
     * @param {Number} menuId - The ID of the menu item.
     * @returns {Boolean} - True if the menu item is a combo, false otherwise.
     */
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
