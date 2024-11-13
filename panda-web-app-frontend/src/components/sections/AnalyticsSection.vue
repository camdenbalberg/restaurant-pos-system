<template>
  <div class="analytics-section">
    <h2>Analytics Management</h2>
    <div class="analytics-content">
      <div v-if="showDateFilter" class="date-filter">
        <label>Start Date:</label>
        <input type="date" v-model="startDate" />
        <label>End Date:</label>
        <input type="date" v-model="endDate" />
      </div>
      <div class="report-buttons">
        <button class="report-button" @click="handleReport('X-report')">X-report</button>
        <button class="report-button" @click="handleReport('Z-report')">Z-report</button>
        <button v-if="!showDateFilter" class="report-button" @click="handleSalesReport">Sales report</button>
        <button v-if="showDateFilter" class="report-button" @click="handleReport('Sales-report')">Press again</button>
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
  data() {
    return {
      transactions: [],
      loading: false,
      menuItems: {},
      hourlySales: [], 
      hourlyIncome: [],
      itemSales: [],
      zReportGenerated: false,
      startDate: null,
      endDate: null,
      showDateFilter: false,
    };
  },
  mounted() {
    this.loadTransactions();
    this.loadMenuItems();
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
      this.showDateFilter = false;
    },

    async calculateMenuItemsPerHour() { //Sales report
      if (!this.startDate || !this.endDate) {
        alert("Please select both start and end dates.");
        return;
      }
      this.loading = true;
      console.log("Fetching transactions by date range...");

      const startDate = new Date(this.startDate);
      const endDate = new Date(this.endDate);
      const menuItemCounts = {};

      // Generate an array of dates in YYYY-MM-DD format between start and end date
      const datesInRange = [];
      let currentDate = new Date(startDate);
      while (currentDate <= endDate) {
        datesInRange.push(currentDate.toISOString().split('T')[0]);
        currentDate.setDate(currentDate.getDate() + 1);
      }

      try {
        const transactionsByDate = await Promise.all(
          datesInRange.map(async date => {
            try {
              const transactions = await fetchTransactionsForDate(date);
              return transactions.length ? transactions : null; // Return null if no transactions for that date
            } catch (error) {
              if (error.response && error.response.status === 406) {
                console.warn(`No transactions for date ${date} (406 Not Acceptable)`);
                return null; // Ignore this date if a 406 error occurs
              } else {
                console.error(`Error fetching transactions for ${date}:`, error);
                return null; // Skip this date in case of an error
              }
            }
          })
        );

        // Convert the array from something like "[[],[],[]]" to "[_,_,_]"
        const allTransactions = transactionsByDate.flat().filter(Boolean);

        // Count sale items by menu_id across all transactions in the range
        allTransactions.forEach(transaction => {
          transaction.sale_items.forEach(saleItem => {
            const menuId = saleItem.menu_id;
            const quantity = saleItem.quantity;
            if (menuItemCounts[menuId]) {
              menuItemCounts[menuId] += quantity;
            } else {
              menuItemCounts[menuId] = quantity;
            }
          });
        });

        // Transform the counts into an array for display
        this.itemSales = Object.keys(menuItemCounts).map(menuId => ({
          id: this.menuItems[menuId] || menuId, // Get the name if available, otherwise use the ID
          amount: menuItemCounts[menuId]
        }));
        
      } catch (error) {
        console.error('Error fetching transactions by date range:', error);
      } finally { 
        this.loading = false;
      }
    },

    async handleSalesReport() {
      // Show the date filter section only when 'Sales Report' is clicked
      this.showDateFilter = true;
      // this.handleReport('Sales-report');
    },

    async handleReport(reportType) {
      this.loading = true;
      await this.loadTransactions(); // Load the latest transactions each time a report is requested
      this.hourlySales = [];
      this.hourlyIncome = [];
      this.itemSales = [];

      switch (reportType) {
        case 'X-report':
          console.log('Generating X-report...');
          this.calculateSalesPerHour();
          break;
        case 'Z-report':
        if (this.zReportGenerated) {
            alert('Z-report has already been generated today.');
            this.hourlyIncome = []; // Clear the table if Z-report has been generated
          } else {
            console.log('Generating Z-report...');
            this.calculateIncomePerHour();
            this.zReportGenerated = true; // Set the flag after first generation
          }
          break;
        case 'Sales-report':
          console.log('Generating Sales Report...');
          this.calculateMenuItemsPerHour();
          break;
        default:
          console.log('Unknown report type');
          break;
      }
      
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

.loading-spinner {
  margin-top: 20px;
  text-align: center;
  font-weight: bold;
  color: #555;
}
</style>
