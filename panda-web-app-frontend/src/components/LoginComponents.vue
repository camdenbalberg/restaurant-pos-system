<template>
  <div class="login-screen">
    <img src="../assets/biglogo.png" id="big-logo" alt="12Team12 Main Logo">
    <h1 class="slogan"><strong><i>Very good, very sugar</i></strong></h1>
    
    <div class="login-text-fields">
      <label for="username">Username:</label>
      <input type="text" id="login-username" v-model="username">
      <br>
      <label for="password">Password:</label>
      <input type="password" id="login-password" v-model="password">
      <br id="bigBr">
      <button @click="submitForm">
        {{ buttonText }}
      </button>
    </div>

  </div>
</template>

<script>
import api from '@/api';

export default {
  data() {
    return {
      username: '',
      password: '',
      buttonText: 'Submit',
    }
  },
  methods: {
    async submitForm() {

      try {
        this.buttonText = "Loading..."
        console.log(import.meta.env.VITE_API_BACKEND_URL);
        const response_pwd = await api.get(`/employees/by_password/${this.password}`);
        this.employees_pwd = response_pwd.data;
        const response_usr = await api.get(`/employees/by_employee_id/${this.username}`);
        this.employees_usr = response_usr.data;
        let found = false;
        for (let i = 0; i < this.employees_pwd.length; i++) {
          if (this.employees_pwd[i].email == this.employees_usr[0].email) {
            console.log("Matching employee found");
            found = true;
            // https://router.vuejs.org/guide/essentials/navigation.html
            return this.$router.push('/');
          }
        }
        if (!found) {
          console.log("Invalid");
        }

      } catch (error) {
        console.error('Error fetching employees:', error);
      } 
      this.buttonText = "Submit\nInvalid"
    }
  }
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
    --textColor: #33353D;
    --subTextColor: #33353D;

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

