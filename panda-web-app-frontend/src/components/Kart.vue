<template>
    <div class="popup">
      <p>Cart</p>
      <ul>
        <li v-for="item in orderedItems" :key="item">
          <div v-for="(i,index) in item" :key="i" class="item">
            <picture>
              <source :srcset="`../../src/assets/menu/${i.menu_id}.avif`" type="image/avif">
              <img :src="`../../src/assets/menu/${i.menu_id}.avif`" :alt="i.menu_name">
            </picture>
            <h2>{{ i.menu_name }}</h2>
            <p>Price: ${{ i.price }}</p>
          </div>
        </li>
      </ul>
      <button @click="$emit('close')">Close</button>
      <button @click="completeTransaction">Order</button>
    </div>
</template>

<script>
import axios from 'axios';
import MealItem from './MealItems.vue'; // Adjust path if necessary

export default {
  name: 'Kart',
  components: {
    MealItem,
  },
  props: {
    orderedItems: {
      type: Array,
      required: true,
    },
  },
  methods: {
    async completeTransaction() {
      try{
        console.log('Transaction complete:', this.orderedItems);
        //track the total cost of transaction
        let cost = 0;
        const transactionIdResponse = await axios.get('/api/v1/transactions/highest_transaction_id');
        let nextTransactionId = transactionIdResponse.data.transaction_id + 1;

        //add all sale items for transaction
        for (const item of this.orderedItems) {
          for (let i = 0; i < item.length; i++) {
              console.log('Added Sale Item:', item[i]);
              console.log('Menu ID:', item[i].menu_id);
              console.log('Price:', item[i].price);
              const response = await axios.post('/api/v1/sale_items/add_sale_item', {
                menu_id: Number(item[i].menu_id),
                quantity: 1,
                price: parseFloat(item[i].price),
                transaction_id: nextTransactionId,
              });
              cost += parseFloat(item[i].price);
            }
        }

        //add the transaction
        const now = new Date();
        const currentDate = now.toISOString().split('T')[0];
        const currentTime = now.toTimeString().split(' ')[0];
        const response = await axios.post('/api/v1/transactions/add_transaction', {
          transaction: {
            date: currentDate,
            time: currentTime,
            total_cost: cost,
            expense: false,
          }
        });

        //clear the cart
        this.$emit('close');
        this.$emit('empty-kart');
      }
      catch (error) {
        console.error('Error completing transaction:', error);
      }
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
li{
  display: flex;
  justify-content: space-around;
  align-items: center;
  flex: 1;
  flex-wrap: wrap;
  padding: 20px;
  overflow-y: auto; /* Ensure the container is scrollable */
}
</style>