<template>
  <div class="menu-board relative w-full" data-carousel="slide">
    <h1>Menu Items</h1>

    <div v-if="loading" class="loading-spinner">
      Loading...
    </div>

    <div v-if="!loading" class="menu-category-carousel relative h-auto overflow-hidden">
      <!-- Carousel wrapper -->
      <div class="carousel-inner flex" :style="{ transform: `translateX(-${carouselIndex * 100}%)` }">
        <!-- Loop through categories in pairs of two -->
        <div v-for="(pair, index) in categoryPairs" :key="index" class="carousel-slide flex-shrink-0 min-w-full flex">
          <div v-for="category in pair" :key="category.name" class="menu-category w-1/2 px-2">
            <h2>{{ category.name.charAt(0).toUpperCase() + category.name.slice(1) }}</h2>
            <div class="menu-items grid gap-4">
              <div v-for="item in category.items" :key="item.menu_id" class="menu-item">
                <h3>{{ item.menu_name }}</h3>
                <p>Price: ${{ item.price }}</p>
                <p>Category: {{ item.category }}</p>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Slider indicators (optional) -->
      <div class="carousel-indicators absolute bottom-2 left-1/2 transform -translate-x-1/2 flex space-x-3">
        <button v-for="(pair, index) in categoryPairs" :key="index" @click="setCarouselIndex(index)" 
                :class="['w-3 h-3 rounded-full', { 'bg-blue-600': carouselIndex === index, 'bg-gray-300': carouselIndex !== index }]" 
                aria-current="carouselIndex === index" :aria-label="`Slide ${index + 1}`">
        </button>
      </div>

      <!-- Slider controls -->
      <button @click="prevSlide" class="absolute top-1/2 left-0 z-30 flex items-center justify-center h-full px-4 -translate-y-1/2 cursor-pointer" aria-label="Previous slide">
        <span class="carousel-control-prev">&lt;</span>
      </button>
      <button @click="nextSlide" class="absolute top-1/2 right-0 z-30 flex items-center justify-center h-full px-4 -translate-y-1/2 cursor-pointer" aria-label="Next slide">
        <span class="carousel-control-next">&gt;</span>
      </button>
    </div>
  </div>
</template>

<script>
import api from '@/api'
import { fetchMenuItems } from '../api/menuService';

export default {
  data() {
    return {
      menuItems: {},
      loading: false,
      carouselIndex: 0, // Track current slide
      carouselInterval: null, // To store the interval for auto transition
    };
  },
  computed: {
    categoryPairs() {
      const categories = Object.entries(this.menuItems).map(([name, items]) => ({ name, items }));
      const pairs = [];
      for (let i = 0; i < categories.length; i += 2) {
        pairs.push(categories.slice(i, i + 2));
      }
      return pairs;
    },
  },
  mounted() {
    this.loadMenuItems();
    this.startAutoSlide(); // Start the auto transition when the component mounts
  },
  beforeDestroy() {
    if (this.carouselInterval) {
      clearInterval(this.carouselInterval); // Clear interval when component is destroyed
    }
  },
  methods: {
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

    // Next slide method
    nextSlide() {
      if (this.carouselIndex < this.categoryPairs.length - 1) {
        this.carouselIndex++;
      } else {
        this.carouselIndex = 0; // Go back to the first slide when reaching the end
      }
    },

    // Previous slide method
    prevSlide() {
      if (this.carouselIndex > 0) {
        this.carouselIndex--;
      } else {
        this.carouselIndex = this.categoryPairs.length - 1; // Go back to the last slide when reaching the start
      }
    },

    // Set carousel index manually when clicking indicators
    setCarouselIndex(index) {
      this.carouselIndex = index;
    },

    // Start automatic slide transition every 10 seconds
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
  padding: 1.5em;
}

.menu-category-carousel {
  position: relative;
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
}
</style>
