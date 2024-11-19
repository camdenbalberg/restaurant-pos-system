// src/router.js
import store from '@/store';
import { createRouter, createWebHistory } from "vue-router";
import { authStatus } from "@/auth/index.js";
import HomeView from "@/views/HomeView.vue"; // Create this component
import AboutView from "@/views/AboutView.vue"; // Create this component
import KitchenView from "../views/KitchenView.vue";
import LoginView from "@/views/LoginView.vue";
import CashierView from "@/views/CashierView.vue";
import CustomerView from "@/views/CustomerView.vue";
import ManagerView from "@/views/ManagerView.vue";
import GoogleAuth from "@/components/GoogleAuth.vue";

const routes = [
  {
    path: "/login/google/callback",
    name: "auth",
    component: GoogleAuth,
  },
  {
    path: "/",
    name: "home",
    component: HomeView,
    // meta: { requiresAuth: true },
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
    // meta: { requiresAuth: true },
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
    // meta: { requiresAuth: true },
  },
  {
    path: '/customer',
    name: 'customer',
    component: CustomerView,
    // meta: { requiresAuth: true },
  },
  {
    path: "/manager",
    name: "manager",
    component: ManagerView,
    // meta: { requiresAuth: true },
  },
  // Catch-all route for unhandled paths
  {
    path: '/:catchAll(.*)', // Matches any route not defined above
    beforeEnter: (to, from, next) => {
      if (to.path.startsWith('/auth')) {
        // Redirect to backend routes
        window.location.href = to.fullPath;
      } else {
        // Handle as a 404 or redirect to a default route
        next({ name: 'login' }); // Adjust as needed
      }
    },
  },
];

const router = createRouter({
  history: createWebHistory(),
  routes,
});

// router.beforeEach( (to, from, next) => {
//   if (to.meta.requiresAuth) {
//     const isAuthenticated = store.getters.isAuthenticated;
//     if (isAuthenticated) {
//       next();
//     } else {
//       next({ name: 'login' });
//     }
//   } else {
//     next();
//   }
// })

export default router;
