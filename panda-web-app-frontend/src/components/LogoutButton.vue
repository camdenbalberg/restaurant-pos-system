<template>
    <button id="logout" @click="logout">
        Logout
    </button>
</template>

<script>
import { useStore } from 'vuex';
import { useRouter } from 'vue-router';
import shared from '../shared'
export default {

  // @vuese
  // Enable flash scaffolding functionality from a shared js file.
  created() {
    this.flashScaffolding = shared.flashScaffolding
  },

  // @vuese
  // Set created user in store to null and redirect to login page
  setup() {
    const store = useStore();
    const router = useRouter();

    const logout = async () => {
      await store.dispatch('logout'); // Call the logout action
      router.push('/login'); // Redirect to the login page
      this.flashScaffolding();
    };

    return { logout };
  },
};
</script>
