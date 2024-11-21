<template>
    <div v-if="isLocked" class="lock-overlay">
      <div class="lock-content">
        <h1>Screen Locked</h1>
        <input
          v-model="enteredPasskey"
          type="password"
          placeholder="Enter passkey"
          @keyup.enter="unlockScreen"
        />
        <button @click="unlockScreen">Unlock</button>
        <p v-if="errorMessage" class="error-message">{{ errorMessage }}</p>
      </div>
    </div>
  </template>
  
  <script>
  export default {
    props: {
      lockPasskey: {
        type: String,
        required: true,
      },
    },
    data() {
      return {
        isLocked: true,
        enteredPasskey: "",
        errorMessage: "",
      };
    },
    methods: {
      unlockScreen() {
        if (this.enteredPasskey === this.lockPasskey) {
          this.isLocked = false;
          this.$emit("unlocked");
        } else {
          this.errorMessage = "Incorrect passkey. Please try again.";
        }
      },
    },
  };
  </script>
  
  <style scoped>
  .lock-overlay {
    position: fixed;
    top: 0;
    left: 0;
    width: 100vw;
    height: 100vh;
    background-color: rgba(0, 0, 0, 0.8);
    display: flex;
    justify-content: center;
    align-items: center;
    z-index: 9999;
  }
  
  .lock-content {
    background: #fff;
    padding: 2rem;
    border-radius: 8px;
    text-align: center;
  }
  
  .lock-content h1 {
    margin-bottom: 1rem;
  }
  
  .lock-content input {
    display: block;
    width: 100%;
    padding: 0.5rem;
    margin-bottom: 1rem;
    font-size: 1rem;
  }
  
  .lock-content button {
    padding: 0.5rem 1rem;
    font-size: 1rem;
    cursor: pointer;
  }
  
  .error-message {
    color: red;
    margin-top: 1rem;
  }
  </style>
  