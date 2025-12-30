import api from "../api/axios";

export const studentService = {
  getProfile() {
    return api.get("/students/profile");
  },

  updateProfile(data) {
    return api.put("/students/profile", data);
  },

  getMyProjects() {
    return api.get("/students/projects");
  },
};

