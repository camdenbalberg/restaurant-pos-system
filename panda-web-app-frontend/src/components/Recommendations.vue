<template>
    <div class="popup">
        <h1>Recommendations</h1>
        <p>Would You Like</p>
        <div v-if="recommendItem()">
            <!-- <MealItems :category="recItem.category" @selected="currentItems(index, $event)" /> -->
        </div>
        <button @click="$emit('close')">Close</button>
        <button @click="addToKart(item)">Add To Order</button>
    </div>
</template>

<script>
import axios from 'axios';
import MealItem from './MealItems.vue'; // Adjust path if necessary


export default {
    name: 'Recommendations',
    components: {
        MealItem,
    },
    props: {
        orderedItems: {
            type: Array,
            required: true,
        },
    },
    data() {
        return {
            recItem: null,
        };
    },
    methods: {
        closeRec() {
            this.$emit('close');
        },
        addToKart() {
            const allItemsSelected = this.selected_items.every(item => item !== null);
            if (allItemsSelected) {
                this.selected_items.unshift(this.menu_item);
                console.log('Emitting add-to-kart:', this.selected_items);
                this.$emit('add-to-kart', this.selected_items);
                this.$emit('close');
            } else {
                console.log('Please select all items before adding to the cart.');
            }
        },
        getRandItem(category){
            //get a random item from the menu
            const rand = Math.floor(Math.random() * this.menuItems.length);
            return this.menuItems[rand];
        },
        recommendItem(){
            //recommend items based off what user has in their cart
            console.log(this.orderedItems);
            let meal = false;
            let entree = false;
            let side = false;
            let drink = false;
            let appetizer = false;
            for(const item of this.orderedItems){
                for(const i of item){
                    console.log(i);
                    if(i.category == "meal"){
                        meal = true;
                    }
                    else if(i.category == "entree"){
                        entree = true;
                    }
                    else if(i.category == "side"){
                        side = true;
                    }
                    else if(i.category == "drink"){
                        drink = true;
                    }
                    else if(i.category == "appetizer"){
                        appetizer = true;
                    }
                }
            }
            if(meal && entree && side && drink){
                //recommend an appetizer
                this.getRandItem("appetizer");
                return true;
            }
            else if(meal && entree && side){
                //recommend a drink
                this.getRandItem("drink");
                return true;
            }
            else if(meal && entree){
                //recommend a side
                this.getRandItem("side");
                return true;
            }
            else if(meal){
                //recommend a drink
                this.getRandItem("drink");
                return true;
            }
            else if(appetizer || entree || side || drink){
                //recommend a meal
                this.getRandItem("meal");
                return true;
            }
            else{
                //no need to recommend
                console.log("No need to recommend");
                this.closeRec();
                return false;
            }
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
</style>