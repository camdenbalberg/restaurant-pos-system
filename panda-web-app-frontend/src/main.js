import './assets/tailwind.css';
import { createApp } from 'vue'
import './style.css'
import App from './App.vue'
import router from '@/router'

const pandaApp = createApp(App).use(router);
pandaApp.config.globalProperties.$backStack = [];
pandaApp.mount("#app");