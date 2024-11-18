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
                 const response = await api.get('/auth/:provider/callback', { headers: { Authorization: `Bearer ${token}` } });
                 const { token: jwt, user } = response.data;
                 this.setToken(jwt);
                 this.setUser(user);
                 this.$router.push( { name: 'home' } );
             } catch (err) {
                 console.error("Failed to authenticate", err);
                 this.$router.push( { name: 'login' } );
             }
         }
     },
 };
</script>
