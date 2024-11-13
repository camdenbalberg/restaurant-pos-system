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
              @click="setCurrentSection(item.name)"
            >
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
  import InventorySection from './sections/InventorySection.vue';
  import EmployeesSection from './sections/EmployeesSection.vue';
  import ScreensSection from './sections/ScreensSection.vue';
  import AnalyticsSection from './sections/AnalyticsSection.vue';
  
  export default {
    // Register the component
    components: {
      InventorySection
    },
    data() {
        return {
        currentSection: '',
        navItems: [
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
    computed: {
      currentComponent() {
        // Map section names to component names
        const componentMap = {
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
      }
    }
  };
  </script>
  
  <style scoped>
  .manager-components {
    width: 100%;
    min-height: 100vh;
    background-color: #f5f5f5;
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
