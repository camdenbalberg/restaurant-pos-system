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

    background: url("./assets/bg.jpg");
    background-repeat: no-repeat;
    background-size: cover;
  }

  #app {
    font-family: Avenir, Helvetica, Arial, sans-serif;
    -webkit-font-smoothing: antialiased;
    -moz-osx-font-smoothing: grayscale;
    text-align: center;
    color: #2c3e50;
    margin-top: 0px;
    margin-bottom: 0px;
    margin-right: 0px;
    margin-left: 0px;

  }

  input {
    background-color: var(--surfaceColor);
    margin-top: 15px;
    margin-bottom: 15px;
    margin-left: 25px;
    margin-right: 25px;
  }

  input:focus {
    background-color: var(--accentColorWeak);
  }

  button {
    background-color: var(--surfaceColor);
    scale: 1;
    transition: scale 0.5s ease;
    transition: background-color 0.25s ease;
  }

  button:hover {
    background-color: var(--accentColorWeak);
    scale: 1.1;
  }

  button:active {
    scale: 1;
    background-color: var(--accentColor);
  }
</style>

