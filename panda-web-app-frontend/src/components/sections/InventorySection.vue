<template>
  <div class="inventory-section">
    <!-- Header Section -->
    <div class="header-section">
      <h2>Inventory Management</h2>
      <button 
        @click="showAddForm = true" 
        class="add-button"
      >
        Add Inventory Item
      </button>
    </div>

    <!-- Inventory Stats -->
    <div class="inventory-stats">
      <div class="stat-card">
        <h4>Total Items</h4>
        <p>{{ inventoryItems.length }}</p>
      </div>
      <div class="stat-card">
        <h4>Low Stock Items</h4>
        <p>{{ lowStockItems }}</p>
      </div>
    </div>

    <!-- Loading Spinner -->
    <div v-if="loading" class="loading-spinner">
      Loading...
    </div>

    <!-- Inventory Table -->
    <div class="table-container">
      <table class="inventory-table">
        <thead>
          <tr>
            <!-- Static Column Headers -->
            <th @click="sortTable('inv_name')" :class="{ sortable: true, sorted: sortBy === 'inv_name' }">
              Name
              <span class="sort-indicator">
                ↕
                <span v-if="sortBy === 'inv_name'">
                  {{ sortDirection === 'asc' ? '▲' : '▼' }}
                </span>
              </span>
            </th>
            <th @click="sortTable('stock')" :class="{ sortable: true, sorted: sortBy === 'stock' }">
              Current Stock
              <span class="sort-indicator">
                ↕
                <span v-if="sortBy === 'stock'">
                  {{ sortDirection === 'asc' ? '▲' : '▼' }}
                </span>
              </span>
            </th>
            <th @click="sortTable('base_stock')" :class="{ sortable: true, sorted: sortBy === 'base_stock' }">
              Base Stock
              <span class="sort-indicator">
                ↕
                <span v-if="sortBy === 'base_stock'">
                  {{ sortDirection === 'asc' ? '▲' : '▼' }}
                </span>
              </span>
            </th>
            <th @click="sortTable('status')" :class="{ sortable: true, sorted: sortBy === 'status' }">
              Status
              <span class="sort-indicator">
                ↕
                <span v-if="sortBy === 'status'">
                  {{ sortDirection === 'asc' ? '▲' : '▼' }}
                </span>
              </span>
            </th>
            <th>Actions</th>
          </tr>
        </thead>
        <tbody>
          <!-- Inventory Items Rendered Here -->
          <tr v-for="item in inventoryItems" :key="item.inv_id">
            <td>{{ item.inv_name }}</td>
            <td>{{ item.stock }}</td>
            <td>{{ item.base_stock }}</td>
            <td>
              <span 
                :class="['status-badge', 
                  item.stock <= item.base_stock * 0.2 ? 'critical' :
                  item.stock <= item.base_stock ? 'warning' : 'good'
                ]"
              >
                {{ getStockStatus(item) }}
              </span>
            </td>
            <td class="actions">
              <button 
                @click="editInventoryItem(item)"
                class="action-button edit"
              >
                Edit
              </button>
              <button 
                @click="confirmDelete(item)"
                class="action-button delete"
              >
                Delete
              </button>
            </td>
          </tr>
        </tbody>
      </table>
    </div>

    <!-- Add/Edit Modal -->
    <div class="modal" v-if="showAddForm || editingInventoryItem">
      <div class="modal-content">
        <h3>{{ editingInventoryItem ? 'Edit Inventory Item' : 'Add New Inventory Item' }}</h3>
        <form @submit.prevent="handleSubmit">
          <div class="form-group">
            <label>Item Name:</label>
            <input 
              v-model="formData.inv_name" 
              required
              type="text"
            >
          </div>
          <div class="form-group">
            <label>Current Stock:</label>
            <input 
              v-model.number="formData.stock" 
              required
              type="number"
              min="0"
            >
          </div>
          <div class="form-group">
            <label>Base Stock Level:</label>
            <input 
              v-model.number="formData.base_stock" 
              required
              type="number"
              min="0"
            >
          </div>
          <div class="form-actions">
            <button 
              type="button" 
              @click="closeForm" 
              class="cancel-button"
            >
              Cancel
            </button>
            <button 
              type="submit" 
              class="submit-button"
            >
              {{ editingInventoryItem ? 'Update' : 'Add' }} Item
            </button>
          </div>
        </form>
      </div>
    </div>

    <!-- Delete Confirmation Modal -->
    <div class="modal" v-if="showDeleteConfirm">
      <div class="modal-content">
        <h3>Confirm Delete</h3>
        <p>Are you sure you want to delete {{ deleteInventoryItem?.inv_name }}?</p>
        <div class="form-actions">
          <button 
            @click="showDeleteConfirm = false" 
            class="cancel-button"
          >
            Cancel
          </button>
          <button 
            @click="handleDelete" 
            class="delete-button"
          >
            Delete
          </button>
        </div>
      </div>
    </div>
  </div>
