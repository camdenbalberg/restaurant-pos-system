// store/index.js
/**
 * @fileoverview Vuex store module to manage user authentication and state.
 * Integrates with the backend to check and update user authentication status.
 */
import { createStore } from 'vuex'; // Use Vue 3's `createStore` from Vuex
import jwtDecode from 'jwt-decode';
import api from '@/api';

/**
 * Vuex store for managing user authentication state.
 * @module store/index
 */
export default createStore({
  /**
   * @property {Object} state - Reactive state object for Vuex.
   * @property {boolean} state.isAuthenticated - Indicates if the user is authenticated.
   * @property {Object|null} state.user - Stores user details when authenticated, null otherwise.
   */
  state: {
    isAuthenticated: false,
    user: null, // To store user details if needed
  },
  mutations: {
    /**
     * Updates the authentication status in the state.
     * @param {Object} state - Vuex state object.
     * @param {boolean} status - Authentication status to set.
     */
    setAuthentication(state, status) {
      state.isAuthenticated = status;
    },

    /**
    * Updates the user information in the state.
    * @param {Object} state - Vuex state object.
    * @param {Object|null} user - User information retrieved from the backend.
    */
    setUser(state, user) {
      console.log('User being set in store:', user); // Debugging line
      state.user = user;
    },
  },
  actions: {
    /**
     * Validates the user's authentication status with the backend.
     * If valid, updates the Vuex state with the user's information.
     * @async
     * @param {Object} context - Vuex action context object.
     * @returns {Promise<void>} Resolves when the authentication check completes.
     */
    async checkAuth({ commit }) {
      try {
        const response = await api.get('/verify/token');
        const data = response.data;
        if (data.valid) {
          commit('setAuthentication', true);
          commit('setUser', data.user);
        } else {
          commit('setAuthentication', false);
          commit('setUser', null);
        }
      } catch (error) {
        console.error('Authentication check failed:', error);
        commit('setAuthentication', false);
        commit('setUser', null);
      }
    },

    /**
    * Logs out the current user and terminates their session.
    * Updates Vuex state to reflect the logout.
    * @async
    * @param {Object} context - Vuex action context object.
    * @returns {Promise<void>} Resolves when the logout operation completes.
    */
    async logout({ commit }) {
      try {
        await api.post('http://localhost/auth/logout'); // Make the logout request to the backend
        commit('setAuthentication', false); // Clear authentication state
        commit('setUser', null); // Clear user state
      } catch (error) {
        console.error('Logout failed:', error);
      }
    },
  },
});
