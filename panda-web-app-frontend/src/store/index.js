// store/index.js
import { createStore } from 'vuex'; // Use Vue 3's `createStore` from Vuex
import jwtDecode from 'jwt-decode';

export default createStore({
  state: {
    isAuthenticated: false,
    user: null, // To store user details if needed
  },
  mutations: {
    setAuthentication(state, status) {
      state.isAuthenticated = status;
    },
    setUser(state, user) {
      state.user = user;
    },
  },
  actions: {
    checkAuth({ commit }) {
      // Extract the `auth_token` cookie
      const token = document.cookie
        .split('; ')
        .find(row => row.startsWith('auth_token='))
        ?.split('=')[1];

      console.log("Auth token:", token); // Debugging
      if (token) {
        try {
          // Optionally decode the token for user details or expiration check
          const decoded = jwtDecode(token);
          console.log("Decoded token:", decoded); // Debugging

          // Example: Check if the token is expired (requires `exp` in JWT payload)
          const currentTime = Math.floor(Date.now() / 1000);
          if (decoded.exp && decoded.exp < currentTime) {
            // Token expired
            console.warn("Token expired");
            commit('setAuthentication', false);
            commit('setUser', null);
          } else {
            // Token is valid
            commit('setAuthentication', true);
            commit('setUser', decoded); // Store user details if available
          }
        } catch (error) {
          console.error('Invalid token:', error);
          commit('setAuthentication', false);
          commit('setUser', null);
        }
      } else {
        // No token found
        console.warn("No Token found");
        commit('setAuthentication', false);
        commit('setUser', null);
      }
    },
  },
});
