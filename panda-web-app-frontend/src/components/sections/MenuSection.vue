<template>
  <div class="menu-section">
    <!-- Previous header and stats sections remain the same -->
    <div class="header-section">
      <h2>Menu Management</h2>
      <button 
        @click="showAddForm = true" 
        class="add-button"
      >
        Add Menu Item
      </button>
    </div>

    <!-- Menu Stats -->
    <div class="menu-stats">
      <div class="stat-card">
        <h4>Total Items</h4>
        <p>{{ menuItems.length }}</p>
      </div>
      <div class="stat-card">
        <h4>Categories</h4>
        <p>{{ uniqueCategories.length }}</p>
      </div>
    </div>

    <!-- Loading Spinner -->
    <div v-if="loading" class="loading-spinner">
      Loading...
    </div>

    <!-- Category Filter -->
    <div class="filter-section">
      <label>Filter by Category:</label>
      <select v-model="selectedCategory" class="category-select">
        <option value="">All Categories</option>
        <option v-for="category in uniqueCategories" 
                :key="category" 
                :value="category">
          {{ category }}
        </option>
      </select>
    </div>

    <!-- Menu Table -->
    <div class="table-container">
      <table class="menu-table">
        <thead>
          <tr>
            <th>Image</th>
            <th>Name</th>
            <th>Category</th>
            <th>Price</th>
            <th>Actions</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="item in filteredMenuItems" :key="item.menu_id">
            <td>
              <img 
                v-if="item.image_url" 
                :src="item.image_url" 
                alt="Menu item"
                class="menu-item-image"
              >
              <span v-else>No image</span>
            </td>
            <td>{{ item.menu_name }}</td>
            <td>{{ item.category }}</td>
            <td>${{ Number(item.price).toFixed(2) }}</td>
            <td class="actions">
              <button 
                @click="editMenuItem(item)"
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

    <!-- Add/Edit Form Modal -->
    <div class="modal" v-if="showAddForm">
      <div class="modal-content">
        <h3>{{ editingMenuItem ? 'Edit Menu Item' : 'Add New Menu Item' }}</h3>
        <form @submit.prevent="handleSubmit" class="menu-form">
          <div class="form-group">
            <label>Item Name:</label>
            <input 
              v-model="formData.menu_name" 
              required
              type="text"
              placeholder="Enter item name"
            >
          </div>
          <div class="form-group">
            <label>Category:</label>
            <input 
              v-model="formData.category" 
              required
              type="text"
              placeholder="Enter category"
            >
          </div>
          <div class="form-group">
            <label>Price:</label>
            <input 
              v-model.number="formData.price" 
              required
              type="number"
              min="0"
              step="0.01"
              placeholder="Enter price"
            >
          </div>
          <div class="form-group">
            <label>Image:</label>
            <input 
              type="file" 
              @change="handleImageChange"
              accept="image/*"
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
              {{ editingMenuItem ? 'Update' : 'Add' }} Item
            </button>
          </div>
        </form>
      </div>
    </div>

    <!-- Delete Confirmation Modal -->
    <div class="modal" v-if="showDeleteConfirm">
      <div class="modal-content">
        <h3>Confirm Delete</h3>
        <p>Are you sure you want to delete {{ deleteMenuItem?.menu_name }}?</p>
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

