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
  created() {
    this.flashScaffolding = shared.flashScaffolding
  },
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
