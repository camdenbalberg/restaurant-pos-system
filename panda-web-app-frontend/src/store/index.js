import { createStore } from 'vuex'; // Use Vue 3's `createStore` from Vuex
import { default as jwtDecode } from 'jwt-decode';


export default createStore({
  state: {
    user: null,
    token: null,
  },
  mutations: {
    setToken(state, token) {
      state.token = token;
      state.user = jwtDecode(token);
    },
    clearAuth(state) {
      state.token = null;
      state.user = null;
    },
  },
  actions: {
    login({ commit }, token) {
      commit('setToken', token);
      document.cookie = `auth_token=${token};path=/`;
    },
    logout({ commit }) {
      commit('clearAuth');
      document.cookie = 'auth_token=;path=/;expires=Thu, 01 Jan 1970 00:00:00 UTC;';
    },
  },
  getters: {
    isAuthenticated: (state) => !!state.token,
    user: (state) => state.user,
  },
});
