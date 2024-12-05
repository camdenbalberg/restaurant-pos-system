<template>
    <div class="home">
      <!-- Show logo and slogan -->
      <img src="../assets/biglogo.png" id="big-logo" alt="12Team12 Main Logo">
      <h1 class="slogan"><strong><i>Very good, very sugar</i></strong></h1>
      <!-- Show the various screens the user can travel to from the home screen -->
      <ul class="home-links">
        <li>
          <button class="home-item" @click="travel('/cashier')">Cashier</button>
          <button class="home-item" @click="travel('/kitchen')">Kitchen</button>
          <button class="home-item" @click="travel('/customer')">Customer</button>
          <button class="home-item" @click="travel('/manager')">Manager</button>
          <button class="home-item" @click="travel('/about')">About</button>
          <!-- <button class="home-item" @click="travel('/login')">Login</button> -->
        </li>
      </ul>
      <!-- Logout button is separate from other links -->
      <ul class="home-links">
        <li><LogoutButton /></li>
      </ul>
    </div>
</template>

<script>
  import LogoutButton from "../components/LogoutButton.vue";
  export default {
    data() {
      return {
      }
    },
    created() {

    },
    methods: {
      // @vuese
      // When a button on the home screen is clicked, push the home page to the back stack and navigate to the requested screen.
      // Back stack is used so when back button is clicked, the previous page can be loaded.
      async travel(destination) {
        this.$backStack.push("/");
        return this.$router.push(destination);
      },
    },
    components: {
      LogoutButton,
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
    --subTextColor: #4c4f69;

    color: var(--textColor);
  }

  /* Team logo */
  img {
    scale: 0.75;
    /* Center the image */
    margin: auto;
    width: 50%;
    z-index: 1;
  }

  label {
    font-size: 30px;
    width: 100px;
  }

  input {
    padding: 10px;
  }

  button {
    margin: 20px;
    font-size: 30px;
    padding-top: 50px;
    padding-bottom: 50px;
    padding-right: 100px;
    padding-left: 100px;
  }
</style>
