import axios from 'axios';

// 1. Configuration de base (ajuste le port selon ton backend Node.js)
const API_URL = 'http://localhost:5000/api'; 

const api = axios.create({
  baseURL: API_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

// 2. Intercepteur pour gérer les erreurs globalement (Optionnel mais recommandé)
api.interceptors.response.use(
  (response) => response,
  (error) => {
    console.error("Erreur API:", error.response ? error.response.data : error.message);
    return Promise.reject(error);
  }
);

// 3. Tes fonctions d'appel
export const projectService = {
  // Récupérer tous les projets
  getAll: () => api.get('/projects'),
  
  // Créer un projet (avec gestion de fichiers pour Multer)
  create: (formData) => api.post('/projects', formData, {
    headers: { 'Content-Type': 'multipart/form-data' } // Crucial pour Multer
  }),
  
  // Récupérer un projet par ID
  getOne: (id) => api.get(`/projects/${id}`),
};

export default api;