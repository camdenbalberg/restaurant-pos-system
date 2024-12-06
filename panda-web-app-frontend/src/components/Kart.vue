<template>
  <link rel="stylesheet" href="https://www.w3schools.com/w3css/4/w3.css"><link rel="stylesheet" href="https://www.w3schools.com/w3css/4/w3.css">


    <div class="popup">
      <h1>Cart</h1>
      <ul>
        <li v-for="(item, ind) in orderedItems" :key="item" class ="meal">
          <div v-for="(i,index) in item" :key="index" class="item">
            <picture>
              <source :srcset="i.image_url ||`../../src/assets/menu/${i.menu_id}.avif`" type="image/avif">
              <img :src="i.image_url ||`../../src/assets/menu/${i.menu_id}.avif`" :alt="i.menu_name">
            </picture>
            <h2>{{ i.menu_name }}</h2>
            <p v-if="i.price > 0">Price: ${{ i.price }}</p>
          </div>
          <button @click="removeItem(ind)">Remove</button>
        </li>
      </ul>
      <div v-if="loading" class="loading-spinner">
        Loading...
      </div>
      <button class="kart-button" @click="$emit('close')">Close</button>
      <button class="kart-button" onclick="document.getElementById('loyalty-modal').style.display='block'" @click="loyaltyScreen = 0">Loyalty</button>
      <button class="kart-button" @click="completeTransaction">Order</button>
      
      <!-- Loyalty information of loaded Customer -->
      <div v-show="phone">Loyalty loaded: ({{ this.phone }}, {{ this.birthday }}, {{ this.points }})</div>
      <div v-show="discountsApplied">Added discounts: ${{ this.birthdayDiscounts + this.normalDiscounts }} off</div>
    </div>

    <!-- Loyalty modal, separate from the other popup modal -->
    <div id="loyalty-modal" class="w3-modal">
      <div class="w3-modal-content w3-animate-top">
        <div class="w3-container">
          <span onclick="document.getElementById('loyalty-modal').style.display='none'"
          class="w3-button w3-display-topright">&times;</span>
          <h1>Loyalty</h1>

          <div v-if="loyaltyScreen == 0">
            <h2>Loyalty Root</h2>
            <div class="modal-row">
              <button class="modal-button" @click="loyaltyScreen = 1">Add Customer</button>
              <button class="modal-button" @click="loyaltyScreen = 2">Check Existing</button>
            </div>
          </div>

          <div v-else-if="loyaltyScreen == 1">
            <h2>Loyalty Add Customer</h2>
            <div class="modal-column">
              <div class="modal-row">
                <label for="loyalty-phone">Phone:</label>
                <input class="modal-input" type="text" id="loyalty-phone" v-model="prospectivePhone">
              </div>
              <div class="modal-row">
                <label for="loyalty-birthday">Birthday (yyyy-mm-dd):</label>
                <input class="modal-input"type="text" id="loyalty-birthday" v-model="prospectiveBirthday">
              </div>
              <div class="modal-row">
                <label for="loyalty-points">Points:</label>
                <input class="modal-input"type="text" id="loyalty-points" v-model="prospectivePoints">
              </div>
              <div v-show="phone">Loaded customer: ({{ this.phone }}, {{ this.birthday }}, {{ this.points }})</div>
              <div v-show="loyaltyErrorAdd">Unable to add customer</div>
            </div>
            <div class="modal-row">
              <button class="modal-button" @click="loyaltyScreen = 0">Back</button>
              <button class="modal-button" @click="loyaltyAddCustomer()">Add Customer</button>
            </div>
          </div>

          <div v-else>
            <h2>Loyalty Check Customer</h2>
            <div class="modal-column">
              <div class="modal-row">
                <label for="loyalty-phone">Phone:</label>
                <input class="modal-input"type="text" id="loyalty-phone" v-model="prospectivePhone">
              </div>
              <div v-show="phone">Loaded customer: ({{ this.phone }}, {{ this.birthday }}, {{ this.points }})</div>
              <div v-show="loyaltyErrorFind">Unable to find customer</div>
            </div>
            <div class="modal-row">
              <button class="modal-button" @click="loyaltyScreen = 0">Back</button>
              <button class="modal-button" @click="loyaltyCheckCustomer()">Check Customer</button>
            </div>
          </div>

        </div>
        <div class="modal-row">
          <button v-show="canBirthday" class="modal-button" @click="applyBirthdayDiscount()">Apply Birthday Discount</button>
          <button v-show="canDiscount" class="modal-button" @click="applyDiscount()">Apply $1 Discount</button>
        </div>
        
      </div>
    </div>
