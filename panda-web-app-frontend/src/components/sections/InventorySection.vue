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
      </div>
    </div>
  </template>
  
  <script>
  export default {
    name: 'InventorySection'
  }
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