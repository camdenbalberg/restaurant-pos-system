// src/router.js
import { createRouter, createWebHistory } from 'vue-router';
import HomeView from '@/views/HomeView.vue'; // Create this component
import AboutView from '@/views/AboutView.vue'; // Create this component
import KitchenView from '../views/KitchenView.vue';

const routes = [
  {
    path: '/',
    name: 'home',
    component: HomeView,
  },
  {
    path: '/about',
    name: 'about',
    component: AboutView,
  },
  {
    path: '/kitchen',
    name: 'kitchen',
    component: KitchenView,
  },
];

const router = createRouter({
  history: createWebHistory(),
  routes,
});

export default router;
