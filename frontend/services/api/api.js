import axios from 'axios';

// L'URL de ton backend (Docker ou localhost)
const API_URL = 'http://localhost:4001'; 

const api = axios.create({
  baseURL: API_URL,
});

// Intercepteur pour injecter le token automatiquement
api.interceptors.request.use((config) => {
  const token = localStorage.getItem('token');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

export default api;