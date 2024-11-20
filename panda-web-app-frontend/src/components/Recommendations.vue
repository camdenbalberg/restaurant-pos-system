<template>
    <div class="popup">
        <h1>Recommendations</h1>
        <p>Would You Like</p>
        <div v-if="recommendItem()">
            <MealItems :category="recItem.category" @selected="currentItems(index, $event)" />
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
        MealItems,
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
        recommendItem(){
            //recommend items based off what user has in their cart
            meal = false;
            entree = false;
            side = false;
            drink = false;
            appetizer = false;
            for(const item of this.kart){
                if(item.category == "Meal"){
                    meal = true;
                }
                else if(item.category == "Entree"){
                    entree = true;
                }
                else if(item.category == "Side"){
                    side = true;
                }
                else if(item.category == "Drink"){
                    drink = true;
                }
                else if(item.category == "Appetizer"){
                    appetizer = true;
                }
            }
            if(meal && entree && side && drink){
                //recommend an appetizer
                
                return true;
            }
            else if(meal && entree && side){
                //recommend a drink

                return true;
            }
            else if(meal && entree){
                //recommend a side

                return true;
            }
            else if(meal){
                //recommend a drink

                return true;
            }
            else if(appetizer || entree || side || drink){
                //recommend a meal

                return true;
            }
            else{
                //no need to recommend

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