<template>
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
    height: 100vh;
    padding: 1em 2em;
  }

  .order-items {
    width: 33%;
    overflow-y: scroll;
    border: 1px solid white;
    padding: 1em;
  }

  .menu-items {
    overflow-y: scroll;
    border: 1px solid white;
  }
</style>