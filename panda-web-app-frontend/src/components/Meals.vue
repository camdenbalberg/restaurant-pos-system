<template>
    <div v-for="meal in menuItems" :key="meal">
        <button @click="showPopup(meal.menu_name, getRecipe(meal))">
            <picture>
                <source srcset="../assets/menu/bowl.avif" type="image/avif">
                <img src="../assets/menu/bowl.avif" alt="bowl">
            </picture>
            {{ meal.menu_name }}
        </button>
    </div>
    <Popup v-if="popupType" :menu_item="popupType" :cat="popupItems" @close="closePopup" @add-to-kart="addToKart($event)"/>
</template>

<script>
import api from '@/api';
import Popup from '../components/Popup.vue'; // Adjust path if necessary

export default {
    components: {
        Popup,
    },
    data() {
        return {
            popupType: null,
            popupItems: [],
            menuItems: [],
            loading: true,
        };
    },
    mounted() {
        this.fetchMenuItems();
    },
    computed: {
    filteredMenuItems() {
            return this.menuItems.filter(item => item.category === 'meal');
        },
    },
    name: 'MenuItems',
    methods: {
        showPopup(type, items) {
            this.popupType = type;
            this.popupItems = items;
        },
        closePopup() {
            this.popupType = null;
            this.popupItems = [];
        },
        async fetchMenuItems() {
            try {
                // Example usage of env var
                console.log(import.meta.env.VITE_API_BACKEND_URL);
                const response = await api.get('/menu_items');
                this.menuItems = response.data;
            } catch (error) {
                console.error('Error fetching menu items:', error);
            } finally {
                this.loading = false;
            }
        },
        getRecipe(meal) {
            //get all items corresponding to the meal and put in a list
        },
        addToKart(items) {
            console.log('Adding to kart:', items);
            emit('add-to-kart', items);
        },
    },
};
</script>

<style scoped>
.menu-items {
    padding: 20px;
    max-width: 600px;
    margin: auto;
}

.menu-item {
    border: 1px solid #ccc;
    border-radius: 4px;
    padding: 15px;
    margin: 10px 0;
    background-color: #f9f9f9;
}

.menu-item h2 {
    margin: 0;
}

.menu-item p {
    margin: 5px 0;
}
</style>  