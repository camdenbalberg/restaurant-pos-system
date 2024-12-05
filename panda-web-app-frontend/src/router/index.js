// src/router.js
/**
 * Vue Router instance configuration file.
 * Manages application routes and navigation guards.
 */
import store from '@/store';
import { createRouter, createWebHistory } from "vue-router";
import { authStatus } from "@/auth/index.js";
import HomeView from "@/views/HomeView.vue"; // Create this component
import AboutView from "@/views/AboutView.vue"; // Create this component
import KitchenView from "../views/KitchenView.vue";
import LoginView from "@/views/LoginView.vue";
import ManagerView from "@/views/ManagerView.vue";
import GoogleAuth from "@/components/GoogleAuth.vue";
import CustomerView from "@/views/CustomerView.vue"; // Create this component
import CashierView from '@/views/CashierView.vue';
import MenuBoardView from "../views/MenuBoardView.vue";

/**
 * Application routes.
 * Each route defines a path, name, and component to render, along with optional metadata.
 */
const routes = [
  {
    path: "/",
    name: "home",
    component: HomeView,
    meta: { requiresAuth: true },
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
    meta: { requiresAuth: true, requiresEmployee: true },
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
    meta: { requiresAuth: true, requiresEmployee: true },
  },
  {
    path: '/customer',
    name: 'customer',
    component: CustomerView,
    meta: { requiresAuth: false },
  },
  {
    path: "/manager",
    name: "manager",
    component: ManagerView,
    meta: { requiresAuth: true, requiresManager: true },
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
  {
    path: "/menu_board",
    name: "menu-board",
    component: MenuBoardView,
  },
];


/**
 * Creates and configures the Vue Router instance.
 * Includes navigation guards to enforce authentication and role-based access control.
 */
const router = createRouter({
  history: createWebHistory(),
  routes,
});

/**
 * Global navigation guard.
 * Checks for authentication and user roles before allowing navigation to routes.
 */
router.beforeEach((to, from, next) => {
  console.log('Navigating to:', to.name);
  console.log('Requires Auth:', to.meta.requiresAuth);
  console.log('Requires Manager:', to.meta.requiresManager);
  store.dispatch('checkAuth').then(() => {
    console.log('User Role:', store.state.user?.role); // Log the user's role after authentication check
    if (to.meta.requiresAuth && !store.state.isAuthenticated) {
      // Redirect unauthenticated users to the login page
      next('/login');
    } else if (to.meta.requiresManager && store.state.user.role !== 'manager') {
      // Redirect non-managers trying to access manager-only pages
      next('/');
      alert("You do not have permission to access this page.");
    } else if (to.meta.requiresEmployee && store.state.user.role !== 'employee' && store.state.user.role !== 'manager') {
      // Redirect non-staff trying to access staff-only pages
      next('/');
      alert("You do not have permission to access this page.");
    } else {
      // Allow navigation
      next();
    }
  });
});
export default router;
