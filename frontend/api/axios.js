import axios from "axios";

const api = axios.create({
  baseURL: import.meta.env.VITE_API_URL || "http://localhost:5000/api",
  withCredentials: true,
  headers: {
    "Content-Type": "application/json",
  },
});

// Intercepteur réponse (global)
api.interceptors.response.use(
  (response) => response,
  (error) => {
    const status = error?.response?.status;
    const message =
      error?.response?.data?.message ||
      error?.response?.data ||
      error.message ||
      "Erreur serveur";

    // Log dev
    console.error("Erreur API :", message);

    // Gestion auth globale
    if (status === 401) {
      // Session expirée / non autorisée
      // Redirection propre
      window.location.href = "/login";
    }

    // Erreur normalisée
    return Promise.reject({
      status,
      message,
      originalError: error,
    });
  }
);

export default api;
