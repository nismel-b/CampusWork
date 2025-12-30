import axios from "axios";

const api = axios.create({
  baseURL: import.meta.env.VITE_API_URL || "http://localhost:5000/api",
  withCredentials: true, // utile si cookies / session
  headers: {
    "Content-Type": "application/json",
  },
});

// Intercepteur réponse (erreurs globales)
api.interceptors.response.use(
  (response) => response,
  (error) => {
    console.error(
      "Erreur API :",
      error?.response?.data || error.message
    );
    return Promise.reject(error);
  }
);

export default api;
