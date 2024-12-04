<template>
  <div class="analytics-section">
    <h2>Analytics Management</h2>
    <div class="analytics-content">
      <div v-if="showDateFilter || showDateFilter2 || showDateFilter3 || showDateFilter4" class="date-filter">
        <label>Start Date:</label>
        <input type="date" v-model="startDate" />
        <label>End Date:</label>
        <input type="date" v-model="endDate" />
      </div>
      <div class="report-buttons">
        <button 
          class="report-button" 
          @click="handleReport('X-report')" 
          title="The X-report provides sales counts per hour for the day."
        >
          X-report
        </button>

        <button 
          class="report-button" 
          @click="handleReport('Z-report')" 
          title="The Z-report calculates total income per hour for the last 24 hours. Only generates once per day."
        >
          Z-report
        </button>

        <button 
          v-if="!showDateFilter" 
          class="report-button" 
          @click="handleSalesReport" 
          title="Click to filter and view the sales report by menu items within a date range."
        >
          Sales report
        </button>
        <button 
          v-if="showDateFilter" 
          class="report-button press-again" 
          @click="handleReport('Sales-report')" 
          title="Press again to generate the sales report based on selected dates."
        >
          Press again
        </button>

        <button 
          v-if="!showDateFilter2" 
          class="report-button" 
          @click="handleProuctUsage" 
          title="Given a time window, display the number of each inventory item used during that time period."
        >
          Product Usage
        </button>
        <button 
          v-if="showDateFilter2" 
          class="report-button press-again" 
          @click="handleReport('Product-usage')" 
          title="Press again to generate."
        >
          Press again
        </button>

        <button 
          v-if="!showDateFilter3" 
          class="report-button" 
          @click="handleWhatSellsTogether" 
          title="Find pairs of menu items that sell together within a date range."
        >
          What Sells Together
        </button>
        <button 
          v-if="showDateFilter3" 
          class="report-button press-again" 
          @click="handleReport('What-sells-together')" 
          title="Press again to generate the report."
        >
          Press again
        </button>

        <button 
          v-if="!showDateFilter4" 
          class="report-button" 
          @click="handleExcessReport" 
          title="Excess report displays inventory items that sold less than 10% of their quantity between the selected dates."
        >
          Excess Report
        </button>
        <button 
          v-if="showDateFilter4" 
          class="report-button press-again" 
          @click="handleReport('Excess-report')" 
          title="Press again to generate the excess report based on selected dates."
        >
          Press again
        </button>
      </div>
      
      <div v-if="loading" class="loading-spinner">
        Loading...
      </div>

      <!-- X-report Table -->
      <div v-if="hourlySales.length">
        <table class="report-table">
          <thead>
            <tr>
              <th>Hour</th>
              <th>Sales Count</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="entry in hourlySales" :key="entry.hour">
              <td>{{ entry.hour }}:00</td>
              <td>{{ entry.count }}</td>
            </tr>
          </tbody>
        </table>
      </div>

      <!-- Z-report Table -->
      <div v-if="hourlyIncome.length">
        <table class="report-table">
          <thead>
            <tr>
              <th>Hour</th>
              <th>Sales Count</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="entry in hourlyIncome" :key="entry.hour">
              <td>{{ entry.hour }}:00</td>
              <td>{{ entry.amount }}</td>
            </tr>
          </tbody>
        </table>
      </div>

      <!-- Sales Report Table -->
      <div v-if="itemSales.length">
        <table class="report-table">
          <thead>
            <tr>
              <th>Menu Item</th>
              <th>Sale Count</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="entry in itemSales" :key="entry.id">
              <td>{{ entry.id }}</td>
              <td>{{ entry.amount }}</td>
            </tr>
          </tbody>
        </table>
      </div>

      <!-- Inventory Usage Report Table -->
      <div v-if="inventoryUsageReport.length">
        <table class="report-table">
          <thead>
            <tr>
              <th>Inventory Item</th>
              <th>Amount Used</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="entry in inventoryUsageReport" :key="entry.id">
              <td>{{ entry.id }}</td>
              <td>{{ entry.amount }}</td>
            </tr>
          </tbody>
        </table>
      </div>

      <!-- What sells together table -->
      <div v-if="pairsReport.length">
        <table class="report-table">
          <thead>
            <tr>
              <th>Menu Item Pair</th>
              <th>Frequency</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="pair in pairsReport" :key="pair.id">
              <td>{{ pair.items }}</td>
              <td>{{ pair.frequency }}</td>
            </tr>
          </tbody>
        </table>
      </div>

      <!-- Excess Report Table -->
      <div v-if="excessReport.length">
        <table class="report-table">
          <thead>
            <tr>
              <th>Inventory Item</th>
              <th>Quantity Sold</th>
              <th>Total Quantity</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="entry in excessReport" :key="entry.id">
              <td>{{ entry.id }}</td>
              <td>{{ entry.sold }}</td>
              <td>{{ entry.total }}</td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</template>

