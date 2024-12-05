<template>
  <!-- @vuese: analytics-section -->
  <!-- Main section for managing analytics and reports -->
  <div class="analytics-section">
    <h2>Analytics Management</h2>

    <!-- @vuese: analytics-content -->
    <!-- Container for the content of analytics management -->
    <div class="analytics-content">

      <!-- @vuese: date-filter -->
      <!-- Date filter inputs for filtering reports by date range -->
      <div v-if="showDateFilter || showDateFilter2 || showDateFilter3 || showDateFilter4" class="date-filter">
        <label>Start Date:</label>
        <input type="date" v-model="startDate" />
        <label>End Date:</label>
        <input type="date" v-model="endDate" />
      </div>

      <!-- @vuese: report-buttons -->
      <!-- Section containing buttons to generate various reports -->
      <div class="report-buttons">

        <!-- @vuese: x-report-button -->
        <!-- Button to generate the X-report -->
        <button 
          class="report-button" 
          @click="handleReport('X-report')" 
          title="The X-report provides sales counts per hour for the day."
        >
          X-report
        </button>

        <!-- @vuese: z-report-button -->
        <!-- Button to generate the Z-report -->
        <button 
          class="report-button" 
          @click="handleReport('Z-report')" 
          title="The Z-report calculates total income per hour for the last 24 hours. Only generates once per day."
        >
          Z-report
        </button>

        <!-- @vuese: sales-report-button -->
        <!-- Button to generate or filter the sales report -->
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

        <!-- @vuese: product-usage-button -->
        <!-- Button to generate or filter the product usage report -->
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

        <!-- @vuese: what-sells-together-button -->
        <!-- Button to generate or filter the report for menu items sold together -->
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

        <!-- @vuese: excess-report-button -->
        <!-- Button to generate or filter the excess inventory report -->
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

      <!-- @vuese: loading-spinner -->
      <!-- Loading spinner displayed while reports are being generated -->
      <div v-if="loading" class="loading-spinner">
        Loading...
      </div>

      <!-- @vuese: report-tables -->
      <!-- Dynamic tables to display various reports -->

      <!-- X-report table -->
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

      <!-- Z-report table -->
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

      <!-- Additional reports tables (Sales, Inventory Usage, Pairs, and Excess Reports) -->
      <!-- Each section dynamically renders a table based on its respective data -->
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
  /**
   * The AnalyticsSection component provides functionality for generating various reports, such as sales per hour, income per hour, inventory usage, and more.
   */
   name: 'AnalyticsSection',


  // @vuese
  // **Data properties**
  // All reactive properties used in the component.
  data() {
    return {
      /** @description List of all transactions fetched from the API */
      allTransactions: [],
      /** @description List of transactions filtered or displayed */
      transactions: [],
      /** @description Loading state for API calls or computations */
      loading: false,
      /** @description Mapping of menu item IDs to names */
      menuItems: {},
      /** @description Sales data grouped by hour */
      hourlySales: [],
      /** @description Income data grouped by hour */
      hourlyIncome: [],
      /** @description Sales data for specific items */
      itemSales: [],
      /** @description Report data for inventory usage */
      inventoryUsageReport: [],
      /** @description Mapping of inventory item IDs to names */
      inventoryItems: {},
      /** @description Flag indicating if the Z-report was generated */
      zReportGenerated: false,
      /** @description Start date for date-range filters */
      startDate: null,
      /** @description End date for date-range filters */
      endDate: null,
      /** @description Flags for showing or hiding date filter sections */
      showDateFilter: false,
      showDateFilter2: false,
      showDateFilter3: false,
      showDateFilter4: false,
      /** @description Report for identifying pairs of items that sell together */
      pairsReport: [],
      /** @description Report for identifying excess inventory */
      excessReport: [],
    };
  },

  // @vuese
  // **Lifecycle Hooks**
  // Automatically executed at specific component lifecycles.
  mounted() {
    this.loadTransactions();
    this.loadMenuItems();
    this.fetchInventoryItems();
  },
  // @vuese
  // **Methods**
  methods: {
    /**
     * Fetches all transactions from the API and updates the `transactions` array.
     * @returns {Promise<void>}
     */
    async loadTransactions() {
      try {
        console.log("Fetching transactions...");
        this.transactions = await fetchTransactions(); // Call the shared fetchTransactions function
      } catch (error) {
        console.error('Error fetching transactions:', error);
      }
    },

    /**
     * Fetches menu items from the API and creates a mapping of menu IDs to names.
     * @returns {Promise<void>}
     */
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

     /**
     * Calculates the number of sales for each hour in the day.
     * The hours range from 10 AM to 9 PM.
     */
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

    /**
     * Calculates the total income for each hour in the day.
     */
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


    /**
     * Fetches transactions in a date range and calculates the sales data per menu item.
     */
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

    /**
     * @method generateProductUsageReport
     * @description 
     * This method generates a product usage report based on the selected date range. It fetches the transactions, sale items, and recipe information 
     * to calculate the total inventory usage for each inventory item involved in the sales during the specified period. The report will include the 
     * inventory item name (if available) and the total amount used for each item.
     *
     * It performs the following steps:
     * 1. Validates the selected date range.
     * 2. Fetches the transactions for the given date range.
     * 3. Retrieves the sale items for each transaction.
     * 4. Counts the quantity sold for each menu item.
     * 5. Fetches the recipe for each menu item to determine which inventory items were used and in what quantities.
     * 6. Calculates the total amount of each inventory item used based on the menu item quantities.
     * 7. Generates and stores the report in the `inventoryUsageReport` array.
     *
     * If an error occurs at any point, an error message is logged to the console.
     *
     * @returns {void}
     */
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

    /**
     * @method validateDates
     * @description
     * Validates the selected start and end dates to ensure the start date is not later than the end date.
     * If the dates are reversed, this method will swap them to ensure the start date is earlier than the end date.
     * This is an internal utility method called by other methods that require valid date ranges.
     *
     * @returns {void}
     */
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

    /**
     * @method fetchInventoryItems
     * @description
     * This method fetches all inventory items from the API and maps their inventory IDs to their respective names. 
     * The data is stored in the `inventoryItems` object, where the key is the inventory ID and the value is the inventory name.
     * This method is typically used to initialize or update the list of inventory items.
     *
     * @returns {void}
     */
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

    /**
     * @method generateWhatSellsTogetherReport
     * @description
     * This method generates a "What Sells Together" report for a selected date range. It identifies pairs of menu items 
     * that were sold together in the same transaction, calculates the frequency of these pairs, and generates a report 
     * sorted by the most frequent pairs.
     * 
     * If an error occurs during data fetching or report generation, it logs the error in the console.
     *
     * @returns {void}
     */
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

    /**
     * @method generateExcessReport
     * @description
     * This method generates an "Excess Report" based on the selected date range. It identifies inventory items that 
     * have sold less than 10% of their available stock during the specified period. The report is generated by comparing 
     * the total quantity sold with the total available quantity for each item.
     * 
     * If no items have sold less than 10%, it alerts the user.
     * If an error occurs during the process, it logs the error to the console.
     *
     * @returns {void}
     */
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

    /**
 * @method handleSalesReport
 * @description
 * This method is called when the "Sales Report" option is selected. It shows the date filter section by setting 
 * the `showDateFilter` property to `true`. This method is used to initiate the process of generating a sales report 
 * by enabling the necessary date filter UI component.
 *
 * @returns {void}
 */
    async handleSalesReport() {
      // Show the date filter section only when 'Sales Report' is clicked
      this.showDateFilter = true;
      // this.handleReport('Sales-report');
    },


/**
 * @method handleProductUsage
 * @description
 * This method is called when the "Product Usage" option is selected. It shows the date filter section by setting 
 * the `showDateFilter2` property to `true`. This method is used to initiate the process of generating a product 
 * usage report by enabling the necessary date filter UI component.
 *
 * @returns {void}
 */
    async handleProuctUsage() {
      // Show the date filter section only when 'Sales Report' is clicked
      this.showDateFilter2 = true;
      // this.handleReport('Sales-report');
    },
    
    /**
 * @method handleWhatSellsTogether
 * @description
 * This method is called when the "What Sells Together" option is selected. It shows the date filter section by setting 
 * the `showDateFilter3` property to `true`. This method is used to initiate the process of generating a "What Sells 
 * Together" report by enabling the necessary date filter UI component.
 *
 * @returns {void}
 */
    async handleWhatSellsTogether() {
      this.showDateFilter3 = true;
    },


/**
 * @method handleExcessReport
 * @description
 * This method is called when the "Excess Report" option is selected. It shows the date filter section by setting 
 * the `showDateFilter4` property to `true`. This method is used to initiate the process of generating an excess report 
 * by enabling the necessary date filter UI component.
 *
 * @returns {void}
 */
    handleExcessReport() {
      this.showDateFilter4 = true;
    },

    /**
 * @method handleReport
 * @description
 * This method handles the report generation process based on the provided `reportType`. It first loads the latest 
 * transactions and then performs the corresponding report generation based on the `reportType` argument.
 * 
 * The method supports multiple report types:
 * - 'X-report': Generates an hourly sales report.
 * - 'Z-report': Generates an income per hour report, but only once per day.
 * - 'Sales-report': Generates a sales report based on menu items per hour.
 * - 'Product-usage': Generates a product usage report.
 * - 'What-sells-together': Generates a report showing items that are sold together frequently.
 * - 'Excess-report': Generates an excess report based on inventory data.
 * 
 * Each report type triggers a specific method for generating the corresponding report (e.g., `calculateSalesPerHour`, 
 * `calculateIncomePerHour`, etc.). The method also controls the visibility of the date filter sections based on 
 * the selected report.
 * 
 * After generating the report, the date filter UI components are hidden, and the loading state is set to `false`.
 *
 * @param {string} reportType - The type of report to generate (e.g., 'X-report', 'Z-report', etc.)
 * @returns {void}
 */
    async handleReport(reportType) {
      this.loading = true;
      await this.loadTransactions(); // Load the latest transactions each time a report is requested
      this.hourlySales = [];
      this.hourlyIncome = [];
      this.itemSales = [];
      this.inventoryUsageReport = [];
      this.pairsReport = [];
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
