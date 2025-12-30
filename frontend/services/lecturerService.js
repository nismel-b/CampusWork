import api from "../api/axios";

export const lecturerService = {
  getProfile() {
    return api.get("/lecturers/profile");
  },

  getSupervisedProjects() {
    return api.get("/lecturers/projects");
  },

  validateProject(projectId) {
    return api.put(`/lecturers/projects/${projectId}/validate`);
  },
};
