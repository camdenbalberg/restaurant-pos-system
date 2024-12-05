<template>
    <div class="recipe-section">
      <div class="header-section">
        <h2>Recipe Management</h2>
        <button 
          @click="showAddForm = true" 
          class="add-button"
        >
          Add Recipe
        </button>
      </div>
  
      <!-- Stats -->
      <div class="recipe-stats">
        <div class="stat-card">
          <h4>Total Recipes</h4>
          <p>{{ recipes.length }}</p>
        </div>
        <div class="stat-card">
          <h4>Menu Items with Recipes</h4>
          <p>{{ uniqueMenuItems.length }}</p>
        </div>
      </div>
  
      <!-- Loading Spinner -->
      <div v-if="loading" class="loading-spinner">
        Loading...
      </div>
  
      <!-- Filter Section -->
      <div class="filter-section">
        <input 
          v-model="searchTerm" 
          placeholder="Search recipes..." 
          class="search-input"
        >
      </div>
  
      <!-- Recipes Table -->
      <div class="table-container">
        <table class="recipe-table">
          <thead>
            <tr>
              <th>Menu Item</th>
              <th>Ingredients</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="(groupedRecipe, menuId) in groupedRecipes" :key="menuId">
              <td>{{ groupedRecipe[0].menu_name }}</td>
              <td>
                <ul class="ingredients-list">
                  <li v-for="recipe in groupedRecipe" :key="recipe.inv_id">
                    {{ recipe.inv_name }} ({{ recipe.quantity }})
                  </li>
                </ul>
              </td>
              <td class="actions">
                <button 
                  @click="editRecipe(groupedRecipe)"
                  class="action-button edit"
                >
                  Edit
                </button>
                <button 
                  @click="confirmDelete(groupedRecipe)"
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
    <div class="modal" v-if="showAddForm || editingRecipe">
      <div class="modal-content">
        <h3>{{ editingRecipe ? 'Edit Recipe' : 'Add New Recipe' }}</h3>
        <form @submit.prevent="handleSubmit" class="recipe-form">
          <div class="form-group">
            <label>Menu Item:</label>
            <select 
              v-model="formData.menu_id"
              required
              class="form-select"
              :disabled="editingRecipe"
            >
              <option value="">Select Menu Item</option>
              <option v-for="item in menuItems" 
                      :key="item.menu_id" 
                      :value="item.menu_id"
              >
                {{ item.menu_name }}
              </option>
            </select>
          </div>

          <!-- Dynamic Ingredients Form -->
          <div class="ingredients-form">
            <h4>Ingredients</h4>
            <div v-for="(ingredient, index) in formData.ingredients" 
                 :key="index" 
                 class="ingredient-row"
            >
              <div class="form-group ingredient-select">
                <label>Ingredient:</label>
                <select 
                  v-model="ingredient.inv_id"
                  required
                  class="form-select"
                >
                  <option value="">Select Ingredient</option>
                  <option v-for="item in inventoryItems" 
                          :key="item.inv_id" 
                          :value="item.inv_id"
                  >
                    {{ item.inv_name }}
                  </option>
                </select>
              </div>
              <div class="form-group quantity-input">
                <label>Quantity:</label>
                <input 
                  v-model.number="ingredient.quantity"
                  type="number"
                  required
                  min="1"
                  step="1"
                >
              </div>
              <button 
                type="button"
                @click="removeIngredient(index)"
                class="remove-button"
                v-if="formData.ingredients.length > 1"
              >
                Remove
              </button>
            </div>
            <button 
              type="button"
              @click="addIngredient"
              class="add-ingredient-button"
            >
              Add Another Ingredient
            </button>
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
              {{ editingRecipe ? 'Update' : 'Add' }} Recipe
            </button>
          </div>
        </form>
      </div>
    </div>

    <!-- Delete Confirmation Modal -->
    <div class="modal" v-if="showDeleteConfirm">
      <div class="modal-content">
        <h3>Confirm Delete</h3>
        <p>Are you sure you want to delete this recipe?</p>
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
 * @component RecipeSection
 * @description A component that manages recipes for menu items, including adding, editing,
 * and deleting recipes. Provides functionality for managing ingredients and their quantities
 * for each menu item recipe.
 */
