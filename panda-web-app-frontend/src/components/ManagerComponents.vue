<template>
    <div class="manager-components">
      <!-- Navigation Bar -->
      <nav class="nav-bar">
        <div class="nav-container">
          <div class="nav-brand">
            <h2><strong>Manager View</strong></h2>
          </div>
          <div class="nav-links">
            <button 
              v-for="(item, index) in navItems" 
              :key="index"
              :class="['nav-button', { active: currentSection === item.name }]"
              @click="setCurrentSection(item.name)">
              {{ item.label }}
            </button>
            
          </div>
        </div>
      </nav>
      <!-- Content Section -->
      <div class="content-section">
        <transition name="fade" mode="out-in">
          <keep-alive>
            <component 
              :is="currentComponent" 
              v-if="currentSection"
              :key="currentSection"
            />
            <div v-else class="placeholder-content">
              <h3>Please select a section</h3>
              <p>Select a section from the navigation bar above to get started</p>
            </div>
          </keep-alive>
        </transition>
      </div>
    </div>
  </template>
  
  <script>
  import api from '@/api';
  // Import the InventorySection component
  import ImageUpload from '../components/ImageUpload.vue';
  import InventorySection from './sections/InventorySection.vue';
  import EmployeesSection from './sections/EmployeesSection.vue';
  import ScreensSection from './sections/ScreensSection.vue';
  import AnalyticsSection from './sections/AnalyticsSection.vue';
  import MenuSection from './sections/MenuSection.vue';
  import RecipeSection from './sections/RecipeSection.vue';
  import shared from '../shared'
  
  export default {
    // Register the component
    components: {
      InventorySection,
      ImageUpload
    },

    // @vuese
    // Initial fields.
    data() {
        return {
          menuId: '',
        currentSection: '',
        navItems: [
          {
            name: 'menu', 
            label: 'Menu',
            description: 'Add, remove, and manage menu items.'
          },
          {
            name: 'recipe',
            label: 'Recipe',
            description: 'Add, remove, and manage recipes.'
          },
          { 
            name: 'inventory', 
            label: 'Inventory',
            description: 'Add different menu items including meal combos, entrees, sides, drinks, and appetizers.'
          },
          { 
            name: 'employees', 
            label: 'Employees',
            description: 'Add, remove, and manage employees.'
          },
          { 
            name: 'screens', 
            label: 'Screens',
            description: 'See all the different screesn and select them.'
          },
          { 
            name: 'analytics', 
            label: 'Analytics',
            description: 'Add X report button and display table/graph, add Z report button and display table/graph, add sales report, '
          }
        ]
      }
    },

  
    // @vuese
    // Enable flash scaffolding functionality from a shared js file.
    created() {
      this.flashScaffolding = shared.flashScaffolding
    },
    computed: {
      currentComponent() {
        // Map section names to component names
        const componentMap = {
          'menu': MenuSection,
          'recipe': RecipeSection,
          'inventory': InventorySection,
            'employees': EmployeesSection,
            'screens': ScreensSection,
            'analytics': AnalyticsSection
        };
        return componentMap[this.currentSection];
      }
    },
    methods: {
      setCurrentSection(section) {
        this.currentSection = section;
      },
      async handleImageUpload({menuId, file}) {
        if (!file) {
          console.error('Missing file');
          alert('Menu ID and Image are required!');
          return;
        }
        if (!menuId) {
          console.error('Missing menuId');
          alert('Menu ID and Image are required!');
          return;
        }
        

        try {
          const formData = new FormData();
          formData.append('image', file);
          formData.append('menu_id', menuId);

          const response = await api.patch(`menu_items/${menuId}/update_image`, formData, {
            headers: { 'Content-Type': 'multipart/form-data' },
            // params: { menu_id: menuId }, 
          });

          console.log('Image uploaded successfully:', response.data);
          alert('Image uploaded successfully!');
          this.flashScaffolding();
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
    }
  };
  </script>
  
  <style scoped>
  .manager-components {
    width: 100%;
    min-height: 100vh;
    background-color: #f5f5f5;
  }
 
  .inventory-section {
    padding: 1rem;
    background-color: white;
    border-radius: 8px;
    box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
  }
 
  .nav-bar {
    background-color: #2c3e50;
    padding: 1rem 0;
    box-shadow: 0 2px 4px rgba(0,0,0,0.1);
  }
  
  .nav-container {
    max-width: 1200px;
    margin: 0 auto;
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 0 2rem;
  }
  
  .nav-brand h2 {
    color: white;
    margin: 0;
    font-size: 1.5rem;
  }
  
  .nav-links {
    display: flex;
    gap: 1rem;
  }
  
  .nav-button {
    background-color: transparent;
    border: none;
    color: white;
    padding: 0.5rem 1rem;
    cursor: pointer;
    font-size: 1rem;
    border-radius: 4px;
    transition: background-color 0.3s ease;
  }
  
  .nav-button:hover {
    background-color: rgba(255,255,255,0.1);
  }
  
  .nav-button.active {
    background-color: rgba(255,255,255,0.2);
  }
  
  .content-section {
    padding: 2rem;
    max-width: 1200px;
    margin: 0 auto;
  }
  
  .placeholder-content {
    text-align: center;
    padding: 2rem;
    background-color: white;
    border-radius: 8px;
    box-shadow: 0 2px 4px rgba(0,0,0,0.1);
  }
  
  .fade-enter-active,
  .fade-leave-active {
    transition: opacity 0.3s ease;
  }
  
  .fade-enter-from,
  .fade-leave-to {
    opacity: 0;
  }
  </style>
