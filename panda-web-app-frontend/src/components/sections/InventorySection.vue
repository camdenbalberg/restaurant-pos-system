<template>
  <div class="inventory-section">
    <h2>Inventory Management</h2>
    <div class="inventory-content">
      <div class="inventory-stats">
        <div class="stat-card">
          <h4>Total Items</h4>
          <p>150</p>
        </div>
        <div class="stat-card">
          <h4>Low Stock Items</h4>
          <p>12</p>
        </div>
      </div>
      <button @click="addMenuItem">Add menu item</button>
    </div>
  </div>
</template>

  
<script>
import axios from 'axios';

  export default {
    name: 'InventorySection',
    methods: {
      async addMenuItem() {
        const menuName = prompt("Enter menu name:");
        const category = prompt("Enter category (meal, entree, side, drink, appetizer)");
        const price = prompt("Enter price:");
        const recipeInput = prompt("Enter recipe (comma-separated integers):");
        const quantityInput = prompt("For the recipe items you gave list their quantities (comma-separated integers):");
        
        // Validate inputs
        const error = this.validateInputs(menuName, category, price, recipeInput, quantityInput);
        if (error) {
          alert(error);
          return;
        }
        
        const priceNum = parseFloat(price);
        const recipe = recipeInput.split(',').map(id => id.trim());
        const quantities = quantityInput.split(',').map(id => id.trim());

        const data = {
          menu_name: menuName,
          price: priceNum,
          category: category
        };

        try {
          // Make the request to add the menu item
          const response = await axios.post('/api/v1/menu_items/add_menu_item', data);
          console.log('Menu item added:', response.data);

          // If the menu item is successfully added, then add the recipe
          this.addRecipe(response.data.menu_id, recipe, quantities);

          // Alert the user of success
          alert(`Added ${category} ${menuName} with price $${price} and recipe ingredients: ${recipe.join(', ')}`);
        } catch (error) {
          console.error('Error adding menu item:', error.response ? error.response.data : error.message);
          alert('Failed to add menu item.');
        }
      },

      async addRecipe(menuId, recipe, quantities) {
        const data = {
          menu_id: menuId,
          recipe: recipe,
          quantities: quantities
        };
        console.log("Starting add recipe: ", data);
        try {
          const response = await axios.post('/api/v1/recipes/add_recipe', data);

          console.log("Recipe added successfully:", response.data);
          alert('Recipe added successfully.');
          
        } catch (error) {
          console.error('Error adding recipe:', error.response ? error.response.data : error.message);
          alert('Failed to add recipe.');
        }
      },

      validateInputs(menuName, category, price, recipeInput, quantityInput) {
        if (!menuName || !category || !price || !recipeInput || !quantityInput) {
          return "Please fill out all fields.";
        }

        // Category validation: Check if category is one of the allowed options
        const validCategories = ['meal', 'entree', 'side', 'drink', 'appetizer'];
        if (!validCategories.includes(category.toLowerCase())) {
          return "Invalid category. Please select one from: meal, entree, side, drink, appetizer.";
        }

        // Price validation: Ensure price is a valid number and >= 0
        const priceNum = parseFloat(price);
        if (isNaN(priceNum) || priceNum < 0) {
          return "Price must be a number greater than or equal to 0.";
        }

        // Recipe input validation: Ensure the recipe is a comma-separated list of integers
        const recipe = recipeInput.split(',').map(id => id.trim());
        if (recipe.some(id => isNaN(parseInt(id)))) {
          return "Recipe input must be a list of integers.";
        }

        // Quantity input validation: Ensure quantities are a comma-separated list of integers
        const quantities = quantityInput.split(',').map(id => id.trim());
        if (quantities.some(qty => isNaN(parseInt(qty)))) {
          return "Quantity input must be a list of integers.";
        }

        // Ensure the number of quantities matches the number of recipes
        if (recipe.length !== quantities.length) {
          return "The number of quantities must match the number of recipes.";
        }

        // All checks passed, return null indicating no error
        return null;
      }
    }
  };
</script>

  
  <style scoped>
  .inventory-section {
    padding: 2rem;
    background-color: white;
    border-radius: 8px;
    box-shadow: 0 2px 4px rgba(0,0,0,0.1);
  }
  
  .inventory-stats {
    display: flex;
    gap: 1rem;
    margin-top: 1rem;
  }
  
  .stat-card {
    background-color: #f8f9fa;
    padding: 1rem;
    border-radius: 6px;
    min-width: 150px;
    text-align: center;
  }
  
  .stat-card h4 {
    margin: 0;
    color: #6c757d;
  }
  
  .stat-card p {
    margin: 0.5rem 0 0;
    font-size: 1.5rem;
    font-weight: bold;
    color: #2c3e50;
  }
  </style>