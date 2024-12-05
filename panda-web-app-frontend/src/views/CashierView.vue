<template>
  <link rel="stylesheet" href="https://www.w3schools.com/w3css/4/w3.css"><link rel="stylesheet" href="https://www.w3schools.com/w3css/4/w3.css">

  <div class="cashier-view">

    <!-- Items in Order -->
    <div class="order-view">
      <div class="order-items">
        <ul>
          <li v-for="orderItem in orderItems" :id="orderItem.index" class="order-item-container">
            <div class="order-item-name">{{orderItem.name}}</div>
            <div class="order-item-price">{{(orderItem.price).toLocaleString('en-US', {
              style: 'currency',
              currency: 'USD',
            })}}</div>
            <div class="order-item-contents">
              <ul>
                <li v-for="item in orderItem.items.slice(1)">
                  {{item.menu_name}}
                </li>
              </ul>
            </div>
            <div class="order-item-quantity">
              Quantity: {{orderItem.quantity}}
              <button class="order-quantity-button" @click="increaseQuantity(orderItem)">+</button>
              <button class="order-quantity-button" @click="decreaseQuantity(orderItem)">-</button>
            </div>
            <div class="order-item-delete"><button @click="deleteItem(orderItem)">Delete</button></div>
          </li>
        </ul>
      </div>
      <div class="order-summary">
        <div class="order-price">
          <div class="order-subtotal-label">Subtotal:</div><div class="order-subtotal">{{getSubtotal()}}</div>
          <div class="order-tax-label">Tax:</div><div class="order-tax">{{getTax()}}</div>
          <div class="order-total-label">Total:</div><div class="order-total">{{getTotal()}}</div>
        </div>
        <button class="order-checkout" onclick="document.getElementById('loyalty-modal').style.display='block'" @click="loyaltyScreen = 0">Loyalty</button>
        <button class="order-checkout" @click="checkout()">Checkout</button>
      </div>
      <div v-show="phone">Loyalty loaded: ({{ this.phone }}, {{ this.birthday }}, {{ this.points }})</div>
    </div>

    <!-- Menu Items -->
    <div class="menu-items">
      <CashierMenuItems @submitItem="receiveItem" @submitMeal="receiveMeal" />
    </div>
  </div>

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
  import CashierMenuItems from '@/components/CashierMenuItems.vue';
  import api from '@/api'
  import shared from '../shared'

  export default {
    name: 'CashierView',
    components: {
      CashierMenuItems,
    },

    // @vuese
    // Initial fields.
    data() {
      return {
        orderItems: [],

        isLocked: false,
        passkey: "",

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
      }
    },
    mounted() {
      this.checkScreenLockStatus();
    },

    // @vuese
    // Enable flash scaffolding functionality from a shared js file.
    created() {
      this.flashScaffolding = shared.flashScaffolding
    },
    beforeRouteLeave(to, from, next) {
      if (!this.isLocked) {
        next();  // Allow navigation if the screen is not locked
      } else {
        const enteredPasskey = prompt("Please enter the passcode to leave the page.");
        console.log(this.passkey); //remove later
        if (enteredPasskey === this.passkey) {
          this.flashScaffolding();
          this.isLocked = false;
          this.handleUnlock();
          next();
        } else {
          alert("Incorrect passkey. You cannot leave the page.");
          next(false);  // Prevent navigation if passkey is incorrect
        }
      }
    },
    methods: {
      async handleUnlock() {
        try {
          const response = await api.unlockScreen({
            screen: {
              screenType: 'Cashier',
              passkey: this.passkey,
            },
          });

          // Check if the response contains a success message
          if (response.message) {
            this.isLocked = false;  // Update the locked state after unlocking
            console.log('Screen unlocked successfully');
          } else {
            console.error('Unexpected response format:', response);
            alert('Failed to unlock the screen. No message received.');
          }
        } catch (error) {
          console.error("Error unlocking the screen:", error);
          alert('Failed to unlock the screen. Please check your passkey.');
        }
      },

      async checkScreenLockStatus() {
        try {
          const response = await api.get('screen_status', {
            params: { screen_type: 'Cashier' }
          });
          if (response.data.locked) {
            this.isLocked = true;
            this.passkey = response.data.passkey || "";  // Optionally, store the passkey if returned
          } else {
            this.isLocked = false;
          }
        } catch (error) {
          console.error("Error fetching screen lock status:", error);
        }
      },

      receiveItem(itemJSON) {
        const item = JSON.parse(JSON.stringify(itemJSON))

        const orderItem = { 
          index: this.orderItems.length,
          name: item.menu_name,
          price: item.price,
          quantity: 1,
          items: [item],
        }

        this.flashScaffolding();
        this.orderItems.push(orderItem);
      },

      receiveMeal(meal) {
        if (!meal || !meal.menuItem || !meal.menuItem.menu_name) {
          console.error('Invalid meal data received:', meal);
          alert('Invalid meal data.');
          return;
        }

        const allSelections = [];
        let totalPrice = meal.menuItem.price;
        Object.keys(meal.selections).forEach(key => {
          const selectionItems = meal.selections[key];
          allSelections.push(...selectionItems);  // Add all selected items to the selections array
          selectionItems.forEach(item => {
            totalPrice += item.price;  // Add the price of each selected item
          });
        });

        // Create an order item based on the meal received
        const orderItem = {
          index: this.orderItems.length,
          name: meal.menuItem.menu_name,  // Name of the main meal
          price: totalPrice,  // Price of main meal + selections
          quantity: 1,
          items: [meal.menuItem, ...allSelections],  // Combine the main item with its selections
        };

        // Add the order item to the orderItems array
        this.flashScaffolding();
        this.orderItems.push(orderItem);
      },

      deleteItem(orderItem) {
        this.orderItems = this.orderItems.filter(item => item.index != orderItem.index);
      },

      deleteAllItems() {
        this.orderItems.splice(0, this.orderItems.length);
      },

      increaseQuantity(orderItem) {
        const newQuantity = orderItem.quantity + 1;
        this.orderItems[orderItem.index].quantity = newQuantity;
        this.orderItems[orderItem.index].price = orderItem.items.reduce((total, item) => {return total += item.price}, 0) * newQuantity;
      },

      decreaseQuantity(orderItem) {
        if (orderItem.quantity <= 1) {
          return;
        }

        const newQuantity = orderItem.quantity - 1;
        this.orderItems[orderItem.index].quantity = newQuantity;
        this.orderItems[orderItem.index].price = orderItem.items.reduce((total, item) => {return total += item.price}, 0) * newQuantity;
      },

      async checkout() {
        const now = new Date();
        const currentDate = now.toISOString().split('T')[0];
        const currentTime = now.toTimeString().split(' ')[0].substring(0,5);
        
        const transactionResponse = await api.post('transactions/add_transaction', {
          transaction: {
            date: currentDate,
            time: currentTime,
            total_cost: this.orderItems.reduce((total, item) => {return total += item.price}, 0),
            expense: false,
          }
        });
        console.log(transactionResponse);

        // Add loyalty points
        if (this.phone) {
          try {
            var formData = {
              loyalty_points: this.points,
            };
            formData.loyalty_points += parseInt(this.getAddedPoints());
            console.log(`Adding ${parseInt(this.getAddedPoints())} points` )
            const response = await api.put(
              `/customers/add_points/${this.id}`,
              formData
            );
          } catch (error) {
            console.log("Error adding loyalty points:",error);
          }
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
        }

        for (const orderItem of this.orderItems) {
          // Consolidate items within each orderItem
          const consolidatedItems = this.consolidateItems(orderItem.items);

          try {
            for (const item of consolidatedItems) {
              const calculatedQuantity = orderItem.quantity * item.quantity;
              const calculatedPrice = item.price * calculatedQuantity;

              console.log(item);

              // Validate data before making the API call
              if (!item.menu_id || calculatedQuantity <= 0) {
                console.error(`Invalid sale item data: menu_id=${item.menu_id}, quantity=${calculatedQuantity}, price=${calculatedPrice}`);
                continue; // Skip invalid entries
              }

              // Make API call sequentially
              await api.post('sale_items/add_sale_item', {
                menu_id: item.menu_id,
                quantity: calculatedQuantity,
                price: calculatedPrice,
                transaction_id: transactionResponse.transaction_id,
              }).catch((error) => {
                console.error("Error adding sale item:", error);
              });
            }
          } catch (error) {
            console.error("Error during sale item processing:", error);
          }
        }

        this.flashScaffolding();
        this.deleteAllItems();
      },

      consolidateItems(items) {
        const consolidated = [];
        const itemMap = new Map();
        const menuIdOrder = new Set(); // To track the order of menu_ids
        console.log(items);
        items.forEach((item) => {
          if (!item.menu_id) {
            console.error(`Invalid item detected: ${JSON.stringify(item)}`);
            return; // Skip invalid items
          }

          // Set a default quantity of 1 if not already present
          if (!item.quantity) {
            item.quantity = 1;
          }

          if (itemMap.has(item.menu_id)) {
            // If menu_id exists, update the quantity
            const existingItem = itemMap.get(item.menu_id);
            existingItem.quantity += item.quantity; // Use item.quantity instead of incrementing by 1
          } else {
            // If menu_id doesn't exist, add it to the map
            itemMap.set(item.menu_id, { ...item }); // Spread to avoid reference issues
            menuIdOrder.add(item.menu_id); // Record the order of this menu_id
          }
        });

        // Maintain the original order by iterating over menuIdOrder
        menuIdOrder.forEach((menu_id) => {
          console.log(consolidated);
          consolidated.push(itemMap.get(menu_id));
        });
        console.log("final: ", consolidated);
        return consolidated;
      },

      getSubtotal() {
        return this.orderItems.reduce((total, item) => {return total += item.price}, 0).toLocaleString('en-US', {
          style: 'currency',
          currency: 'USD',
        });
      },

      getTax() {
        return (this.orderItems.reduce((total, item) => {return total += item.price}, 0) * 0.0625).toLocaleString('en-US', {
          style: 'currency',
          currency: 'USD',
        });
      },

      getTotal() {
        return (this.orderItems.reduce((total, item) => {return total += item.price}, 0) * 1.0625).toLocaleString('en-US', {
          style: 'currency',
          currency: 'USD',
        });
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
      // Adds an item to the orderItems list which is a discount.
      applyBirthdayDiscount() {
        const orderItem = { 
          index: this.orderItems.length,
          name: "Birthday Discount",
          price: -10,
          quantity: 1,
          items: [],
        }
        
        this.canBirthday = false;
        this.flashScaffolding();
        this.orderItems.push(orderItem);
      },

      // Add a normal discount of $1 off.
      // Adds an item to the orderItems list which is a discount
      applyDiscount() {
        const orderItem = { 
          index: this.orderItems.length,
          name: "$1 Discount",
          price: -1,  
          quantity: 1,
          items: [],
        }

        this.points -= 10;
        this.checkDiscounts();
        
        this.flashScaffolding();
        this.orderItems.push(orderItem);
      },
    }
  };
</script>

<style scoped>
  .cashier-view {
    display: flex;
    height: calc(100vh - 70px);
    padding: 1em 2em;
  }

  .order-view {
    width: 60vh;
    border: 1px solid white;
    padding: 0.5em;
  }

  .order-items {
    height: 85%;
    overflow-y: scroll;
    padding: 0.5em;
    border: 1px solid white;
  }

  .order-item-container {
    display: grid;
    gap: 0.25em 0.25em;
    grid-template-columns: auto auto;

    margin-bottom: 1em;
    padding: 0.5em;

    background: white;
    border: 1px solid #666;
    border-radius: 1px;
  }

  .order-item-name {
    text-align: left;
    font-size: 115%;
    font-weight: 750;
  }

  .order-item-price {
    margin-right: 0.25em;
    text-align: right;
    font-size: 115%;
    font-weight: 750;
  }

  .order-item-contents {
    grid-row: 2;
    grid-column: 1 / span 2;

    margin-left: 2em;

    text-align: left;
    font-size: 85%;
  }

  .order-item-contents ul {
    list-style-type: disc;
  }

  .order-item-quantity {
    grid-row: 3;
    grid-column: 1 / 1;

    margin-top: auto;

    text-align: left;
    font-size: 95%;
  }

  .order-quantity-button {
    width: 1.5em;
    height: 1.5em;
    margin-left: 0.25em;
  }

  .order-item-delete {
    grid-row: 3;
    grid-column: 2 / 2;
    color: #242528;
  }

  .order-item-delete button {
    margin-right: 0.25em;
    padding: 0.25em 0.375em;
    font-size: 90%;
    float: right;
  }

  .order-summary {
    display: flex;
    flex-direction: row-reverse;
    align-items: center;
    justify-content: space-between;

    margin-top: 1em;
    padding: 0.25em 0.5em;
    border: 1px solid white;
  }

  .order-checkout {
    padding: 1em;
    color: #242528;
    background-color: #C3C7D0;
  }

  .order-price {
    display: grid;
    grid-template-columns: auto auto;
    grid-template-rows: auto auto auto;
    gap: 0 0.25em;
  }

  .order-subtotal-label, .order-tax-label, .order-total-label {
    text-align: right;
    font-size: 85%;
    margin-top: auto;
  }
  .order-total-label {
    font-size: 120%;
  }

  .order-subtotal {
    text-align: right;
    font-size: 100%;
  }

  .order-tax {
    text-align: right;
    font-size: 100%;
    color: #666;
  }
  .order-total {
    text-align: right;
    font-size: 120%;
    font-weight: 600;
  }

  .menu-items {
    width: 140vh;
    overflow-y: scroll;
    border: 1px solid white;
    padding: 1em;
  }

  /* Loyalty Modal */

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