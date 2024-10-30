<template>
  <div class="login-screen">
    <h1>Login Screen</h1>

    <img src="../assets/biglogo.png" id="big-logo" alt="12Team12 Main Logo">

    <div class="login-text-fields">
      <label for="username">Username:</label>
      <input type="text" id="login-username" v-model="username">
      <br>
      <label for="password">Password:</label>
      <input type="password" id="login-password" v-model="password">
      <br id="bigBr">
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
    /* Center the image */
    margin: auto;
    width: 50%;
  }

  label {
    font-size: 30px;
    width: 100px;
  }

  input {
    padding: 10px;
  }

  button {
    margin-top: 70px;
    font-size: 30px;
    padding-top: 25px;
    padding-bottom: 25px;
    padding-right: 50px;
    padding-left: 50px;
  }
</style>

