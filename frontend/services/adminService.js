import api from "../api/axios";

export const adminService = {
  getDashboardStats() {
    return api.get("/admin/stats");
  },

  getAllUsers() {
    return api.get("/admin/users");
  },

  deleteUser(userId) {
    return api.delete(`/admin/users/${userId}`);
  },
};
