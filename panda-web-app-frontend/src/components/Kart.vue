<template>
    <div class="popup">
      <p>{{ menu_item }}</p>
      <ul>
        <li v-for="item in cat" :key="item">
          <MenuItem :category="item" />
        </li>
      </ul>
      <button @click="$emit('close')">Close</button>
    </div>
</template>

<script>
import MenuItem from './MenuItem.vue'; // Adjust path if necessary

export default {
  name: 'Popup',
  components: {
    MenuItem,
  },
  props: {
    menu_item: {
      type: String,
      required: true,
    },
    cat:{
      type: Array,
      required: true,
      validator(value) {
        return value.every(item => typeof item === 'string');
      },
    }
  },
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