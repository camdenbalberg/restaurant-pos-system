<template>
  <div class="cashier-view">

    <!-- Items in Order -->
    <div class="order-items">
      <ul>
        <li v-for="orderItem in orderItems" :id="orderItem.index">
          <div class="order-item-container">
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
            <div class="order-item-quantity">Quantity: {{orderItem.quantity}}</div>
            <div class="order-item-delete"><button @click="deleteItem(orderItem)">Delete</button></div>
          </div>
        </li>
      </ul>
    </div>

    <!-- Menu Items -->
    <div class="menu-items">
      <CashierMenuItems @submitItem="receiveItem" @submitMeal="receiveMeal" />
    </div>
  </div>
</template>
  
<script>
  import CashierMenuItems from '@/components/CashierMenuItems.vue';
  
  export default {
    name: 'Cashier View',
    components: {
      CashierMenuItems,
    },
    data() {
      return {
        orderItems: [],
      }
    },
    methods: {
      receiveItem(itemJSON) {
        const item = JSON.parse(JSON.stringify(itemJSON))

        console.log("received item:");
        console.log(item);

        const orderItem = { 
          index: this.orderItems.length,
          name: item.menu_name,
          price: item.price,
          quantity: 1,
          items: [item],
        }

        this.orderItems.push(orderItem);
      },

      receiveMeal(mealJSON) {
        const meal = JSON.parse(JSON.stringify(mealJSON))

        console.log("received meal:");
        console.log(meal);

        const orderItem = {
          index: this.orderItems.length,
          name: meal[0].menu_name,
          price: meal.reduce((total, item) => {return total += item.price}, 0),
          quantity: 1,
          items: meal,
        }

        this.orderItems.push(orderItem);
      },

      deleteItem(orderItem) {
        this.orderItems = this.orderItems.filter(item => item != orderItem);
      }
    }
  };
</script>

<style scoped>
  .cashier-view {
    display: flex;
    height: 100vh;
    padding: 1em 2em;
  }

  .order-items {
    width: 60vh;
    overflow-y: scroll;
    border: 1px solid white;
    padding: 1em;
  }

  .order-item-container {
    display: grid;
    gap: 0.25em 0.25em;
    grid-template-columns: 70% 30%;

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

  .order-item-delete {
    grid-row: 3;
    grid-column: 2 / 2;
  }

  .order-item-delete button {
    margin-right: 0.25em;
    padding: 0.25em 0.375em;
    font-size: 90%;
    float: right;
  }

  .menu-items {
    width: 140vh;
    overflow-y: scroll;
    border: 1px solid white;
    padding: 1em;
  }
</style>