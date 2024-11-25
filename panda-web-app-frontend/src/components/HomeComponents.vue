<template>
    <div class="home">
      <img src="../assets/biglogo.png" id="big-logo" alt="12Team12 Main Logo">
      <h1 class="slogan"><strong><i>Very good, very sugar</i></strong></h1>
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
