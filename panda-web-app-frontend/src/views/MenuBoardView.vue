<template>
  <div class="menu-board relative w-full" data-carousel="slide">
    <h1>Menu Items</h1>

    <!-- Loading spinner shown while menu data is being fetched -->
    <div v-if="loading" class="loading-spinner">
      Loading...
    </div>

    <!-- Menu category carousel -->
    <div v-if="!loading" class="menu-category-carousel relative h-auto overflow-hidden">
      <!-- Carousel wrapper -->
      <div class="carousel-inner flex" :style="{ transform: `translateX(-${carouselIndex * 100}%)` }">
        <!-- Loop through categories in pairs of two -->
        <div v-for="(pair, index) in categoryPairs" :key="index" class="carousel-slide flex-shrink-0 min-w-full flex">
          <div v-for="category in pair" :key="category.name" class="menu-category w-1/2 px-2">
            <!-- Category image -->
            <img 
              :src="category.image" 
              :alt="`${category.name} image`" 
              class="category-image mb-4 w-full h-48 object-cover rounded-lg" 
            />
            <h2>{{ category.name.charAt(0).toUpperCase() + category.name.slice(1) + 's'}}</h2>
            <!-- Menu items within the category -->
            <div class="menu-items grid gap-4">
              <div v-for="item in category.items" :key="item.menu_id" class="menu-item">
                <h3>{{ item.menu_name }}</h3>
                <p v-if="item.price > 0">Price: ${{ item.price.toFixed(2) }}</p>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Carousel navigation indicators -->
      <div class="carousel-indicators absolute bottom-2 left-1/2 transform -translate-x-1/2 flex space-x-3">
        <button 
          v-for="(pair, index) in categoryPairs" 
          :key="index" 
          @click="setCarouselIndex(index)" 
          :class="['w-3 h-3 rounded-full', { 'bg-blue-600': carouselIndex === index, 'bg-gray-300': carouselIndex !== index }]" 
          aria-current="carouselIndex === index" 
          :aria-label="`Slide ${index + 1}`">
        </button>
      </div>

      <!-- Previous and Next controls -->
      <button 
        @click="prevSlide" 
        class="absolute top-1/2 left-0 z-30 flex items-center justify-center h-full -translate-y-1/2 cursor-pointer" 
        aria-label="Previous slide">
        <span class="carousel-control-prev">&lt;</span>
      </button>
      <button 
        @click="nextSlide" 
        class="absolute top-1/2 right-0 z-30 flex items-center justify-center h-full -translate-y-1/2 cursor-pointer" 
        aria-label="Next slide">
        <span class="carousel-control-next">&gt;</span>
      </button>
    </div>
  </div>
</template>

<script>
import api from '@/api'
import { fetchMenuItems } from '../api/menuService';

