import React, { useState, useEffect } from 'react';
import Sidebar from './components/Sidebar';
import ProjectCard from './components/ProjectCard';
import UploadModal from './components/UploadModal';
import ProjectDetails from './components/ProjectDetails';
import Login from './pages/Login';
import { Search, Plus, Filter, LayoutGrid } from 'lucide-react';
import api from './services/api';

function App() {
  const [isAuthenticated, setIsAuthenticated] = useState(!!localStorage.getItem('token'));
  const [projects, setProjects] = useState([]);
  const [isModalOpen, setModalOpen] = useState(false);
  const [selectedProject, setSelectedProject] = useState(null);
  const [activeTab, setActiveTab] = useState('all'); // 'all', 'mine'
  const [searchTerm, setSearchTerm] = useState('');
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (isAuthenticated) fetchProjects();
  }, [isAuthenticated, searchTerm, activeTab]);

  const fetchProjects = async () => {
    try {
      setLoading(true);
      const user = JSON.parse(localStorage.getItem('user'));
      
      // On récupère tout
      const res = await api.get('/api/projects');
      let data = res.data;

      // Logique de filtrage locale (plus rapide pour le MVP)
      if (activeTab === 'mine') {
        data = data.filter(p => p.authorId === user?.id);
      }

      // Recherche multi-critères
      if (searchTerm) {
        const lowerTerm = searchTerm.toLowerCase();
        data = data.filter(p => 
          p.title.toLowerCase().includes(lowerTerm) ||
          p.department?.toLowerCase().includes(lowerTerm) ||
          p.authorName?.toLowerCase().includes(lowerTerm) ||
          p.keywords?.some(k => k.toLowerCase().includes(lowerTerm))
        );
      }

      setProjects(data);
    } catch (err) {
      console.error("Fetch error:", err);
    } finally {
      setLoading(false);
    }
  };

  if (!isAuthenticated) {
    return <Login onLoginSuccess={() => setIsAuthenticated(true)} />;
  }

  return (
    <div className="flex min-h-screen bg-[#F8FAFC]">
      <Sidebar />

      <main className="ml-64 flex-1 p-10">
        {/* Top Header */}
        <header className="flex justify-between items-center mb-10">
          <div className="relative w-[450px]">
            <Search className="absolute left-4 top-1/2 -translate-y-1/2 text-slate-400" size={20} />
            <input 
              type="text" 
              placeholder="Rechercher par titre, auteur, matière ou tags..." 
              className="w-full pl-12 pr-4 py-4 bg-white border border-slate-200 rounded-2xl shadow-sm focus:ring-2 focus:ring-blue-500 outline-none transition-all"
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
            />
          </div>

          <button 
            onClick={() => setModalOpen(true)}
            className="flex items-center gap-3 bg-blue-600 text-white px-8 py-4 rounded-2xl font-bold hover:bg-blue-700 shadow-xl shadow-blue-100 transition-all hover:-translate-y-0.5"
          >
            <Plus size={20} />
            Nouveau Projet
          </button>
        </header>

        {/* Dashboard Title & Tabs */}
        <div className="mb-8">
          <h1 className="text-3xl font-extrabold text-slate-900 mb-6">Bibliothèque de projets</h1>
          
          <div className="flex items-center justify-between border-b border-slate-200">
            <div className="flex gap-10">
              <button 
                onClick={() => setActiveTab('all')}
                className={`pb-4 px-2 text-sm font-bold uppercase tracking-wider transition-all ${activeTab === 'all' ? 'text-blue-600 border-b-2 border-blue-600' : 'text-slate-400 hover:text-slate-600'}`}
              >
                Tous les Projets
              </button>
              <button 
                onClick={() => setActiveTab('mine')}
                className={`pb-4 px-2 text-sm font-bold uppercase tracking-wider transition-all ${activeTab === 'mine' ? 'text-blue-600 border-b-2 border-blue-600' : 'text-slate-400 hover:text-slate-600'}`}
              >
                Mes Publications
              </button>
            </div>

            <div className="flex items-center gap-4 pb-3 text-slate-400">
              <span className="text-xs font-bold uppercase tracking-widest">{projects.length} projets</span>
              <LayoutGrid size={18} />
            </div>
          </div>
        </div>

        {/* Grid Content */}
        {loading ? (
          <div className="grid grid-cols-3 gap-8 animate-pulse">
            {[1, 2, 3].map(i => <div key={i} className="h-64 bg-slate-200 rounded-2xl"></div>)}
          </div>
        ) : projects.length === 0 ? (
          <div className="flex flex-col items-center justify-center py-32 bg-white rounded-3xl border border-dashed border-slate-200">
            <Filter size={48} className="text-slate-200 mb-4" />
            <p className="text-slate-500 font-medium">Aucun projet ne correspond à votre recherche.</p>
          </div>
        ) : (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
            {projects.map((project) => (
              <div key={project._id} onClick={() => setSelectedProject(project)} className="cursor-pointer group">
                <ProjectCard project={project} />
              </div>
            ))}
          </div>
        )}
      </main>

      {/* Modals & Overlays */}
      <UploadModal 
        isOpen={isModalOpen} 
        onClose={() => setModalOpen(false)} 
        onUploadSuccess={fetchProjects} 
      />

      <ProjectDetails 
        project={selectedProject} 
        isOpen={!!selectedProject} 
        onClose={() => setSelectedProject(null)} 
      />
    </div>
  );
}

export default App;