export default {
  name: 'RecipeSection',
  
  /**
   * Initial component data
   * @returns {Object} Component data
   */
  data() {
    return {
      /** @type {Array} List of all recipes */
      recipes: [],
      
      /** @type {Array} List of available menu items */
      menuItems: [],
      
      /** @type {Array} List of available inventory items */
      inventoryItems: [],
      
      /** @type {Boolean} Loading state indicator */
      loading: false,
      
      /** @type {Boolean} Controls visibility of add/edit form */
      showAddForm: false,
      
      /** @type {Object|null} Currently edited recipe */
      editingRecipe: null,
      
      /** @type {Boolean} Controls visibility of delete confirmation */
      showDeleteConfirm: false,
      
      /** @type {Object|null} Recipe to be deleted */
      deleteRecipe: null,
      
      /** @type {String} Search term for filtering recipes */
      searchTerm: '',
      
      /** @type {Object} Form data for adding/editing recipes */
      formData: {
        menu_id: '',
        ingredients: [
          { inv_id: '', quantity: 1 }
        ]
      }
    }
  },

  computed: {
    /**
     * Gets the unique menu items that have associated recipes
     * @returns {Array} List of unique menu item IDs
     */
    uniqueMenuItems() {
      return [...new Set(this.recipes.map(recipe => recipe.menu_id))];
    },

    /**
     * Groups recipes by menu item and filters based on search term
     * @returns {Object} Grouped and filtered recipes
     */
    groupedRecipes() {
      // Group recipes by menu_id
      const grouped = this.recipes.reduce((acc, recipe) => {
        if (!acc[recipe.menu_id]) {
          acc[recipe.menu_id] = [];
        }
        acc[recipe.menu_id].push(recipe);
        return acc;
      }, {});

      // Filter based on search term
      if (this.searchTerm) {
        const searchLower = this.searchTerm.toLowerCase();
        return Object.fromEntries(
          Object.entries(grouped).filter(([_, recipes]) => 
            recipes[0].menu_name.toLowerCase().includes(searchLower) ||
            recipes.some(recipe => 
              recipe.inv_name.toLowerCase().includes(searchLower)
            )
          )
        );
      }

      return grouped;
    }
  },

  methods: {
    /**
     * Fetches all recipes from the backend API
     * @async
     * @returns {Promise<void>}
     */
    async fetchRecipes() {
      this.loading = true;
      try {
        const response = await api.get('/recipes');
        this.recipes = response.data;
      } catch (error) {
        console.error('Error fetching recipes:', error);
      } finally {
        this.loading = false;
      }
    },

    /**
     * Fetches all menu items from the backend API
     * @async
     * @returns {Promise<void>}
     */
    async fetchMenuItems() {
      try {
        const response = await api.get('/menu_items');
        this.menuItems = response.data;
      } catch (error) {
        console.error('Error fetching menu items:', error);
      }
    },

    /**
     * Fetches all inventory items from the backend API
     * @async
     * @returns {Promise<void>}
     */
    async fetchInventoryItems() {
      try {
        const response = await api.get('/inventory_items');
        this.inventoryItems = response.data;
      } catch (error) {
        console.error('Error fetching inventory items:', error);
      }
    },

    /**
     * Adds a new ingredient row to the recipe form
     */
    addIngredient() {
      this.formData.ingredients.push({ inv_id: '', quantity: 1 });
    },

    /**
     * Removes an ingredient from the recipe form
     * @param {number} index - Index of the ingredient to remove
     */
    removeIngredient(index) {
      this.formData.ingredients.splice(index, 1);
    },

    /**
     * Prepares the form for editing an existing recipe
     * @param {Array} recipes - Array of recipe objects for a menu item
     */
    editRecipe(recipes) {
      this.editingRecipe = recipes;
      this.formData = {
        menu_id: recipes[0].menu_id,
        ingredients: recipes.map(recipe => ({
          inv_id: recipe.inv_id,
          quantity: recipe.quantity
        }))
      };
      this.showAddForm = true;
    },

    /**
     * Initiates the deletion process for a recipe
     * @param {Array} recipes - Array of recipe objects to delete
     */
    confirmDelete(recipes) {
      this.deleteRecipe = recipes;
      this.showDeleteConfirm = true;
    },

    /**
     * Processes the actual deletion of a recipe
     * @async
     * @returns {Promise<void>}
     */
    async handleDelete() {
      try {
        for (const recipe of this.deleteRecipe) {
          await api.delete(`/recipes`, {
            params: {
              menu_id: recipe.menu_id,
              inv_id: recipe.inv_id
            }
          });
        }
        await this.fetchRecipes();
        this.showDeleteConfirm = false;
        this.deleteRecipe = null;
      } catch (error) {
        console.error('Error deleting recipe:', error);
      }
    },

    /**
     * Handles form submission for both adding and updating recipes
     * @async
     * @returns {Promise<void>}
     */
    async handleSubmit() {
      try {
        if (this.editingRecipe) {
          // Delete existing recipe entries
          for (const recipe of this.editingRecipe) {
            await api.delete(`/recipes`, {
              params: {
                menu_id: recipe.menu_id,
                inv_id: recipe.inv_id
              }
            });
          }
        }

        // Add new recipe entries
        for (const ingredient of this.formData.ingredients) {
          await api.post('/recipes', {
            menu_id: this.formData.menu_id,
            inv_id: ingredient.inv_id,
            quantity: ingredient.quantity
          });
        }

        await this.fetchRecipes();
        this.closeForm();
      } catch (error) {
        console.error('Error saving recipe:', error);
      }
    },

    /**
     * Closes the form and resets form data to initial values
     */
    closeForm() {
      this.showAddForm = false;
      this.editingRecipe = null;
      this.formData = {
        menu_id: '',
        ingredients: [
          { inv_id: '', quantity: 1 }
        ]
      };
    }
  },

  /**
   * Lifecycle hook - Called when component is created
   * Fetches initial recipe data and required lookup data
   */
  created() {
    this.fetchRecipes();
    this.fetchMenuItems();
    this.fetchInventoryItems();
  }
}
</script>
  
  <style scoped>
  .recipe-section {
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
  
  .recipe-stats {
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
  
  .filter-section {
    margin-bottom: 1.5rem;
  }
  
  .search-input {
    width: 100%;
    max-width: 300px;
    padding: 0.5rem;
    border: 1px solid #ddd;
    border-radius: 4px;
    font-size: 1rem;
  }
  
  .table-container {
    overflow-x: auto;
    margin-top: 1rem;
    border-radius: 4px;
    box-shadow: 0 1px 3px rgba(0,0,0,0.1);
  }
  
  .recipe-table {
    width: 100%;
    border-collapse: collapse;
    margin-top: 1rem;
    background-color: white;
  }
  
  .recipe-table th,
  .recipe-table td {
    padding: 1rem;
    text-align: left;
    border-bottom: 1px solid #eee;
  }
  
  .recipe-table th {
    background-color: #f8f9fa;
    font-weight: 600;
    color: #495057;
    white-space: nowrap;
  }
  
  .recipe-table tr:hover {
    background-color: #f8f9fa;
  }
  
  .ingredients-list {
    list-style: none;
    padding: 0;
    margin: 0;
  }
  
  .ingredients-list li {
    margin-bottom: 0.25rem;
  }
  
  .actions {
    display: flex;
    gap: 0.5rem;
    white-space: nowrap;
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
  
  .loading-spinner {
    display: flex;
    justify-content: center;
    align-items: center;
    padding: 2rem;
    font-size: 1.2rem;
    color: #6c757d;
  }
  
  /* Modal Styles */
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
    max-width: 600px;
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
  
  /* Form Styles */
  .recipe-form {
    display: flex;
    flex-direction: column;
    gap: 1.5rem;
  }
  
  .form-group {
    margin-bottom: 1rem;
  }
  
  .form-group label {
    display: block;
    margin-bottom: 0.5rem;
    font-weight: 500;
    color: #495057;
  }
  
  .form-group input,
  .form-group select {
    width: 100%;
    padding: 0.5rem;
    border: 1px solid #ddd;
    border-radius: 4px;
    font-size: 1rem;
    transition: border-color 0.2s ease;
  }
  
  .form-group input:focus,
  .form-group select:focus {
    outline: none;
    border-color: #2196F3;
    box-shadow: 0 0 0 2px rgba(33,150,243,0.1);
  }
  
  .ingredient-row {
    display: grid;
    grid-template-columns: 2fr 1fr auto;
    gap: 1rem;
    align-items: flex-end;
    margin-bottom: 1rem;
    padding-bottom: 1rem;
    border-bottom: 1px solid #eee;
  }
  
  .ingredients-form {
    background-color: #f8f9fa;
    padding: 1.5rem;
    border-radius: 8px;
    margin-bottom: 1.5rem;
  }
  
  .ingredients-form h4 {
    margin-top: 0;
    margin-bottom: 1.5rem;
    color: #2c3e50;
  }
  
  .add-ingredient-button {
    background-color: #2196F3;
    color: white;
    padding: 0.5rem 1rem;
    border: none;
    border-radius: 4px;
    cursor: pointer;
    transition: background-color 0.2s ease;
    width: 100%;
    margin-top: 1rem;
  }
  
  .add-ingredient-button:hover {
    background-color: #1e88e5;
  }
  
  .remove-button {
    background-color: #f44336;
    color: white;
    padding: 0.5rem;
    border: none;
    border-radius: 4px;
    cursor: pointer;
    height: 38px;
    transition: background-color 0.2s ease;
  }
  
  .remove-button:hover {
    background-color: #e53935;
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
  
  /* Responsive Styles */
  @media (max-width: 768px) {
    .recipe-section {
      padding: 1rem;
    }
  
    .recipe-stats {
      flex-direction: column;
    }
  
    .stat-card {
      margin-bottom: 1rem;
    }
  
    .modal-content {
      margin: 1rem;
      padding: 1.5rem;
    }
  
    .ingredient-row {
      grid-template-columns: 1fr;
      gap: 0.5rem;
    }
  
    .actions {
      flex-direction: column;
      gap: 0.5rem;
    }
  
    .action-button {
      width: 100%;
    }
  }
  
  @media (max-width: 480px) {
    .header-section {
      flex-direction: column;
      gap: 1rem;
    }
  
    .add-button {
      width: 100%;
    }
  
    .search-input {
      max-width: 100%;
    }
  
    .form-actions {
      flex-direction: column;
      gap: 0.5rem;
    }
  
    .submit-button,
    .cancel-button,
    .delete-button {
      width: 100%;
    }
  }
  </style>