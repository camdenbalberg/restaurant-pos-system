<template>
    <div>Redirecting...</div>
</template>

<script>
 import api from "@/api";
 import { mapActions } from 'vuex';

 export default {
     methods: {
         ...mapActions(['setUser', 'setToken']),
     },
     async created() {
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
