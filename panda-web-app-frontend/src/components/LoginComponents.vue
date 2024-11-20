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
  <div>
    <button id="google-signin-btn" @click="googleLogin">
      Sign in with Google
    </button>
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
    googleLogin() {
      window.location.href = 'http://localhost/auth/google_oauth2';
    },
    async submitForm() {
      try {
        if (this.username && this.password) {
          // Manual login flow
          const response = await api.post('http://localhost/auth/login', {
            username: this.username,
            password: this.password,
          });
          if (response.data.success) {
            console.log('Login successful:', response.data.user);
            this.$router.push('/');
          } else {
            console.log('Invalid login:', response.data.error);
            this.buttonText = "Submit\nInvalid";
          }
        }
      } catch (error) {
        console.error('Error logging in:', error);
      }
    },
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
