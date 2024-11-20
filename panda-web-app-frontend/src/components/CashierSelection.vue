<template>
    <div v-if="loading">Loading...</div>

    <div v-if="!loading && !filteredMenuItems.length">No menu items available.</div>

    <div v-if="!loading && filteredMenuItems.length" class="cashier-selection">
      <div class="cashier-selection-category">{{category}}</div>
      <ul class="cashier-selection-list">
        <li v-for="item in filteredMenuItems">
          <button class="menu-item" :id="item.menu_id" @click="$emit('selectItem', item)">{{item.menu_name}}</button>
        </li>
      </ul>
    </div>
  </template>
  
  <script>
  import api from '@/api';
  
  export default {
    name: 'CashierSelection',
    props: {
      category: {
        type: String,
        required: true,
      },
    },
    emits: ["selectItem"],
    data() {
      return {
        items: [],
        loading: true,
      };
    },
    computed: {
      filteredMenuItems() {
        return this.items.filter(item => item.category === this.category);
      },
    },
    mounted() {
      this.fetchMenuItems();
    },
    methods: {
      async fetchMenuItems() {
        try {
          // Example usage of env var
          console.log(import.meta.env.VITE_API_BACKEND_URL);
          const response = await api.get('/menu_items');
          this.items = response.data;
        } catch (error) {
          console.error('Error fetching menu items:', error);
        } finally {
          this.loading = false;
        }
      },
    },
  };
  </script>
  
<style scoped>
  .cashier-selection {
    width: 80%;
    margin-bottom: 2em;
  }

  .cashier-selection-category {
    margin-left: 0.5em;
    margin-bottom: 0.5em;
    text-align: left;
    font-weight: 600;
    font-size: 125%;
    text-transform: capitalize;
  }

  .cashier-selection-list {
    display: grid;
    grid-template-columns: 1fr 1fr 1fr 1fr;
    grid-auto-rows: 1fr;
    gap: 1.5em 1em;
  }

  .menu-item {
    width: 100%;
    height: 100%;
    margin: 0;
    padding: 0.5em;
    border: 1px solid #ccc;
    border-radius: 4px;
    background-color: #f9f9f9;
  }

</style>
