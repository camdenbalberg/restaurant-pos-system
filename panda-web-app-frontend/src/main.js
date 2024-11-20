import './assets/tailwind.css';
import { createApp } from 'vue';
import './style.css';
import App from './App.vue';
import router from '@/router';
import store from './store';

const app = createApp(App);

app.use(router);
// createApp(App).use(router).mount('#app');
app.use(store);
app.mount('#app');