</template>

<script>
import MealItem from './MealItems.vue'; // Adjust path if necessary
import shared from '../shared'
import api from '@/api'

export default {
  name: 'Kart',

  // @vuese
  /**
   * @data
   * @description
   * Initial fields for the component.
   * 
   * - 'loading' is the loading state of the component.
   * - 'loyaltyScreen' is the current screen of the loyalty modal.
   * - 'phone' is the phone number of the loaded Customer.
   * - 'birthday' is the birthday of the loaded Customer.
   * - 'points' is the loyalty points of the loaded Customer.
   * - 'id' is the id of the loaded Customer.
   * - 'prospectivePhone' is the phone number of the prospective Customer.
   * - 'prospectiveBirthday' is the birthday of the prospective Customer.
   * - 'prospectivePoints' is the loyalty points of the prospective Customer.
   * - 'loyaltyErrorFind' is the error state of finding a Customer.
   * - 'loyaltyErrorAdd' is the error state of adding a Customer.
   * - 'canDiscount' is the state of being able to apply a discount.
   * - 'canBirthday' is the state of being able to apply a birthday discount.
   * - 'birthdayDiscounts' is the total birthday discounts applied.
   * - 'normalDiscounts' is the total normal discounts applied.
   * - 'discountsApplied' is the state of discounts being applied.
   */
  data() {
    return{
      loading: false,

      // Loyalty information
      loyaltyScreen: 0,
      phone: "",
      birthday: "",
      points: 0,
      id: "",
      prospectivePhone: "",
      prospectiveBirthday: "",
      prospectivePoints: 0,
      loyaltyErrorFind: false,
      loyaltyErrorAdd: false,
      canDiscount: false,
      canBirthday: false,
      birthdayDiscounts: 0,
      normalDiscounts: 0,
      discountsApplied:  false,
    }
  },

  // @vuese
  /**
   * @components
   * @description
   * Components used in the component.
   * 
   * - 'MealItem' is the MealItem component.
   */
  components: {
    MealItem,
  },

  // @vuese
  /**
   * @props
   * @description
   * Props for the component.
   * 
   * - 'orderedItems' is the list of ordered items.
   */
  props: {
    orderedItems: {
      type: Array,
      required: true,
    },
  },

  // @vuese
  // Enable flash scaffolding functionality from a shared js file.
  created() {
    this.flashScaffolding = shared.flashScaffolding
  },

  // @vuese
  /**
   * @methods
   * @description
   * Methods for the component.
   * 
   * - 'completeTransaction' completes the transaction.
   * - 'getAddedPoints' calculates the total points that should be added to the Customer account.
   * - 'loyaltyAddCustomer' adds a Customer to the Customer table.
   * - 'loyaltyCheckCustomer' checks if a Customer exists in the table given a phone number.
   * - 'checkDiscounts' checks if more discounts can be applied for the loaded Customer.
   * - 'applyBirthdayDiscount' adds a birthday discount of $10 off.
   * - 'applyDiscount' adds a normal discount of $1 off.
   */
  methods: {
    
    // @vuese
    /**
     * @method completeTransaction
     * @description
     * Complete the transaction.
     */
    async completeTransaction() {
      try{
        this.loading = true;
        console.log('Transaction complete:', this.orderedItems);
        //track the total cost of transaction
        let cost = 0;
        const transactionIdResponse = await api.get('/transactions/highest_transaction_id');
        let nextTransactionId = transactionIdResponse.data.transaction_id + 1;

        // account for loyalty discounts
        cost -= this.birthdayDiscounts + this.normalDiscounts;

        //add the transaction
        const now = new Date();
        const currentDate = now.toISOString().split('T')[0];
        const currentTime = now.toTimeString().split(' ')[0];
        const response = await api.post('/transactions/add_transaction', {
          transaction: {
            date: currentDate,
            time: currentTime,
            total_cost: cost,
            expense: false,
          }
        });

        //add all sale items for transaction
        this.loading = true;
        for (const item of this.orderedItems) {
          for (let i = 0; i < item.length; i++) {
              console.log('Added Sale Item:', item[i]);
              console.log('Menu ID:', item[i].menu_id);
              console.log('Price:', item[i].price);
              const response = await api.post('/sale_items/add_sale_item', {
                menu_id: Number(item[i].menu_id),
                quantity: 1,
                price: parseFloat(item[i].price),
                transaction_id: nextTransactionId,
              });
              cost += parseFloat(item[i].price);
            }
        }

        this.loading = false;
        //clear the cart
        this.$emit('close');
        this.$emit('empty-kart');
        this.flashScaffolding();
        this.loading = false;

        // Reset loyalty
        this.phone = "";
        this.birthday = "";
        this.points = 0;
        this.id = "";
        this.prospectivePhone = "";
        this.prospectiveBirthday = "";
        this.prospectivePoints = 0;
        this.loyaltyErrorFind = false;
        this.loyaltyErrorAdd = false;
        this.canBirthday = false;
        this.canDiscount = false;
        this.birthdayDiscounts = 0;
        this.normalDiscounts = 0;
        this.discountsApplied = false;

        alert(`Order completed, your order number is: ${nextTransactionId}`);
      }
      catch (error) {
        this.loading = false;
        console.error('Error completing transaction:', error);
        alert(`Error placing order`);
      }
    },

    // @vuese
    // Calculate the total points that should be added to the Customer account.
    // 1 Point for 1 dollar spent
    getAddedPoints() {
      return this.orderItems.reduce((total, item) => {return total += item.price}, 0);
    },

    // @vuese
    // Add a Customer to the Customer table.
    // Adds a Customer based on their phone number, birthday, and starting points.
    // Also loads the Customer for checkout or loyalty implementation, will be in the same state as after calling loyaltyCheckCustomer().
    async loyaltyAddCustomer() {
      try {
        console.log(`Adding loyalty for (${this.prospectivePhone},${this.prospectiveBirthday},${this.prospectivePoints})`);
        const response = await api.post('/customers/add_customer', {
          phone: this.prospectivePhone,
          birthday: this.prospectiveBirthday,
          loyalty_points: this.prospectivePoints,
        });
        this.flashScaffolding();
        this.phone = response.data.phone;
        this.birthday = response.data.birthday;
        this.points = response.data.loyalty_points;
        this.id = response.data.id;
        console.log(response);
        this.loyaltyErrorAdd = false;
      } catch (error) {
        console.log("Error adding customer:", error);
        this.loyaltyErrorAdd = true;
      }
      this.checkDiscounts();
    },

    // @vuese
    // Check if a Customer exists in the table given a phone number.
    // Loads the given Customer for checkout or loyalty implementation.
    async loyaltyCheckCustomer() {
      try {
        console.log("Checking loyalty for " + this.prospectivePhone);
        const response = await api.get(`/customers/by_phone/${this.prospectivePhone}`);
        this.flashScaffolding();
        console.log(response);
        this.phone = response.data[0].phone;
        this.birthday = response.data[0].birthday;
        this.points = response.data[0].loyalty_points;
        this.id = response.data[0].id;
        this.loyaltyErrorFind = false;
      } catch (error) {
        this.flashScaffolding();
        console.log("Error checking employees or no employee found: ", error);
        this.phone = "";
        this.birthday = "";
        this.points = 0;
        this.loyaltyErrorFind = true;
      }
      this.checkDiscounts();
    },

    // @vuese
    // Check if more discounts can be applied for the loaded Customer.
    // If more discounts can be applied, the discount buttons in the modal will be enabled.
    checkDiscounts() {
      if (parseInt(this.points) >= 10) {
        this.canDiscount = true;
      } else {
        this.canDiscount = false;
      }

      // https://stackoverflow.com/questions/2013255/how-to-get-year-month-day-from-a-date-object
      var dateObj = new Date();
      dateObj.setHours(dateObj.getUTCHours() - (dateObj.getTimezoneOffset() / 60));
      const month   = parseInt(dateObj.getUTCMonth() + 1); // months from 1-12
      const day     = parseInt(dateObj.getUTCDate());

      console.log(`Today is ${month}-${day} and your birthday is ${this.birthday.split("-")[1]}-${this.birthday.split("-")[2]}`);

      if (parseInt(this.birthday.split("-")[1]) == month && parseInt(this.birthday.split("-")[2]) == day) {
        this.canBirthday = true;
      } else {
        this.canBirthday = false;
      }
    },

    // @vuese
    // Add a birthday discount of $10 off.
    applyBirthdayDiscount() {
      this.birthdayDiscounts += 10;
      this.discountsApplied = true;
      
      this.canBirthday = false;
      this.flashScaffolding();
    },

    // @vuese
    // Add a normnal discount of $1 off.
    applyDiscount() {
      this.normalDiscounts += 1;
      this.discountsApplied = true;

      this.points -= 10;
      this.checkDiscounts();
      
      this.flashScaffolding();
    },

    removeItem(index) {
      this.$emit('remove-item', index);
    },
  }
};
</script>

