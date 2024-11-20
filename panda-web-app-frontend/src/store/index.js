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
    setUser(state, user) {
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
  },
});
