<template>
    <div class="popup">
      <p>Cart</p>
      <ul>
        <li v-for="item in orderedItems" :key="item">
          <div v-for="(i,index) in item" :key="index" class="item">
            <picture>
              <source :srcset="`../../src/assets/menu/${i.menu_id}.avif`" type="image/avif">
              <img :src="`../../src/assets/menu/${i.menu_id}.avif`" :alt="i.menu_name">
            </picture>
            <h2>{{ i.menu_name }}</h2>
            <p>Price: ${{ i.price }}</p>
          </div>
        </li>
      </ul>
      <div v-if="loading" class="loading-spinner">
        Loading...
      </div>
      <button @click="$emit('close')">Close</button>
      <button @click="completeTransaction">Order</button>
    </div>
</template>

<script>
import axios from 'axios';

export default {
  name: 'Kart',
  data(){
    return {
      loading: false,
    };
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
        //add all sale items for transaction
        this.loading = true;
        for (const item of this.orderedItems) {
          for (let i = 0; i < item.length; i++) {
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
        this.loading = false;
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
.menu-items {
  flex: 1 1 20%;
  margin: 10px;
  padding: 10px;
  border-radius: 5px;
  font-size: 16px;
  background-color: white;
  border: 1px solid black;
  color: black;
  max-width: 200px;
  min-width: 100px;
}
.item {
  border: 1px solid #ccc;
  border-radius: 4px;
  padding: 15px;
  margin: 10px 0;
  background-color: #f9f9f9;
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
</style>