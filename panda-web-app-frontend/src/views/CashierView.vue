<template>
  <h1>Cashier View</h1>
  <div class="cashier-view">
    <!-- Items in Order -->
     <div class="order-items">
      I am an order!
     </div>

    <!-- Menu Items -->
    <div class="menu-items">
      <CashierMenuItems />
    </div>

  </div>
</template>
  
<script>
  import CashierMenuItems from '@/components/CashierMenuItems.vue';
  
  export default {
    name: 'Cashier View',
    components: {
      CashierMenuItems,
    },
  };
</script>

<style scoped>
  .cashier-view {
    display: flex;
    width: 100%;
  }

  .order-items {
    width: 33%;
    height: 75%;
    order: 1;
    overflow-y: scroll;

    border: 1px solid white;
    padding: 1em;
  }

  .menu-items {
    width: 67%;
    height: 100%;
    order: 2;
    overflow-y: scroll;

    border: 1px solid white;
    padding: 1em;
  }
</style>