<!-- src/App.vue -->
<template>
  <div id="app">
    <h1>Menu Items</h1>
    <router-view />
  </div>
</template>

<script>
export default {
  name: 'App',
};
</script>

<style>
:root {
  --accentColor: #dc8a78;
  --accentColorIntense: #db5132;
  --accentColorWeak: #edbeb4;
  --surfaceColor: #ccd0da;
  --backgroundColor: #eff1f5;
  --borderColor: #dce0e8;
  --textColor: #4c4f69;
  --subTextColor: #5c5f77;
}

#app {
  font-family: Avenir, Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
  color: #2c3e50;
  margin-top: 60px;
}
</style>

