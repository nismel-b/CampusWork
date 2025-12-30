import api from "../api/axios";

export const authService = {
  login(credentials) {
    return api.post("/auth/login", credentials);
  },

  register(data) {
    return api.post("/auth/register", data);
  },

  getCurrentUser() {
    return api.get("/auth/me");
  },

  logout() {
    return api.post("/auth/logout");
  },
};

