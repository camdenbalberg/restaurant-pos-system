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
import MenuItem from './MealItems.vue'; // Adjust path if necessary

export default {
  name: 'Kart',
  components: {
    MenuItem,
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
    completeTransaction() {
      console.log('Transaction complete:', this.orderedItems);
      this.$emit('close');
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