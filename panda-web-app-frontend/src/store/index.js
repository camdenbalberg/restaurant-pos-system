import { createStore } from 'vuex';

const store = createStore({
  state: {
    user: null,
    token: localStorage.getItem('token') || '',
  },
  mutations: {
    SET_USER(state, user) {
      state.user = user;
    },
    SET_TOKEN(state, token) {
      state.token = token;
      localStorage.setItem('token', token);
    },
    LOGOUT(state) {
      state.user = null;
      state.token = '';
      localStorage.removeItem('token');
    },
  },
  actions: {
    setUser({ commit }, user) {
      commit('SET_USER', user);
    },
    setToken({ commit }, token) {
      commit('SET_TOKEN', token);
    },
    logout({ commit }) {
      commit('LOGOUT');
    },
  },
  getters: {
    isAuthenticated: (state) => !!state.token,
    currentUser: (state) => state.user,
  },
});

export default store;