</template>


<script>
import api from '@/api';

/**
 * @component InventorySection
 * @description A component that manages inventory items, including tracking stock levels,
 * adding new items, and monitoring inventory status. Provides functionality for sorting,
 * filtering, and managing stock levels with warning indicators.
 */
export default {
  name: 'InventorySection',
  
  /**
   * Initial component data
   * @returns {Object} Component data
   */
  data() {
    return {
      /** @type {Array} List of all inventory items */
      inventoryItems: [],
      
      /** @type {Boolean} Loading state indicator */
      loading: false,
      
      /** @type {Boolean} Controls visibility of add/edit form */
      showAddForm: false,
      
      /** @type {Object|null} Currently edited inventory item */
      editingInventoryItem: null,
      
      /** @type {Boolean} Controls visibility of delete confirmation */
      showDeleteConfirm: false,
      
      /** @type {Object|null} Item to be deleted */
      deleteInventoryItem: null,
      
      /** @type {Object} Form data for adding/editing items */
      formData: {
        inv_name: '',
        stock: 0,
        base_stock: 0
      },
      
      /** @type {String} Current sort column */
      sortBy: '',
      
      /** @type {String} Current sort direction ('asc' or 'desc') */
      sortDirection: 'asc'
    };
  },

  computed: {
    /**
     * Calculates the number of items that are below their base stock level
     * @returns {number} Count of low stock items
     */
    lowStockItems() {
      return this.inventoryItems.filter(item => 
        item.stock <= item.base_stock
      ).length;
    }
  },

  methods: {
    /**
     * Retrieves all inventory items from the backend API
     * @async
     * @returns {Promise<void>}
     */
    async fetchInventoryItems() {
      this.loading = true;
      try {
        const response = await api.get('/inventory_items');
        this.inventoryItems = response.data;
      } catch (error) {
        console.error('Error fetching inventory items:', error);
      } finally {
        this.loading = false;
      }
    },

    /**
     * Determines the stock status of an item based on current quantity vs base stock
     * @param {Object} item - Inventory item to check
     * @returns {string} Status label ('Critical', 'Low', or 'Good')
     */
    getStockStatus(item) {
      if (item.stock <= item.base_stock * 0.2) return 'Critical';
      if (item.stock <= item.base_stock) return 'Low';
      return 'Good';
    },

    /**
     * Prepares the form for editing an existing inventory item
     * @param {Object} item - Item to edit
     */
    editInventoryItem(item) {
      this.editingInventoryItem = item;
      this.formData = { ...item };
      this.showAddForm = true;
    },

    /**
     * Initiates the deletion process for an inventory item
     * @param {Object} item - Item to delete
     */
    confirmDelete(item) {
      this.deleteInventoryItem = item;
      this.showDeleteConfirm = true;
    },

    /**
     * Processes the actual deletion of an inventory item
     * @async
     * @returns {Promise<void>}
     */
    async handleDelete() {
      try {
        await api.delete(`/inventory_items/${this.deleteInventoryItem.inv_id}`);
        this.inventoryItems = this.inventoryItems.filter(
          item => item.inv_id !== this.deleteInventoryItem.inv_id
        );
        this.showDeleteConfirm = false;
        this.deleteInventoryItem = null;
      } catch (error) {
        console.error('Error deleting inventory item:', error);
      }
    },

    /**
     * Handles form submission for both adding and updating inventory items
     * @async
     * @returns {Promise<void>}
     */
    async handleSubmit() {
      try {
        if (this.editingInventoryItem) {
          await api.put(
            `/inventory_items/${this.editingInventoryItem.inv_id}`,
            this.formData
          );
          const index = this.inventoryItems.findIndex(
            item => item.inv_id === this.editingInventoryItem.inv_id
          );
          this.inventoryItems[index] = { ...this.formData };
        } else {
          const response = await api.post('/inventory_items/create', this.formData);
          this.inventoryItems.push(response.data);
        }
        this.closeForm();
      } catch (error) {
        console.error('Error saving inventory item:', error);
      }
    },

    /**
     * Closes the form and resets form data to initial values
     */
    closeForm() {
      this.showAddForm = false;
      this.editingInventoryItem = null;
      this.formData = {
        inv_name: '',
        stock: 0,
        base_stock: 0
      };
    },

    /**
     * Sorts the inventory table based on the specified column
     * @param {string} column - Column to sort by
     */
    sortTable(column) {
      if (this.sortBy === column) {
        // Toggle sorting direction
        this.sortDirection = this.sortDirection === 'asc' ? 'desc' : 'asc';
      } else {
        // Set the column to sort by and reset direction
        this.sortBy = column;
        this.sortDirection = 'asc';
      }

      // Perform sorting
      this.inventoryItems.sort((a, b) => {
        let valA, valB;

        // Special case for 'status' column
        if (column === 'status') {
          const statusPriority = {
            Critical: 3,
            Low: 2,
            Good: 1
          };
          valA = statusPriority[this.getStockStatus(a)];
          valB = statusPriority[this.getStockStatus(b)];
        } else {
          valA = a[column];
          valB = b[column];

          // Handle case-insensitive string comparison
          if (typeof valA === 'string') valA = valA.toLowerCase();
          if (typeof valB === 'string') valB = valB.toLowerCase();
        }

        if (valA < valB) return this.sortDirection === 'asc' ? -1 : 1;
        if (valA > valB) return this.sortDirection === 'asc' ? 1 : -1;
        return 0;
      });
    }
  },

  /**
   * Lifecycle hook - Called when component is created
   * Fetches initial inventory data
   */
  created() {
    this.fetchInventoryItems();
  }
}
</script>

