<template>
    <div class="cashier-popup">
      <button @click="$emit('close')" class="close-button">Close</button>

      <div class="popup-name">{{menu_item}}</div>
      <ul>
        <li v-for="item in cat">
          <CashierSelection :category="item" />
        </li>
      </ul>
    </div>
</template>

<script>
import CashierSelection from './CashierSelection.vue'; // Adjust path if necessary

export default {
  name: 'CashierPopup',
  components: {
    CashierSelection,
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
  .cashier-popup {
    position: fixed;
    top: 50%;
    left: 50%;
    width: 90%;
    height: 90%;
    transform: translate(-50%, -50%);
    padding: 1.5em;

    background-color: white;
    border: 2px solid #888;
    border-radius: 0.25em;
    box-shadow: 1em black;

    overflow-y: scroll;
  }

  .popup-name {
    text-align: center;
    font-size: 133%;
    font-weight: 700;
  }

  .close-button {
    position: absolute;
    top: 2%;
    right: 3%;
  }
</style>