import { fileURLToPath, URL } from 'node:url'
import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [vue()],
  resolve: {
    alias: {
      '@': fileURLToPath(new URL('./src', import.meta.url))
    }
  },
  server: {
    port: 5173,
    // 开发环境反向代理：把 /api 转发到后端 Spring Boot（同 nginx 的作用）
    proxy: {
      '/api': {
        target: 'http://127.0.0.1:80',
        changeOrigin: true
      }
    }
  }
})