<style scoped>
.inventory-section {
  padding: 2rem;
  background-color: white;
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}

.header-section {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 2rem;
}

.inventory-stats {
  display: flex;
  gap: 1rem;
  margin-bottom: 2rem;
}

.stat-card {
  background-color: #f8f9fa;
  padding: 1.5rem;
  border-radius: 8px;
  flex: 1;
  text-align: center;
  box-shadow: 0 1px 3px rgba(0,0,0,0.1);
}

.stat-card h4 {
  margin: 0;
  color: #6c757d;
  font-size: 0.875rem;
}

.stat-card p {
  margin: 0.5rem 0 0;
  font-size: 1.5rem;
  font-weight: bold;
  color: #2c3e50;
}

.add-button {
  background-color: #4CAF50;
  color: white;
  padding: 0.5rem 1rem;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-size: 1rem;
  transition: background-color 0.2s ease;
}

.add-button:hover {
  background-color: #43a047;
}

.loading-spinner {
  display: flex;
  justify-content: center;
  align-items: center;
  padding: 2rem;
  font-size: 1.2rem;
  color: #6c757d;
}

.table-container {
  overflow-x: auto;
  margin-top: 1rem;
  border-radius: 4px;
  box-shadow: 0 1px 3px rgba(0,0,0,0.1);
}

.inventory-table {
  width: 100%;
  border-collapse: collapse;
  margin-top: 1rem;
  background-color: white;
}

.inventory-table td {
  padding: 1rem;
  text-align: left;
  border-bottom: 1px solid #eee;
}

.inventory-table th {
  padding: 1rem;
  text-align: left;
  border-bottom: 1px solid #eee;
  cursor: pointer;
  user-select: none;
  transition: background-color 0.3s;
}

