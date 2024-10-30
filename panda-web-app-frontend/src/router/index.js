// src/router.js
import { createRouter, createWebHistory } from 'vue-router';
import HomeView from '@/views/HomeView.vue'; // Create this component
import AboutView from '@/views/AboutView.vue'; // Create this component
import LoginView from '@/views/LoginView.vue';
import CustomerView from '@/views/CustomerView.vue'; // Create this component

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
    path: '/login',
    name: 'login',
    component: LoginView,
  },
  {
    path: '/customer',
    name: 'customer',
    component: CustomerView,
  },
];

const router = createRouter({
  history: createWebHistory(),
  routes,
});

export default router;
