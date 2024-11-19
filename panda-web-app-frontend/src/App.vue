<!-- src/App.vue -->
<template>
  <div id="app">
    <router-view />
  </div>
</template>

<script>
import { onMounted } from 'vue';
import { useStore } from 'vuex';
export default {
  name: 'App',
  methods: {
    setup() {
      const store = useStore();

      onMounted(() => {
        store.dispatch('checkAuth'); // Check auth on app load
      });
    },
  }
};
</script>

<style>

</style>

