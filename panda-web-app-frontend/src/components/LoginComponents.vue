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

</style>