export default {
  // @vuese
  // Component's initial state variables
  data() {
    return {
      isLocked: false, // State to check if the screen is locked
      passkey: "", // Passkey for unlocking the screen
      menuItems: {}, // Fetched menu items grouped by category
      loading: false, // Loading state for menu data
      carouselIndex: 0, // Current index for the carousel
      carouselInterval: null, // Interval for automatic carousel sliding
    };
  },
  // @vuese
  // Computed properties for generating paired categories
  computed: {
    categoryPairs() {
      const categories = Object.entries(this.menuItems).map(([name, items]) => ({ 
      name,
      items,
      image: this.getCategoryImage(name),
     }));
      const pairs = [];
      for (let i = 0; i < categories.length; i += 2) {
        pairs.push(categories.slice(i, i + 2));
      }
      return pairs;
    },
  },
  // @vuese
  // Lifecycle hooks for initializing the component
  mounted() {
    this.loadMenuItems();
    this.startAutoSlide(); // Start the auto transition when the component mounts
     // Listen for lock event to lock the screen
    this.checkScreenLockStatus();
  },
  beforeDestroy() {
    if (this.carouselInterval) {
      clearInterval(this.carouselInterval); // Clear interval when component is destroyed
    }
  },

  // @vuese
  // Navigation guard for verifying passkey before leaving the page
  beforeRouteLeave(to, from, next) {
    if (!this.isLocked) {
      next();  // Allow navigation if the screen is not locked
    } else {
      const enteredPasskey = prompt("Please enter the passcode to leave the page.");
      console.log(this.passkey); //remove later
      if (enteredPasskey === this.passkey) {
        this.isLocked = false;
        this.handleUnlock();
        next();
      } else {
        alert("Incorrect passkey. You cannot leave the page.");
        next(false);  // Prevent navigation if passkey is incorrect
      }
    }
  },

  methods: {
    // @vuese
    // Unlock the screen with the provided passkey
    async handleUnlock() {
      try {
        const response = await api.unlockScreen({
          screen: {
            screenType: 'Menu_Board',
            passkey: this.passkey,
          },
        });

        // Check if the response contains a success message
        if (response.message) {
          this.isLocked = false;  // Update the locked state after unlocking
          console.log('Screen unlocked successfully');
        } else {
          console.error('Unexpected response format:', response);
          alert('Failed to unlock the screen. No message received.');
        }
      } catch (error) {
        console.error("Error unlocking the screen:", error);
        alert('Failed to unlock the screen. Please check your passkey.');
      }
    },
    
    // @vuese
    // Check the screen lock status from the API
    async checkScreenLockStatus() {
      try {
        const response = await api.get('screen_status', {
          params: { screen_type: 'Menu_Board' }
        });
        if (response.data.locked) {
          this.isLocked = true;
          this.passkey = response.data.passkey || "";  // Optionally, store the passkey if returned
        } else {
          this.isLocked = false;
        }
      } catch (error) {
        console.error("Error fetching screen lock status:", error);
      }
    },

    // @vuese
    // Load menu items from the server and group them by category
    async loadMenuItems() {
      this.loading = true; 
      try {
        const menuData = await fetchMenuItems();
        
        this.menuItems = menuData.reduce((acc, item) => {
          const category = item.category.toLowerCase();  // Normalize category names to lowercase
          if (!acc[category]) {
            acc[category] = [];
          }
          acc[category].push(item);
          return acc;
        }, {});

      } catch (error) {
        console.error('Error loading menu items:', error);
      } finally {
        this.loading = false; 
      }
    },

    // @vuese
    // Retrieve image for a given category name
    getCategoryImage(categoryName) {
      const images = {
        entree: 'https://i.imgur.com/BEhf8zt.png',
        meal: 'https://i.imgur.com/uVZyIZs.png',
        side: 'https://i.imgur.com/szq6n6I.png',
        appetizer: 'https://i.imgur.com/7fYAqdh.png',
        drink: 'https://i.imgur.com/ibEASgp.png'
      };
      console.log(images[categoryName.toLowerCase()]);
      return images[categoryName.toLowerCase()] || '../assets/biglogo.png';
    },

    // @vuese
    // Navigate to the next carousel slide
    nextSlide() {
      if (this.carouselIndex < this.categoryPairs.length - 1) {
        this.carouselIndex++;
      } else {
        this.carouselIndex = 0; // Go back to the first slide when reaching the end
      }
    },

    // @vuese
    // Navigate to the previous carousel slide
    prevSlide() {
      if (this.carouselIndex > 0) {
        this.carouselIndex--;
      } else {
        this.carouselIndex = this.categoryPairs.length - 1; // Go back to the last slide when reaching the start
      }
    },

    // @vuese
    // Set the carousel to a specific slide index
    setCarouselIndex(index) {
      this.carouselIndex = index;
    },

    // @vuese
    // Start automatic carousel slide transitions
    startAutoSlide() {
      this.carouselInterval = setInterval(() => {
        this.nextSlide(); // Automatically go to the next slide
      }, 10000); // Change slide every 10 seconds
    },
  },
};
</script>

<style scoped>
.menu-board {
  padding: .75em;
}

.menu-category-carousel {
  position: relative;
}

.category-image {
  width: 100%;
  height: 16rem; /* Increase the height to cover more of the image */
  object-fit: cover; /* Ensures the image covers the container */
  object-position: center; /* Centers the image within the container */
  border-radius: 0.5rem;
  margin-bottom: 1rem;
}

.carousel-inner {
  display: flex;
  transition: transform 0.5s ease;
  width: 100%;
}

.carousel-slide {
  flex-shrink: 0;
  min-width: 100%;
  display: flex; /* Ensuring the slides are flex containers */
}

.menu-category {
  width: 50%; /* Each category takes half the width of the container */
  padding: 0 1em;
}

.menu-items {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 1.5em;
}

.menu-item {
  border: 1px solid #ccc;
  border-radius: 4px;
  padding: 15px;
  background-color: #f9f9f9;
}
.menu-item h3 {
  font-size: 1.5rem;
  font-weight: bold;
}

.carousel-indicators button {
  width: 8px;
  height: 8px;
  background-color: #bbb;
  border-radius: 50%;
}

.carousel-control-prev,
.carousel-control-next {
  font-size: 1.5em;
  color: #333;
  cursor: pointer;
  top: 50%; /* Center vertically */
  transform: translateY(-50%);
  z-index: 30;
  padding: 0; /* Remove padding to make flush */
  height: 100%; /* Full height for easy clicking */
  width: 10px; /* Set width of the clickable area */
}

.carousel-control-prev {
  left: 0; /* Flush with the left side */
}

.carousel-control-next {
  right: 0; /* Flush with the right side */
}
h1 {
  font-size: 2.5rem;
  font-weight: bold;
  text-align: center;
  margin-bottom: .25em;
  color: #333;
}

h2 {
  font-size: 1.8rem; 
  font-weight: bold;
  margin-bottom: .5em;
  color: #444;
}
</style>
