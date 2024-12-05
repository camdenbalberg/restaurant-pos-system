<template>
  <div>Redirecting...</div>
</template>

<script>
  import api from "@/api";
  import { mapActions } from 'vuex';
  import shared from '../shared'

  export default {
    methods: {
        ...mapActions(['setUser', 'setToken']),
    },

    // @vuese
    // Create a session for authenticated user if authenticated and verified with the backend, redirect to home page
    // Otherwise, do not authenticate user and redirect to login page
    async created() {
      this.flashScaffolding = shared.flashScaffolding

      const urlParams = new URLSearchParams(window.location.search);
      const token = urlParams.get('token');

      if (token) {
        try {
          // Directly save the token from the URL
          this.setToken(token);

          // Optionally, if user data is passed in the query params, save it too
          const user = JSON.parse(urlParams.get('user'));
          if (user) {
              this.setUser(user);
          }

          // Redirect the user to the home page
          this.$router.push({ name: 'home' });
          this.flashScaffolding();
        } catch (err) {
          console.error("Failed to authenticate", err);
          this.$router.push({ name: 'login' });
        }
      } else {
        console.error("No token provided");
        this.$router.push({ name: 'login' });
      }
    },
  };
</script>
