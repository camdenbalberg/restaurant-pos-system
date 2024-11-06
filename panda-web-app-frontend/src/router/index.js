// src/router.js
import { createRouter, createWebHistory } from "vue-router";
import HomeView from "@/views/HomeView.vue"; // Create this component
import AboutView from "@/views/AboutView.vue"; // Create this component
import KitchenView from "../views/KitchenView.vue";
import LoginView from "@/views/LoginView.vue";
import CustomerView from "@/views/CustomerView.vue"; // Create this component
import ManagerView from "@/views/ManagerView.vue"; // Create this component
import CashierView from '@/views/CashierView.vue';

const routes = [
  {
    path: "/home",
    name: "home",
    component: HomeView,
  },
  {
    path: "/about",
    name: "about",
    component: AboutView,
  },
  {
    path: "/kitchen",
    name: "kitchen",
    component: KitchenView,
  },
  {
    path: "/login",
    name: "login",
    component: LoginView,
  },
  {
    path: '/cashier',
    name: 'cashier',
    component: CashierView,
  },
  {
    path: '/customer',
    name: 'customer',
    component: CustomerView,
  },
  {
    path: "/manager",
    name: "manager",
    component: ManagerView,
  },
];

const router = createRouter({
  history: createWebHistory(),
  routes,
});

export default router;
