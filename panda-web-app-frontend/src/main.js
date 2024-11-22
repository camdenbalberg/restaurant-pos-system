import './assets/tailwind.css';
import { createApp } from 'vue';
import './style.css';
import App from './App.vue';
import router from '@/router';
import store from './store';

const pandaApp = createApp(App).use(router).use(store);
pandaApp.config.globalProperties.$backStack = [];
pandaApp.mount("#app");

