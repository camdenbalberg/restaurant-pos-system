<template>
  <div v-if="loading">Loading...</div>

  <div v-if="!loading && !filteredMenuItems.length">No menu items available.</div>

  <div v-if="!loading && filteredMenuItems.length" class="cashier-selection">
    <div class="cashier-selection-category">{{ category }}</div>
    <ul class="cashier-selection-list">
      <li v-for="item in filteredMenuItems" :key="item.menu_id">
        <button
          class="menu-item"
          :id="item.menu_id"
          :disabled="isDisabled(item)"
          :class="{ selected: isSelected(item), disabled: isDisabled(item) }"
          @click="handleSelection(item)"
        >
          {{ item.menu_name }}
        </button>
      </li>
    </ul>
    <!-- <p class="selection-count">
      Selections: {{ selectedItems.length }}/{{ maxSelections }}
    </p> -->
  </div>
</template>

<script>
import api from '@/api';

// @vuese
// @group CashierView
export default {
  name: 'CashierSelection',
  props: {
    // The category of this menu selection.
    category: {
      type: String,
      required: true,
    },
    // The max number of selections you can make from this category.
    maxSelections: {
      type: Number,
      required: true,
    },
    // The items selected from this category.
    selectedItems: {
      type: Array,
      required: true,
    },
  },
  emits: ["selectItem"],

  // @vuese
  // Initial fields.
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
        const response = await api.get('/menu_items');
        this.items = response.data;
      } catch (error) {
        console.error('Error fetching menu items:', error);
      } finally {
        this.loading = false;
      }
    },
    isSelected(item) {
      return this.selectedItems.some(selected => selected.menu_id === item.menu_id);
    },
    isDisabled(item) {
      return this.selectedItems.length >= this.maxSelections && !this.isSelected(item);
    },
    handleSelection(item) {
      if (!this.isDisabled(item)) {
        // Selects an item from the given display for CashierPopup to handle.
        // @arg the selected item
        this.$emit('selectItem', item);
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
  transition: background-color 0.3s ease;
}

.menu-item.selected {
  background-color: #8a3d3d;
  color: white;
  border-color: #7b3333;
}

.menu-item.disabled {
  background-color: #f1f1f1;
  color: #aaa;
  border-color: #ddd;
  pointer-events: none;
}

.selection-count {
  margin-top: 1em;
  font-weight: 500;
  color: #333;
}
</style>
