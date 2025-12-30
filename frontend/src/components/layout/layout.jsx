import React, { useState, useEffect } from "react";
import { Outlet } from "react-router-dom";

import Sidebar from "./sidebar";
import ProjectCard from "../UI/projectcard";
import UploadModal from "../UI/uploadmodal";
import ProjectDetails from "../UI/projectdetails";

import { Search, Plus } from "lucide-react";
import { projectService } from "../services/projectService";

export default function DashboardLayout({ user, role, onLogout }) {
  const [projects, setProjects] = useState([]);
  const [isModalOpen, setModalOpen] = useState(false);
  const [selectedProject, setSelectedProject] = useState(null);
  const [activeTab, setActiveTab] = useState("all");
  const [searchTerm, setSearchTerm] = useState("");
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchProjects();
  }, []);

  const fetchProjects = async () => {
    try {
      setLoading(true);
      const res = await projectService.getAll();
      setProjects(res.data);
    } catch (err) {
      console.error("Erreur de récupération :", err);
    } finally {
      setLoading(false);
    }
  };

  const filteredProjects = projects.filter(project => {
    const matchesTab =
      activeTab === "all" || project.authorId === user.id;

    const lowerTerm = searchTerm.toLowerCase();
    const matchesSearch =
      !searchTerm ||
      project.title?.toLowerCase().includes(lowerTerm) ||
      project.authorName?.toLowerCase().includes(lowerTerm);

    return matchesTab && matchesSearch;
  });

  return (
    <div className="flex min-h-screen bg-[#F8FAFC]">
      <Sidebar role={role} onLogout={onLogout} />

      <main className="ml-64 flex-1 p-10">
        {/* Header commun */}
        <header className="flex justify-between items-center mb-10">
          <div className="relative w-[450px]">
            <Search className="absolute left-4 top-1/2 -translate-y-1/2 text-slate-400" size={20} />
            <input
              type="text"
              placeholder="Rechercher un projet..."
              className="w-full pl-12 pr-4 py-4 bg-white border rounded-2xl"
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
            />
          </div>

          {(role === "student" || role === "lecturer") && (
            <button
              onClick={() => setModalOpen(true)}
              className="flex items-center gap-3 bg-blue-600 text-white px-8 py-4 rounded-2xl font-bold"
            >
              <Plus size={20} />
              Nouveau Projet
            </button>
          )}
        </header>

        {/* Pages injectées ici */}
        <Outlet context={{ projects: filteredProjects, loading }} />
      </main>

      <UploadModal
        isOpen={isModalOpen}
        onClose={() => setModalOpen(false)}
        onUploadSuccess={fetchProjects}
      />

      {selectedProject && (
        <ProjectDetails
          project={selectedProject}
          isOpen
          onClose={() => setSelectedProject(null)}
        />
      )}
    </div>
  );
}
