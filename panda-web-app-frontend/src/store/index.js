// store/index.js
import { createStore } from 'vuex'; // Use Vue 3's `createStore` from Vuex
import jwtDecode from 'jwt-decode';
import api from '@/api';

export default createStore({
  state: {
    isAuthenticated: false,
    user: null, // To store user details if needed
  },
  mutations: {
    setAuthentication(state, status) {
      state.isAuthenticated = status;
    },
    // setUser(state, user) {
    //   state.user = user;
    // },
    setUser(state, user) {
      console.log('User being set in store:', user); // Debugging line
      state.user = user;
    },
  },
  actions: {
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
