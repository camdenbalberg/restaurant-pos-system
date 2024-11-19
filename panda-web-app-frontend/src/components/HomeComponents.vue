<template>
    <div class="home">
      <img src="../assets/biglogo.png" id="big-logo" alt="12Team12 Main Logo">
      <h1 class="slogan"><strong><i>Very good, very sugar</i></strong></h1>
      <ul class="home-links">
        <li>
          <RouterLink to="/cashier">
              <button class="home-item">Cashier</button>
          </RouterLink>
          
          <RouterLink to="/kitchen">
              <button class="home-item">Kitchen</button>
          </RouterLink>

          <RouterLink to="/customer">
              <button class="home-item">Customer</button>
          </RouterLink>

          <RouterLink to="/manager">
              <button class="home-item">Manager</button>
          </RouterLink>
          
          <RouterLink to="/about">
              <button class="home-item">About</button>
          </RouterLink>

          <RouterLink to="/login">
              <button class="home-item">Login</button>
          </RouterLink>
        </li>
      </ul>
    </div>
</template>

<script>
import { computed, onMounted } from 'vue';
import { useStore } from 'vuex';

export default {
  setup() {
    const store = useStore();

    const isAuthenticated = computed(() => store.state.isAuthenticated);
    const user = computed(() => store.state.user);

    onMounted(() => {
      store.dispatch('checkAuth'); // Check authentication on component mount
    });

    return { isAuthenticated, user };
  },
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
    margin: 50px;
    font-size: 30px;
    padding-top: 50px;
    padding-bottom: 50px;
    padding-right: 100px;
    padding-left: 100px;
  }
</style>

