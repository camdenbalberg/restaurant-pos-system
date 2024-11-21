<template>
    <div class="screens-section">
      <h2>Screen Management</h2>
      <div class="screens-content">
        <div class="screens-buttons">
          <button class="screens-button" @click="lockScreen('Customer')">Lock Customer Screen</button>
          <button class="screens-button" @click="lockScreen('Cashier')">Lock Cashier Screen</button>
          <button class="screens-button" @click="lockScreen('Menu_Board')">Lock Menu Board</button>
        </div>
        <div v-if="loading" class="loading-spinner">
          Loading...
        </div>
      </div>
    </div>
  </template>
  
  <script>
  import api from '@/api';
  import axios from 'axios';

export default {
  name: 'ScreensSection',
  data() {
    return {
      loading: false,
      passkey: "",
    };
  },
  methods:{
    async lockScreen(screenType) {
      this.passkey = prompt("Enter a six digit pin ie \'123456\'' ");
      if (!/^\d{6}$/.test(this.passkey)) {
        alert("Invalid PIN. Please enter a six-digit number.");
        return;
      }
      this.loading = true;
      
      switch (screenType) {
        case 'Customer':
          console.log('Locking Customer');
          break;
        case 'Cashier':
          console.log('Locking Cashier')
          break;
        case 'Menu_Board':
          console.log('Locking Menu Board');
          break;
        default:
          console.log('Unknown screen type');
          break;
      }
      
    }
  }
}
  </script>
  
  <style scoped>
  .screens-section {
    padding: 2rem;
    background-color: white;
    border-radius: 8px;
    box-shadow: 0 2px 4px rgba(0,0,0,0.1);
  }
  .screens-buttons {
    display: flex;
    justify-content: center; /* Center horizontally */
    align-items: center;
    flex-wrap: wrap;
    gap: 15px;
    margin-top: 20px;
  }
  .screens-button {
    color: black;
    background-color: aliceblue;
    border: 2px solid black;
    width: 250px;
    padding: 20px;
    font-size: 16px;
    cursor: pointer;
    border-radius: 5px;
  }
  .loading-spinner {
    margin-top: 20px;
    text-align: center;
    font-weight: bold;
    color: #555;
  }
  </style>