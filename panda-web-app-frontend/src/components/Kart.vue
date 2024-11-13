<template>
    <div class="popup">
      <p>Kart</p>
      <ul>
        <li v-for="item in orderedItems" :key="item">
          <div v-for="(i,index) in item" :key="i">
            <!--for now check for first index since meal is a string-->
            {{ i }}
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
      //validator(value) {
      //  return value.every(item => typeof item === 'string');
      //},
    },
  },
  methods: {
    async completeTransaction() {
      try{
        console.log('Transaction complete:', this.orderedItems);
        //track the total cost of transaction
        let cost = 0;
        //add all sale items for transaction
        for (const item of this.orderedItems) {
          for (let i = 1; i < item.length; i++) {
              console.log('Added Sale Item:', item[i]);
              console.log('Menu ID:', item[i].menu_id);
              console.log('Price:', item[i].price);
              const response = await axios.post('/api/v1/sale_items/add_sale_item', {
                menu_id: Number(item[i].menu_id),
                quantity: 1,
                price: parseFloat(item[i].price),
              });
              cost += parseFloat(item[i].price);
            }
        }

        //add the transaction
        const now = new Date();
        const currentDate = now.toLocaleDateString();
        const currentTime = now.toLocaleTimeString('en-GB', { hour12: false, hour: '2-digit', minute: '2-digit' });
        const response = await axios.post('/api/v1/transactions/add_transaction', {
          date: currentDate,
          time: currentTime,
          total_cost: cost,
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
.ul{
  display: flex;
  justify-content: space-around;
  align-items: center;
  flex: 1;
  flex-wrap: wrap;
  padding: 20px;
  overflow-y: auto; /* Ensure the container is scrollable */
}
</style>