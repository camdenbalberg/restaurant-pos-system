<template>
  <div class="login-screen">
    <img src="../assets/biglogo.png" id="big-logo" alt="12Team12 Main Logo">
    <h1 class="slogan"><strong><i>Very good, very sugar</i></strong></h1>

    <div class="login-text-fields">
      <label for="login-username">Username:</label>
      <input type="text" id="login-username" v-model="username">
      <br>
      <label for="login-password">Password:</label>
      <input type="password" id="login-password" v-model="password">
      <br id="bigBr">
      <button id="submit_login_button" @click="submitForm">
        {{ buttonText }}
      </button>
    </div>
  </div>
  <div>
    <button
      id="google_login_button"
      @click="googleLogin"
      :class="{ 'clicked': isClicked }"
      type="button"
      class="text-white bg-[#4285F4] hover:bg-[#4285F4]/90 focus:ring-4 focus:outline-none focus:ring-[#4285F4]/50 font-medium rounded-lg text-sm px-5 py-2.5 text-center inline-flex items-center dark:focus:ring-[#4285F4]/55 me-2 mb-2"
    >
      <svg
        class="w-8 h-8 me-4"
        aria-hidden="true"
        xmlns="http://www.w3.org/2000/svg"
        fill="currentColor"
        viewBox="0 0 18 19"
      >
        <path
          fill-rule="evenodd"
          d="M8.842 18.083a8.8 8.8 0 0 1-8.65-8.948 8.841 8.841 0 0 1 8.8-8.652h.153a8.464 8.464 0 0 1 5.7 2.257l-2.193 2.038A5.27 5.27 0 0 0 9.09 3.4a5.882 5.882 0 0 0-.2 11.76h.124a5.091 5.091 0 0 0 5.248-4.057L14.3 11H9V8h8.34c.066.543.095 1.09.088 1.636-.086 5.053-3.463 8.449-8.4 8.449l-.186-.002Z"
          clip-rule="evenodd"
        />
      </svg>
      Sign in With Google
    </button>
  </div>
  <button id = "skip_login_button" @click="skipForm">Skip Login As Customer</button>
</template>

<script>
import api from '@/api';
import shared from '../shared'

export default {

  // @vuese
  // Initial fields.
  data() {
    return {

      // @vuese
      // The username entered by the user.
      // type: {String}
      username: '',

      //
      // The password entered by the user.
      // type: {String}
      password: '',

      // The text displayed on the submit button.
      // default: 'Submit'
      // type: {String}
      buttonText: 'Submit',
    }
  },

  created() {
    // @vuese
    // Enable flash scaffolding functionality from a shared js file.
    this.flashScaffolding = shared.flashScaffolding
  },

  methods: {

    // @vuese
    // Initiates the Google login flow by redirecting to Google OAuth.
    // Changes the button state briefly for a visual effect.
    googleLogin() {
      this.isClicked = true;
      setTimeout(() => {
        this.isClicked = false;
      }, 1000); // Animation duration (1 second)

      // Call OAuth flow initiater
      this.googleInitiateFlow();
    },
    googleInitiateFlow() {
      window.location.href = 'http://localhost/auth/google_oauth2';
    },

    // @vuese
    // Normal login without using Google OAuth.
    // Navigates to the home screen on success and not if there is an error or invalid credentials.
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
            this.$backStack.push(this.$route.name);
            this.$router.push('/');
            this.flashScaffolding();
          } else {
            console.log('Invalid login:', response.data.error);
            alert("Invalid credentials.");
            this.buttonText = "Submit\nInvalid";
          }
        }
      } catch (error) {
        alert("Invalid credentials.");
        console.error('Error logging in:', error);
      }
    },
    // @vuese
    // Allows to skip login process (for development use)
    async skipForm() {
      try {
        if (true) {
          // Manual login flow
          // this.username = "5"
          // this.password = "b455mord";
          const response = await api.post('http://localhost/auth/login', {
            username: "5",
            password: "b455mord",
          });
          if (response.data.success) {
            console.log('Login successful:', response.data.user);
            this.$backStack.push(this.$route.name);
            this.$router.push('/customer');
            this.flashScaffolding();
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

#submit_login_button {
  margin-top: 70px;
  font-size: 30px;
  padding-top: 25px;
  padding-bottom: 25px;
  padding-right: 50px;
  padding-left: 50px;
}

#google_login_button {
  margin-top: 70px;
  font-size: 30px;
  padding-top: 25px;
  padding-bottom: 25px;
  padding-right: 50px;
  padding-left: 50px;
}

.clicked {
  animation: color-change 1s forwards;
}

@keyframes color-change {
  0% {
    background-color: #4285f4;
  }
  50% {
    background-color: #34a853;
  }
  100% {
    background-color: #ea4335;
  }
}
</style>
