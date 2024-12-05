<template>
    <div class="popup">
        <h1>Recommendations</h1>
        <p>Would You Like</p>
        <div v-if="recommendItem()" class="menu-item">
            <picture>
                <source :srcset="recItem.image_url || `../../src/assets/menu/${recItem.menu_id}.avif`" type="image/avif">
                <img :src="recItem.image_url || `../../src/assets/menu/${recItem.menu_id}.avif`" :alt="recItem.menu_name">
            </picture>
            <h2>{{ recItem.menu_name }}</h2>
            <p>Price: ${{ recItem.price }}</p>
        </div>
        <button @click="$emit('close')">Close</button>
        <button @click="addToKart()">Add To Order</button>
    </div>
</template>

<script>
import axios from 'axios';
import MealItems from './MealItems.vue'; // Adjust path if necessary


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
        menuItems: {
            type: Array,
            required: true,
        }
    },

    // @vuese
    /**
     * @data
     * @description
     * Initial fields for the component.
     * 
     * - 'recItem' is the selected random item to recommend.
     * - 'recList' is the list of possible recommendations.
     */
    data() {
        return {
            recItem: null, //the selected random item to reccomend
            recList: [], //the list of possible reccomendations
        };
    },

    // @vuese
    /**
     * @methods
     * @description
     * Methods for the component.
     * 
     * - 'getRandItem' gets a random item from the menu.
     * - 'recommendItem' recommends items based off what user has in their cart.
     * - 'addToKart' adds the recommended item to the cart.
     */
    methods: {
        // @vuese
        /**
         * @method getRandItem
         * @description
         * Get a random item from the menu.
         */
        getRandItem(){
            //get a random item from the menu
            const rand = Math.floor(Math.random() * this.recList.length);
            this.recItem = this.recList[rand];
            console.log(this.recItem);
        },

        // @vuese
        /**
         * @method recommendItem
         * @description
         * Recommend items based off what user has in their cart.
         */
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
            if(meal && entree && side && drink && !appetizer){
                //recommend an appetizer
                this.recList = this.menuItems.filter(item => item.category === 'appetizer');
                this.getRandItem();
                return true;
            }
            else if(meal && entree && side){
                //recommend a drink
                this.recList = this.menuItems.filter(item => item.category === 'drink');
                this.getRandItem();
                return true;
            }
            else if(meal && entree){
                //recommend a side
                this.recList = this.menuItems.filter(item => item.category === 'side');
                this.getRandItem();
                return true;
            }
            else if(meal){
                //recommend a drink
                this.recList = this.menuItems.filter(item => item.category === 'drink');
                this.getRandItem();
                return true;
            }
            else if(appetizer || entree || side || drink){
                //recommend a meal
                this.recList = this.menuItems.filter(item => item.category === 'meal');
                this.getRandItem();
                return true;
            }
            else{
                //no need to recommend
                console.log("No need to recommend");
                this.$emit('close');
                return false;
            }
        },

        // @vuese
        /**
         * @method addToKart
         * @description
         * Add the recommended item to the cart.
         */
        addToKart(){
            if(this.recItem.category === 'meal'){
                this.$emit('handle-show-meal', this.recItem);
                this.$emit('close');
            }
            else if(this.recItem.category === 'side'){
                let side = [];
                side.push({menu_id: 1, menu_name: 'A La Carte Side', price: 4.40, category: 'meal'});
                side.push(this.recItem);
                this.$emit('add-to-kart', side);
                this.$emit('close');
            }
            else{
                console.log(this.recItem);
                this.$emit('add-to-kart', [this.recItem]);
                this.$emit('close');
            }
        },
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
.menu-item {
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
</style>