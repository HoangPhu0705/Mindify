import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import dotenv from 'dotenv';

dotenv.config();

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [react()],
  server: {
    proxy: {
      '/admin': {
        target: process.env.API_BASE_URL,
        changeOrigin: true,
        secure: false,
      },
      '/api': {
        target: process.env.API_BASE_URL,
        changeOrigin: true,
        secure: false,
      },
      // '/admin-login': {
      //   target: process.env.API_BASE_URL,
      //   changeOrigin: true,
      //   secure: false,
      // },
    },
  },
})