<style scoped>
  .popup {
    position: fixed;
    top: 50%;
    left: 50%;
    width: 90%;
    height: 90%;
    transform: translate(-50%, -50%);
    background-color: white;
    padding: 20px;
    border: 1px solid black;
    overflow-y:scroll;
  }
  .meal{
    display: flex;
    flex-direction: row;
    justify-content: center;
    align-items: normal;
    border: 1px solid #ccc;
    border-radius: 4px;
    padding: 20px;
    margin: 10px;
    background-color: #f9f9f9;
    width: auto;
    box-sizing: border-box;
    height: auto; /* Set a fixed height for consistency */
  }
  .item {
    display: flex;
    flex-direction: column;
    justify-content: space-between;
    align-items: stretch;
    border: 1px solid #ccc;
    border-radius: 4px;
    padding: 20px;
    margin: 10px;
    background-color: #f9f9f9;
    width: calc(20% - 20px); /* Adjust width to fit two items per row */
    box-sizing: border-box;
    height: auto; /* Set a fixed height for consistency */
  }
  .popup button {
    margin: 0.5em;
    padding: 0.5em 0.75em; 
    color: #242528;
    background-color: #C3C7D0;
  }
  img{
    margin:auto;
  }
  .loading-spinner {
    margin-top: 20px;
    text-align: center;
    font-weight: bold;
    color: #555;
  }

  .kart-button {
    margin: 35px;
    font-size: 30px;
    padding-top: 25px;
    padding-bottom: 25px;
    padding-right: 50px;
    padding-left: 50px;
  }

  /* Loyalty Modal */

  .loyalty-modal {
    position: fixed;
  }

  .modal-button {
    margin: 35px;
    font-size: 30px;
    padding-top: 25px;
    padding-bottom: 25px;
    padding-right: 50px;
    padding-left: 50px;
  }

  .modal-row {
    display: flex;
    flex-direction: row;
    align-items: center;
    justify-content: space-between;
  }

  .modal-column {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: space-between;
  }

  .modal-input {
    margin: 5px;
  }
</style>