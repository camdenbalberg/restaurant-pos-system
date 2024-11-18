<template>
    <button id="logout" @click="logout">
        Logout
    </button>
</template>

<script>
 import api from "@/api";
 import { mapActions } from 'vuex';

 export default {
     name: 'LogoutButton',
     methods: {
         ...mapActions(['logout']),
     },
 }
</script>
