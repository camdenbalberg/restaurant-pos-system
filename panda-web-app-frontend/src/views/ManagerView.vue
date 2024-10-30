<template>
    <div class="manager-view">
      <ManagerComponents />
    </div>
  </template>
  
  <script>
  import ManagerComponents from '../components/ManagerComponents.vue';
  
  export default { 
    name: 'ManagerView',
    components: {
      ManagerComponents,
    },
  };
  </script>
  
  <style scoped>
  .manager-view {
    width: 100%;
    min-height: 100vh;
  }
  </style>