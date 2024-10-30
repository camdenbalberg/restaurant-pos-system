<template>
  <div class="login-screen">
    <h1>Login Screen</h1>

    <img src="../assets/biglogo.png" id="big-logo" alt="12Team12 Main Logo">

    <div class="login-text-fields">
      <label for="username">Username:</label>
      <input type="text" id="login-username" v-model="username">
      <br />
      <label for="password">Password:</label>
      <input type="password" id="login-password" v-model="password">
      <br />
      <button @click="submitForm">Submit</button>
    </div>

  </div>
</template>

<script>
import axios from 'axios';

export default {
  // data() {
  //   return {
  //     menuItems: [],
  //     loading: false,
  //   };
  // },
  // mounted() {
  //   this.fetchMenuItems();
  // },
  // name: '',
  // methods: {

  // },
};
</script>

<style scoped>
  :root {
    --accentColor: #dc8a78;
    --accentColorIntense: #db5132;
    --accentColorWeak: #edbeb4;
    --surfaceColor: #ccd0da;
    --backgroundColor: #eff1f5;
    --borderColor: #dce0e8;
    --textColor: #4c4f69;
    --subTextColor: #5c5f77;

    color: var(--textColor);
  }

  img {
    scale: 0.75;
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

