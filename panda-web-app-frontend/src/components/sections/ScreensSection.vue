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

   // @vuese
  /**
   * @data
   * @description
   * Initial fields for the component.
   * 
   * - `loading`: A boolean flag to indicate loading state (true when the screen is being locked).
   * - `passkey`: Stores the PIN entered by the user to lock the screen.
   */
  data() {
    return {
      loading: false,
      passkey: "",
    };
  },
  methods:{
     /**
     * @method lockScreen
     * @description
     * This method locks the specified screen type (Customer, Cashier, or Menu Board) after the user 
     * enters a valid six-digit PIN. It triggers a request to the API to lock the screen and then redirects 
     * to the corresponding page based on the screen type.
     * 
     * @param {string} screenType - The type of screen to lock. It can be 'Customer', 'Cashier', or 'Menu_Board'.
     * @returns {void}
     */
    async lockScreen(screenType) {
      this.passkey = prompt("Enter a six digit pin ie \'123456\'' ");
      if (!/^\d{6}$/.test(this.passkey)) {
        alert("Invalid PIN. Please enter a six-digit number.");
        return;
      }
      
      try {
        this.loading = true;
        await api.lockScreen({
          screen: {
            screenType: screenType,
            passkey: this.passkey,
          },
        });
        
        this.$emit('screen-locked', { screenType, passkey: this.passkey });
        switch(screenType){
          case 'Menu_Board':
            this.$router.push('/menu_board');
            break;
          case 'Customer':
            this.$router.push('/customer');
            break;
          case 'Cashier':
            this.$router.push('/cashier');
            break;
          default:
            alert("Error while redirecting");
            break;
        }
        // alert(`${screenType} screen locked successfully!`);
      } catch (error) {
        console.error("Error locking screen:", error);
        alert("Failed to lock the screen.");
      } finally {
        this.loading = false;
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