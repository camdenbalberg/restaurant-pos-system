<template>
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
        <button class="order-checkout" @click="checkout()">Checkout</button>
      </div>
    </div>

    <!-- Menu Items -->
    <div class="menu-items">
      <CashierMenuItems @submitItem="receiveItem" @submitMeal="receiveMeal" />
    </div>
  </div>
</template>
  
<script>
  import CashierMenuItems from '@/components/CashierMenuItems.vue';
  import api from '@/api'
  import shared from '../shared'

  export default {
    name: 'Cashier View',
    components: {
      CashierMenuItems,
    },
    data() {
      return {
        orderItems: [],
        isLocked: false,
        passkey: "",
      }
    },
    mounted() {
      this.checkScreenLockStatus();
    },
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

      receiveMeal(mealJSON) {
        const meal = JSON.parse(JSON.stringify(mealJSON))

        const orderItem = {
          index: this.orderItems.length,
          name: meal[0].menu_name,
          price: meal.reduce((total, item) => {return total += item.price}, 0),
          quantity: 1,
          items: meal,
        }

        this.flashScaffolding()
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

        // go through each order item
        // look at the items inside each orderitem...
        // collect their quantity into a map <menu_item, quantity>
        const map = new Map();
        this.orderItems.forEach((orderItem) => {
          for (let item of orderItem.items) {
            if (!map.has(item)) {
              map.set(item, orderItem.quantity);
            } else {
              map.set(item, orderItem.quantity + map.get(item));
            } 
          }
        });

        map.forEach(async (value, key) => {
          const saleItemResponse = await api.post('sale_items/add_sale_item', {
            menu_id: key.menu_id,
            quantity: value,
            price: key.price * value,
          });
          console.log(saleItemResponse);
        });
        
        this.flashScaffolding();
        this.deleteAllItems();
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
</style>