<template>
    <div class="cashier-popup">
      <div class="popup-name">{{menu_item.menu_name}}</div>

      <div class="popup-items">
        <button @click="$emit('cancel')" class="cancel-button">Cancel</button>
        <button @click="$emit('submitMeal', mealItems)" class="submit-button">Submit</button>

      </div>
      
      <div class="popup-selections">
        <ul>
          <li v-for="item in cat">
            <CashierSelection :category="item" @selectItem="selectItem"/>
          </li>
        </ul>
      </div>
    </div>
</template>s

<script>
import CashierSelection from './CashierSelection.vue'; // Adjust path if necessary

export default {
  name: 'CashierPopup',
  components: {
    CashierSelection,
  },
  props: {
    menu_item: {
      type: Object,
      required: true,
    },
    cat: {
      type: Array,
      required: true,
      validator(value) {
        return value.every(item => typeof item === 'string');
      },
    }
  },
  emits: ['cancel', 'submitMeal'],
  data() {
    return {
      mealItems: [this.menu_item],
    }
  },
  methods: {
    selectItem(item) {
      // console.log("meal selection received item: ")
      // console.log(item);

      this.mealItems.push(item);
    }
  },
};
</script>

<style scoped>
  .cashier-popup {
    position: fixed;
    top: calc(50% + 70px);
    left: 50%;
    height: calc(90% - 70px);
    width: 90%;
    transform: translate(-50%, calc(-50% - 35px));
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
    width: 100%;
  }

  .popup-items {
    width: 18%;
    float: right;
  }

  .cancel-button, .submit-button {
    margin: 0.5em;
    padding: 0.5em 0.75em; 
    color: #242528;
    background-color: #C3C7D0;
  }
</style>