<script>
import api from '@/api';
import axios from 'axios';
import { fetchTransactions } from '../../api/transactionService';
import { fetchTransactionsForDate } from '../../api/transactionService';
import { fetchMenuItems } from '../../api/menuService';

export default {
  name: 'AnalyticsSection',

  // @vuese
  // Initial fields.
  data() {
    return {
      allTransactions: [],
      transactions: [],
      loading: false,
      menuItems: {},
      hourlySales: [], 
      hourlyIncome: [],
      itemSales: [],
      inventoryUsageReport: [],
      inventoryItems: {},
      zReportGenerated: false,
      startDate: null,
      endDate: null,
      showDateFilter: false,
      showDateFilter2: false,
      pairsReport: [],
      showDateFilter3: false,
      excessReport: [],
      showDateFilter4: false,
    };
  },
  mounted() {
    this.loadTransactions();
    this.loadMenuItems();
    this.fetchInventoryItems();
  },
  methods: {
    async loadTransactions() {
      try {
        console.log("Fetching transactions...");
        this.transactions = await fetchTransactions(); // Call the shared fetchTransactions function
      } catch (error) {
        console.error('Error fetching transactions:', error);
      }
    },

    async loadMenuItems() {
      try {
        const menuData = await fetchMenuItems();  // Fetch menu items from API
        this.menuItems = menuData.reduce((acc, item) => {
          acc[item.menu_id] = item.menu_name; // Create a mapping from menu_id to menu_name
          return acc;
        }, {});
      } catch (error) {
        console.error('Error loading menu items:', error);
      }
    },

    calculateSalesPerHour() {// X-report
      const salesCount = Array(12).fill(0); // 12 hours from 10 AM to 9 PM

      this.transactions.forEach(transaction => {
        // Extract the hour part from "HH:MM" format
        const [hourString] = transaction.formatted_transaction_time .split(":");
        const hour = parseInt(hourString, 10); // Convert to integer

        if (!isNaN(hour) && hour >= 10 && hour <= 21) {
          // Map hour to index (10AM = 0, 11AM = 1, ..., 9PM = 11)
          const hourIndex = hour - 10;
          salesCount[hourIndex] += 1;
        } else {
          console.error("Invalid or out-of-range hour for formatted_transaction_time :", transaction.formatted_transaction_time );
        }
      });

      // Set the result to hourlySales for table binding
      this.hourlySales = salesCount.map((count, index) => ({
        hour: 10 + index, // Convert index back to actual hour (10:00 - 21:00)
        count,
      }));
      this.loading = false;
    },

    calculateIncomePerHour() { //Z-report
      const incomeCount = Array(12).fill(0);

      this.transactions.forEach(transaction => {
        // Extract the hour part from "HH:MM" format
        const [hourString] = transaction.formatted_transaction_time .split(":");
        const hour = parseInt(hourString, 10); // Convert to integer

        if (!isNaN(hour) && hour >= 10 && hour <= 21) {
          // Map hour to index (10AM = 0, 11AM = 1, ..., 9PM = 11)
          const hourIndex = hour - 10;
          incomeCount[hourIndex] += transaction.total_price;
        } else {
          console.error("Invalid or out-of-range hour for formatted_transaction_time :", transaction.formatted_transaction_time );
        }
      });

      this.hourlyIncome = incomeCount.map((amount, index) => ({
        hour: 10 + index,
        amount,
      }));
      this.loading = false;
    },

    async calculateMenuItemsPerHour() { //Sales report
      this.validateDates();

      if (!this.startDate || !this.endDate) {
        alert("Please select both start and end dates.");
        return;
      }
      this.loading = true;
      console.log("Fetching transactions by date range...");

      try {
        const response = await api.get(`transactions/by_date_range?start_date=${this.startDate}&end_date=${this.endDate}`);
        if (!response || !response.data) {
          throw new Error(`Error fetching transactions: ${response.statusText}`);
        }
        console.log(response.data);

        this.allTransactions = response.data;
        console.log('Type of allTransactions:', typeof this.allTransactions, Array.isArray(this.allTransactions), this.allTransactions);
        
        const transactionIds = this.allTransactions.map(transaction => transaction.transaction_id);

        // Fetch sale items for all transactions in one request
        const saleItemsResponse = await api.post('sale_items/by_transaction_ids', { transaction_ids: transactionIds });
        
        const menuItemCounts = {};
        const saleItemsForTransactions = saleItemsResponse.data;

    saleItemsForTransactions.forEach(sale_item => {
          const menuId = sale_item.menu_id;
          const quantity = sale_item.quantity;
          if (menuItemCounts[menuId]) {
            menuItemCounts[menuId] += quantity;
          } else {
            menuItemCounts[menuId] = quantity;
          }
        });

    this.itemSales = Object.keys(menuItemCounts).map(menuId => ({
      id: this.menuItems[menuId] || menuId, // Get the name if available, otherwise use the ID
      amount: menuItemCounts[menuId]
    }));
        console.log('Item sales: ', this.itemSales);
      } catch (error) {
        console.error('Error fetching transactions by date range:', error);
      } finally { 
        this.loading = false;
      }
    },

    async generateProductUsageReport() {
      this.validateDates();

      if (!this.startDate || !this.endDate) {
        alert("Please select both start and end dates.");
        return;
      }
      this.loading = true;
      console.log("Fetching transactions by date range...");

      try {
        const response = await api.get(`transactions/by_date_range?start_date=${this.startDate}&end_date=${this.endDate}`);
        if (!response || !response.data) {
          throw new Error(`Error fetching transactions: ${response.statusText}`);
        }
        
        this.allTransactions = response.data;
        
        const transactionIds = this.allTransactions.map(transaction => transaction.transaction_id);

        // Fetch sale items for all transactions in one request
        const saleItemsResponse = await api.post('sale_items/by_transaction_ids', { transaction_ids: transactionIds });
        
        const menuItemCounts = {};
        const saleItemsForTransactions = saleItemsResponse.data;

        saleItemsForTransactions.forEach(sale_item => {
          const menuId = sale_item.menu_id;
          const quantity = sale_item.quantity;
          if (menuItemCounts[menuId]) {
            menuItemCounts[menuId] += quantity;
          } else {
            menuItemCounts[menuId] = quantity;
          }
        });
        
        const inventoryUsage = {};

        for (const menuId of Object.keys(menuItemCounts)) {
          const recipeResponse = await api.get(`recipes/${menuId}`);
          const recipes = recipeResponse.data;

          // Multiply the menu item count by the inventory quantities in the recipes
          recipes.forEach(recipe => {
            const inventoryId = recipe.inv_id;
            const recipeQuantity = recipe.quantity;
            const totalUsed = menuItemCounts[menuId] * recipeQuantity;

            if (inventoryUsage[inventoryId]) {
              inventoryUsage[inventoryId] += totalUsed;
            } else {
              inventoryUsage[inventoryId] = totalUsed;
            }
          });
        }
        
        this.inventoryUsageReport = Object.keys(inventoryUsage).map(invId => ({
          id: this.inventoryItems[invId] || invId,
          amount: inventoryUsage[invId]
        }));
        console.log('Inv usage: ', this.inventoryUsageReport);
      } catch (error) {
        console.error('Error fetching transactions by date range:', error);
      } finally { 
        this.loading = false;
      }
    },

    validateDates() {
        if (this.startDate && this.endDate) {
          const start = new Date(this.startDate);
          const end = new Date(this.endDate);
          if (start > end) {
            // Reverse the dates
            const temp = this.startDate;
            this.startDate = this.endDate;
            this.endDate = temp;
          }
        }
    },

    async fetchInventoryItems() {
      this.loading = true;
      try {
        const response = await api.get('/inventory_items');
        const inventoryData = response.data;

        // Map inventory IDs to their names
        this.inventoryItems = inventoryData.reduce((acc, item) => {
          acc[item.inv_id] = item.inv_name;
          return acc;
        }, {});
        console.log("Inv: ", this.inventoryItems);
      } catch (error) {
        console.error('Error fetching inventory items:', error);
      } finally {
        this.loading = false;
      }
    },

    async generateWhatSellsTogetherReport() {
      this.validateDates();

      if (!this.startDate || !this.endDate) {
        alert("Please select both start and end dates.");
        return;
      }
      this.loading = true;

      try {
        // Fetch transactions within the date range
        const response = await api.get(`transactions/by_date_range?start_date=${this.startDate}&end_date=${this.endDate}`);
        if (!response || !response.data) {
          throw new Error(`Error fetching transactions: ${response.statusText}`);
        }
        const transactions = response.data;

        // Fetch sale items for all transactions
        const transactionIds = transactions.map(transaction => transaction.transaction_id);
        const saleItemsResponse = await api.post('sale_items/by_transaction_ids', { transaction_ids: transactionIds });
        const saleItems = saleItemsResponse.data;

        // Group sale items by transaction ID
        const groupedItems = {};
        saleItems.forEach(item => {
          if (!groupedItems[item.transaction_id]) {
            groupedItems[item.transaction_id] = [];
          }
          groupedItems[item.transaction_id].push(item.menu_id);
        });

        // Generate pairs and their frequencies
        const pairCounts = {};
        Object.values(groupedItems).forEach(items => {
          items.sort(); // Sort items to ensure consistent pair ordering
          for (let i = 0; i < items.length; i++) {
            for (let j = i + 1; j < items.length; j++) {
              const pair = `${items[i]}-${items[j]}`;
              pairCounts[pair] = (pairCounts[pair] || 0) + 1;
            }
          }
        });

        // Convert pair counts to an array and sort by frequency
        this.pairsReport = Object.keys(pairCounts)
          .map(pair => {
            const [menuId1, menuId2] = pair.split('-');
            return {
              items: `${this.menuItems[menuId1] || menuId1} & ${this.menuItems[menuId2] || menuId2}`,
              frequency: pairCounts[pair],
            };
          })
          .sort((a, b) => b.frequency - a.frequency); // Sort by descending frequency

      } catch (error) {
        console.error('Error generating What Sells Together report:', error);
      } finally {
        this.loading = false;
      }
    },

    async generateExcessReport() {
      this.validateDates();

      if (!this.startDate || !this.endDate) {
        alert("Please select both start and end dates.");
        return;
      }
      this.loading = true;
      console.log("Generating Excess Report...");

      try {
        const response = await api.get(`transactions/by_date_range?start_date=${this.startDate}&end_date=${this.endDate}`);
        if (!response || !response.data) {
          throw new Error(`Error fetching transactions: ${response.statusText}`);
        }

        const allTransactions = response.data;
        const transactionIds = allTransactions.map(transaction => transaction.transaction_id);

        const saleItemsResponse = await api.post('sale_items/by_transaction_ids', { transaction_ids: transactionIds });
        const saleItemsForTransactions = saleItemsResponse.data;

        const itemQuantities = {};

        saleItemsForTransactions.forEach(sale_item => {
          const invId = sale_item.inv_id;
          const quantitySold = sale_item.quantity;

          if (itemQuantities[invId]) {
            itemQuantities[invId].sold += quantitySold;
          } else {
            itemQuantities[invId] = { sold: quantitySold, total: 0 };
          }
        });

        const inventoryData = await api.get('/inventory_items');
        const inventoryDataArray = inventoryData.data;

        inventoryDataArray.forEach(item => {
          if (itemQuantities[item.inv_id]) {
            itemQuantities[item.inv_id].total = item.total_quantity;
          }
        });

        this.excessReport = Object.keys(itemQuantities).map(invId => {
          const item = itemQuantities[invId];
          if (item.sold / item.total < 0.1) { // Sold less than 10%
            return {
              id: this.inventoryItems[invId] || invId,
              sold: item.sold,
              total: item.total,
            };
          }
        }).filter(item => item); // Remove any null values

        console.log('Excess Report: ', this.excessReport);
      } catch (error) {
        console.error('Error generating excess report:', error);
      } finally {
        if(this.excessReport.length === 0){
          alert("No inventory items sold less than 10% of their quantity during this timeframe")
        }
        this.loading = false;
      }
    },


    async handleSalesReport() {
      // Show the date filter section only when 'Sales Report' is clicked
      this.showDateFilter = true;
      // this.handleReport('Sales-report');
    },

    async handleProuctUsage() {
      // Show the date filter section only when 'Sales Report' is clicked
      this.showDateFilter2 = true;
      // this.handleReport('Sales-report');
    },
    
    async handleWhatSellsTogether() {
      this.showDateFilter3 = true;
    },

    handleExcessReport() {
      this.showDateFilter4 = true;
    },

    async handleReport(reportType) {
      this.loading = true;
      await this.loadTransactions(); // Load the latest transactions each time a report is requested
      this.hourlySales = [];
      this.hourlyIncome = [];
      this.itemSales = [];
      this.inventoryUsageReport = [];
      this.excessReport = [];

      switch (reportType) {
        case 'X-report':
          console.log('Generating X-report...');
          await this.calculateSalesPerHour();
          break;
        case 'Z-report':
        if (this.zReportGenerated) {
            alert('Z-report has already been generated today.');
            this.hourlyIncome = []; // Clear the table if Z-report has been generated
          } else {
            console.log('Generating Z-report...');
            await this.calculateIncomePerHour();
            this.zReportGenerated = true; // Set the flag after first generation
          }
          break;
        case 'Sales-report':
          console.log('Generating Sales Report...');
          await this.calculateMenuItemsPerHour();
          break;
        case 'Product-usage':
          console.log('Generating Product Usage Report.');
          await this.generateProductUsageReport();
          break;
        case 'What-sells-together':
          console.log('Generating What Sells Together Report...');
          await this.generateWhatSellsTogetherReport();
          break;
        case 'Excess-report':
          console.log('Generating Excess Report...');
          await this.generateExcessReport();
          break;
        default:
          console.log('Unknown report type');
          this.showDateFilter = false;
          this.showDateFilter2 = false;
          this.showDateFilter3 = false;
          this.showDateFilter4 = false;
          this.loading = false;
          break;
      }
      this.showDateFilter = false;
      this.showDateFilter2 = false;
      this.showDateFilter3 = false;
      this.showDateFilter4 = false;
      this.loading = false;
    }
  }
};
</script>

<style scoped>
.analytics-section {
  padding: 2rem;
  background-color: white;
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.report-table {
  width: 100%;
  margin-top: 20px;
  border-collapse: collapse;
}

.report-table th,
.report-table td {
  padding: 10px;
  border: 1px solid #ddd;
  text-align: center;
}

.report-table th {
  background-color: #f4f4f4;
}

.report-buttons {
  display: flex;
  justify-content: center; /* Center horizontally */
  align-items: center;
  flex-wrap: wrap;
  gap: 15px;
  margin-top: 20px;
}
.report-button {
  color: black;
  background-color: aliceblue;
  border: 2px solid black;
  width: 250px;
  padding: 20px;
  font-size: 16px;
  cursor: pointer;
  border-radius: 5px;
}

.report-button:hover {
  background-color: #e0f7ff; 
}

.report-button.press-again {
  background-color: #ffebcd; 
  color: #333; 
  font-weight: bold; 
  border: 2px solid #cc9900; 
}

.report-button.special-button:hover {
  background-color: #ffd700; /* Goldenrod for hover effect */
}

.loading-spinner {
  margin-top: 20px;
  text-align: center;
  font-weight: bold;
  color: #555;
}
</style>
