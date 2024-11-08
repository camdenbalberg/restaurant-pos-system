/// /frontend/vite.config.js
import { defineConfig } from 'vite';
import vue from '@vitejs/plugin-vue';
import { resolve } from 'path';

export default defineConfig({
  plugins: [vue()],
  resolve: {
    alias: {
      '@': resolve(__dirname, 'src'), // Allows using '@' to refer to 'src'
    },
  },
  server: {
    port: process.env.PORT ? parseInt(process.env.PORT) : 80,
    host: true,
    strictPort: true, // Fail if the port is already in use
  },
});
