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
        // Prompt for menu name, price, and recipe
        const menuName = prompt("Enter menu name:");
        const price = prompt("Enter price:");
        const recipeInput = prompt("Enter recipe (comma-separated integers):");
        const category = prompt("Enter category (meal, entree, side, drink, appetizer)");

        if (menuName && price && category) {

          // Here you can process the new menu item (e.g., save it to a list or send to a server)
          const data = {
            menu_name: menuName,
            price: parseFloat(price),
            category: category
          };
          const recipe = recipeInput.split(',').map(id => id.trim());
            
          console.log(data);

          const response = await axios.post('/api/v1/menu_items/add_menu_item', data)
          .then(response => {
            console.log('Menu item added:', response.data);
            //if successfully added menu item then add recipe.
            console.log(response.data.menu_id, " AHHHHH ", recipe.join(','))
            this.addRecipe(response.data.menu_id, recipe);

            // Optionally, alert the user or refresh data after success
            alert(`Added ${category}${menuName} with price $${price} and recipe ingredients:`);
          })
          .catch(error => {
            console.error('Error adding menu item:', error.response ? error.response.data : error.message);
            alert('Failed to add menu item.');
          });

        } else {
          alert("Please fill out all fields.");
        }
      },

      async addRecipe(menuId, recipe) {
        const data = {
          menu_id: menuId,
          recipe: recipe
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