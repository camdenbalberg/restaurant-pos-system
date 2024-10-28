<!-- src/views/Login.vue -->
<template>
  <div>
    <h1>Login View</h1>
    <LoginComponents />
  </div>
</template>

<script>
import LoginComponents from '../components/LoginComponents.vue'; // Adjust path if necessary

export default {
  name: 'Login',
  components: {
    LoginComponents,
  },
};
</script>