export default {
  name: 'MenuSection',
  
  // @vuese
  /**
   * @data
   * @description
   * This section defines the initial data fields used in the component. 
   * - `menuItems`: List of menu items fetched from the backend.
   * - `loading`: A flag to indicate whether the component is in a loading state.
   * - `showAddForm`: Flag to show or hide the form for adding/editing a menu item.
   * - `editingMenuItem`: Holds the menu item currently being edited, or `null` if adding a new one.
   * - `showDeleteConfirm`: Flag to show or hide the delete confirmation modal.
   * - `deleteMenuItem`: The menu item to be deleted.
   * - `selectedCategory`: Category selected for filtering menu items.
   * - `formData`: Form data used to add or edit a menu item.
   * - `selectedImage`: The selected image for the menu item.
   */
  data() {
    return {
      menuItems: [],
      loading: false,
      showAddForm: false,
      editingMenuItem: null,
      showDeleteConfirm: false,
      deleteMenuItem: null,
      selectedCategory: '',
      formData: {
        menu_name: '',
        category: '',
        price: 0
      },
      selectedImage: null
    }
  },

  computed: {
    /**
     * @computed uniqueCategories
     * @description
     * This computed property returns a list of unique categories extracted from the `menuItems` array.
     * @returns {Array} List of unique categories.
     */
    uniqueCategories() {
      return [...new Set(this.menuItems.map(item => item.category))];
    },
    
    /**
     * @computed filteredMenuItems
     * @description
     * This computed property filters the `menuItems` based on the selected category.
     * If no category is selected, all menu items are shown.
     * @returns {Array} Filtered menu items based on the selected category.
     */
    filteredMenuItems() {
      if (!this.selectedCategory) return this.menuItems;
      return this.menuItems.filter(item => 
        item.category === this.selectedCategory
      );
    }
  },

  methods: {
    /**
     * @method fetchMenuItems
     * @description
     * Fetches menu items from the backend API and sets the `menuItems` data property.
     * Sets the `loading` flag to `true` while the request is in progress.
     * 
     * @returns {Promise<void>}
     */
    async fetchMenuItems() {
      this.loading = true;
      try {
        const response = await api.get('/menu_items');
        this.menuItems = response.data;
      } catch (error) {
        console.error('Error fetching menu items:', error);
      } finally {
        this.loading = false;
      }
    },

    /**
     * @method handleImageChange
     * @description
     * Handles the change event when an image file is selected for a menu item.
     * Updates the `selectedImage` data property with the selected file.
     * 
     * @param {Event} event - The file input change event.
     * @returns {void}
     */
    handleImageChange(event) {
      this.selectedImage = event.target.files[0];
    },

     /**
     * @method uploadImage
     * @description
     * Uploads an image for a menu item to the backend.
     * If a new image is selected, it is sent to the backend to be associated with the given menu item ID.
     * 
     * @param {string} menuId - The ID of the menu item to associate the image with.
     * @returns {Promise<void>}
     */
    async uploadImage(menuId) {
      if (!this.selectedImage) return;

      const formData = new FormData();
      formData.append('image', this.selectedImage);
      formData.append('menu_id', menuId);

      try {
        const response = await api.patch(`menu_items/${menuId}/update_image`, formData, {
            headers: { 'Content-Type': 'multipart/form-data' },
            // params: { menu_id: menuId }, 
          });
      } catch (error) {
        if (error.response) {
            // Backend returned an error
            const statusCode = error.response.status;
            const errorMessage = error.response.data?.message || error.response.statusText;

            console.error('Error uploading image:', errorMessage);

            // Specific error handling based on status code or message
            if (statusCode === 413 || errorMessage.includes('too large body')) {
              alert('The uploaded image is too large. Please choose a smaller file.');
            } else if (statusCode === 400) {
              alert('Bad Request. Please check the menu ID and try again.');
            } else if (statusCode === 404) {
              alert('Menu ID not found. Please enter a valid menu ID.');
            } else if (statusCode === 500) {
              alert('Server error. Please try again later.');
            } else {
              alert(`An unexpected error occurred: ${errorMessage}`);
            }
          } else if (error.request) {
            // Request was made but no response received
            console.error('No response from server:', error.request);
            alert('No response from the server. Please check your network connection.');
          } else {
            // Something else caused the error
            console.error('Unexpected error:', error.message);
            alert(`Unexpected error: ${error.message}`);
          }
      }
    },

     /**
     * @method editMenuItem
     * @description
     * Opens the Add/Edit form for editing a specific menu item.
     * Populates the form fields with the existing menu item data.
     * 
     * @param {Object} item - The menu item to be edited.
     * @returns {void}
     */
    editMenuItem(item) {
      this.editingMenuItem = item;
      this.formData = { 
        menu_name: item.menu_name,
        category: item.category,
        price: item.price
      };
      this.showAddForm = true;
    },

    /**
     * @method confirmDelete
     * @description
     * Confirms the deletion of a menu item and sets the `deleteMenuItem` property to the item to be deleted.
     * 
     * @param {Object} item - The menu item to be deleted.
     * @returns {void}
     */
    confirmDelete(item) {
      this.deleteMenuItem = item;
      this.showDeleteConfirm = true;
    },

    /**
     * @method handleDelete
     * @description
     * Deletes the selected menu item from the backend and removes it from the local `menuItems` array.
     * 
     * @returns {Promise<void>}
     */
    async handleDelete() {
      try {
        await api.delete(`/menu_items/${this.deleteMenuItem.menu_id}`);
        this.menuItems = this.menuItems.filter(
          item => item.menu_id !== this.deleteMenuItem.menu_id
        );
        this.showDeleteConfirm = false;
        this.deleteMenuItem = null;
      } catch (error) {
        console.error('Error deleting menu item:', error);
      }
    },

    /**
     * @method handleSubmit
     * @description
     * Handles form submission for adding or updating a menu item. If editing an existing item, it updates the item; otherwise, it adds a new item.
     * After submitting the form, the menu item is saved to the backend and the list is refreshed.
     * 
     * @returns {Promise<void>}
     */
    async handleSubmit() {
      try {
        let response;
        if (this.editingMenuItem) {
          // Update existing menu item
          response = await api.patch(
            `/menu_items/${this.editingMenuItem.menu_id}`,
            this.formData
          );
          
          // Update the item in the local array
          const index = this.menuItems.findIndex(
            item => item.menu_id === this.editingMenuItem.menu_id
          );
          if (index !== -1) {
            this.menuItems[index] = response.data;
          }

          if (this.selectedImage) {
            await this.uploadImage(this.editingMenuItem.menu_id);
          }
        } else {
          // Add new menu item
          response = await api.post('/menu_items/add_menu_item', this.formData);
          if (this.selectedImage) {
            await this.uploadImage(response.data.menu_id);
          }
          this.menuItems.push(response.data);
        }
        await this.fetchMenuItems();
        this.closeForm();
      } catch (error) {
        alert(`Error saving menu item: ${error.message || JSON.stringify(error)}`);
        console.error('Error saving menu item:', error);
      }
    },

    /**
     * @method closeForm
     * @description
     * Closes the Add/Edit form and resets all form data to its initial state.
     * 
     * @returns {void}
     */
    closeForm() {
      this.showAddForm = false;
      this.editingMenuItem = null;
      this.selectedImage = null;
      this.formData = {
        menu_name: '',
        category: '',
        price: 0
      };
    }
  },

  /**
   * @created
   * @description
   * Fetches the menu items from the backend as soon as the component is created.
   * 
   * @returns {void}
   */
  created() {
    this.fetchMenuItems();
  }
}
</script>

<style scoped>
/* Adding all the previously missing styles */
.menu-section {
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

.menu-stats {
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

.filter-section {
  margin-bottom: 1.5rem;
}

.category-select {
  padding: 0.5rem;
  border: 1px solid #ddd;
  border-radius: 4px;
  margin-left: 0.5rem;
}

.menu-item-image {
  width: 50px;
  height: 50px;
  object-fit: cover;
  border-radius: 4px;
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

.menu-table {
  width: 100%;
  border-collapse: collapse;
  margin-top: 1rem;
  background-color: white;
}

.menu-table th,
.menu-table td {
  padding: 1rem;
  text-align: left;
  border-bottom: 1px solid #eee;
}

.menu-table th {
  background-color: #f8f9fa;
  font-weight: 600;
  color: #495057;
  white-space: nowrap;
}

.menu-table tr:hover {
  background-color: #f8f9fa;
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
  .menu-section {
    padding: 1rem;
  }

  .menu-stats {
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

  .menu-table th,
  .menu-table td {
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