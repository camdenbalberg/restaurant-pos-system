<template>
  <div class="analytics-section">
    <h2>Analytics Management</h2>
    <div class="analytics-content">
      <div class="report-buttons">
        <button class="report-button" @click="handleReport('X-report')">X-report</button>
        <button class="report-button" @click="handleReport('Z-report')">Z-report</button>
        <button class="report-button" @click="handleReport('Sales-report')">Sales Report</button>
      </div>
      
      <!-- Table for displaying the sales per hour -->
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
    </div>
  </div>
</template>

<script>
import api from '@/api';
import axios from 'axios';
import { fetchTransactions } from '../../api/transactionService';
import { fetchMenuItems } from '../../api/menuService';

export default {
  name: 'AnalyticsSection',
  data() {
    return {
      transactions: [],
      loading: true,
      menuItems: {},
      hourlySales: [], // Store sales count per hour
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
        this.calculateSalesPerHour(); // Calculate sales per hour after loading transactions
        
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

    calculateSalesPerHour() {
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
    },

    async handleReport(reportType) {
      // Handle the report generation
      switch (reportType) {
        case 'X-report':
          console.log('Generating X-report...');
          await this.loadTransactions(); // Re-fetch transactions and calculate sales per hour
          break;
        case 'Z-report':
          console.log('Generating Z-report...');
          break;
        case 'Sales-report':
          console.log('Generating Sales Report...');
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
</style>
