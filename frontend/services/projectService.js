import api from "../api/axios";

export const projectService = {
  getAll() {
    return api.get("/projects");
  },

  getOne(id) {
    return api.get(`/projects/${id}`);
  },

  create(formData) {
    return api.post("/projects", formData, {
      headers: {
        "Content-Type": "multipart/form-data",
      },
    });
  },
};