.inventory-table th {
  background-color: #f8f9fa;
  font-weight: 600;
  color: #495057;
  white-space: nowrap;
}

.inventory-table tr:hover {
  background-color: #f8f9fa;
}

.inventory-table th.sortable:hover {
  background-color: #f0f4f8;
}

.inventory-table th.sorted {
  background-color: #e3eaf0;
}

.sort-indicator {
  font-size: 0.8rem;
  margin-left: 0.5rem;
  color: #6c757d;
}

.sort-indicator span {
  font-size: 0.7rem;
  margin-left: 0.2rem;
}

.status-badge {
  padding: 0.25rem 0.5rem;
  border-radius: 4px;
  font-size: 0.875rem;
  font-weight: 500;
  text-transform: capitalize;
}

.status-badge.good {
  background-color: #e8f5e9;
  color: #2e7d32;
}

.status-badge.warning {
  background-color: #fff3e0;
  color: #e65100;
}

.status-badge.critical {
  background-color: #ffebee;
  color: #c62828;
}

.actions {
  display: flex;
  gap: 0.5rem;
  white-space: nowrap;
}

.action-button {
  padding: 0.25rem 0.5rem;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-size: 0.875rem;
  transition: opacity 0.2s ease;
}

.action-button.edit {
  background-color: #2196F3;
  color: white;
}

.action-button.edit:hover {
  background-color: #1e88e5;
}

.action-button.delete {
  background-color: #f44336;
  color: white;
}

.action-button.delete:hover {
  background-color: #e53935;
}

.modal {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background-color: rgba(0,0,0,0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
}

.modal-content {
  background-color: white;
  padding: 2rem;
  border-radius: 8px;
  width: 100%;
  max-width: 500px;
  max-height: 90vh;
  overflow-y: auto;
  box-shadow: 0 4px 6px rgba(0,0,0,0.1);
}

.modal-content h3 {
  margin-top: 0;
  margin-bottom: 1.5rem;
  color: #2c3e50;
  font-size: 1.25rem;
}

.form-group {
  margin-bottom: 1.5rem;
}

.form-group label {
  display: block;
  margin-bottom: 0.5rem;
  font-weight: 500;
  color: #495057;
}

.form-group input {
  width: 100%;
  padding: 0.5rem;
  border: 1px solid #ddd;
  border-radius: 4px;
  font-size: 1rem;
  transition: border-color 0.2s ease;
}

.form-group input:focus {
  outline: none;
  border-color: #2196F3;
  box-shadow: 0 0 0 2px rgba(33,150,243,0.1);
}

.form-group input:invalid {
  border-color: #f44336;
}

.form-actions {
  display: flex;
  justify-content: flex-end;
  gap: 1rem;
  margin-top: 2rem;
}

.submit-button,
.cancel-button,
.delete-button {
  padding: 0.5rem 1rem;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-size: 1rem;
  transition: background-color 0.2s ease;
}

.submit-button {
  background-color: #4CAF50;
  color: white;
}

.submit-button:hover {
  background-color: #43a047;
}

.cancel-button {
  background-color: #9e9e9e;
  color: white;
}

.cancel-button:hover {
  background-color: #757575;
}

.delete-button {
  background-color: #f44336;
  color: white;
}

.delete-button:hover {
  background-color: #e53935;
}

@media (max-width: 768px) {
  .inventory-section {
    padding: 1rem;
  }

  .inventory-stats {
    flex-direction: column;
  }

  .stat-card {
    margin-bottom: 1rem;
  }

  .modal-content {
    margin: 1rem;
    padding: 1.5rem;
  }

  .action-button {
    padding: 0.5rem;
  }
}

@media (max-width: 480px) {
  .header-section {
    flex-direction: column;
    gap: 1rem;
    align-items: stretch;
  }

  .add-button {
    width: 100%;
  }

  .inventory-table th,
  .inventory-table td {
    padding: 0.75rem;
  }

  .actions {
    flex-direction: column;
    gap: 0.25rem;
  }

  .action-button {
    width: 100%;
  }
}
</style>