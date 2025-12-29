import React, { useState, useEffect } from 'react';
import Sidebar from './components/Sidebar';
import ProjectCard from './components/ProjectCard';
import UploadModal from './components/UploadModal';
import ProjectDetails from './components/ProjectDetails';
import Login from './pages/Login';
import { Search, Plus, Filter, LayoutGrid, LogOut } from 'lucide-react';
import api from './services/api';

function App() {
  const [isAuthenticated, setIsAuthenticated] = useState(!!localStorage.getItem('token'));
  const [projects, setProjects] = useState([]);
  const [isModalOpen, setModalOpen] = useState(false);
  const [selectedProject, setSelectedProject] = useState(null);
  const [activeTab, setActiveTab] = useState('all'); 
  const [searchTerm, setSearchTerm] = useState('');
  const [loading, setLoading] = useState(true);

  // Fonction de déconnexion pour Sidebar ou Header
  const handleLogout = () => {
    localStorage.removeItem('token');
    localStorage.removeItem('user');
    setIsAuthenticated(false);
  };

  useEffect(() => {
    if (isAuthenticated) fetchProjects();
  }, [isAuthenticated]); // On fetch au chargement ou quand l'auth change

  const fetchProjects = async () => {
    try {
      setLoading(true);
      // Correction de l'URL pour correspondre à ton service api.js 
      // Si ton service api.js a déjà baseURL: '.../api', utilise juste '/projects'
      const res = await api.get('/projects'); 
      setProjects(res.data);
    } catch (err) {
      console.error("Erreur de récupération :", err);
    } finally {
      setLoading(false);
    }
  };

  // LOGIQUE DE FILTRAGE (Calculée à chaque rendu pour plus de fluidité)
  const filteredProjects = projects.filter(project => {
    const user = JSON.parse(localStorage.getItem('user'));
    
    // Filtre par Onglet (Tous vs Les miens)
    const matchesTab = activeTab === 'all' || project.authorId === user?.id;

    // Filtre par Recherche
    const lowerTerm = searchTerm.toLowerCase();
    const matchesSearch = !searchTerm || 
      project.title?.toLowerCase().includes(lowerTerm) ||
      project.department?.toLowerCase().includes(lowerTerm) ||
      project.authorName?.toLowerCase().includes(lowerTerm) ||
      project.year?.toString().includes(lowerTerm) || // Recherche par année
      project.keywords?.some(k => k.toLowerCase().includes(lowerTerm));

    return matchesTab && matchesSearch;
  });

  if (!isAuthenticated) {
    return <Login onLoginSuccess={() => setIsAuthenticated(true)} />;
  }

  return (
    <div className="flex min-h-screen bg-[#F8FAFC]">
      {/* On passe handleLogout à la Sidebar si besoin */}
      <Sidebar onLogout={handleLogout} />

      <main className="ml-64 flex-1 p-10">
        {/* Top Header */}
        <header className="flex justify-between items-center mb-10">
          <div className="relative w-[450px]">
            <Search className="absolute left-4 top-1/2 -translate-y-1/2 text-slate-400" size={20} />
            <input 
              type="text" 
              placeholder="Titre, auteur, année ou mots-clés..." 
              className="w-full pl-12 pr-4 py-4 bg-white border border-slate-200 rounded-2xl shadow-sm focus:ring-2 focus:ring-blue-500 outline-none transition-all"
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
            />
          </div>

          <button 
            onClick={() => setModalOpen(true)}
            className="flex items-center gap-3 bg-blue-600 text-white px-8 py-4 rounded-2xl font-bold hover:bg-blue-700 shadow-xl shadow-blue-100 transition-all hover:-translate-y-0.5 active:scale-95"
          >
            <Plus size={20} />
            Nouveau Projet
          </button>
        </header>

        {/* Dashboard Title & Tabs */}
        <div className="mb-8">
          <h1 className="text-3xl font-extrabold text-slate-900 mb-6 tracking-tight">Espace Projets</h1>
          
          <div className="flex items-center justify-between border-b border-slate-200">
            <div className="flex gap-10">
              {['all', 'mine'].map((tab) => (
                <button 
                  key={tab}
                  onClick={() => setActiveTab(tab)}
                  className={`pb-4 px-2 text-sm font-bold uppercase tracking-wider transition-all relative ${
                    activeTab === tab ? 'text-blue-600' : 'text-slate-400 hover:text-slate-600'
                  }`}
                >
                  {tab === 'all' ? 'Tous les Projets' : 'Mes Publications'}
                  {activeTab === tab && (
                    <div className="absolute bottom-0 left-0 w-full h-0.5 bg-blue-600 rounded-full" />
                  )}
                </button>
              ))}
            </div>

            <div className="flex items-center gap-4 pb-3 text-slate-400">
              <span className="text-xs font-bold uppercase tracking-widest">
                {filteredProjects.length} résultat{filteredProjects.length > 1 ? 's' : ''}
              </span>
              <LayoutGrid size={18} />
            </div>
          </div>
        </div>

        {/* Grid Content */}
        {loading ? (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
            {[1, 2, 3, 4, 5, 6].map(i => (
              <div key={i} className="h-[400px] bg-slate-100 animate-pulse rounded-2xl border border-slate-200" />
            ))}
          </div>
        ) : filteredProjects.length === 0 ? (
          <div className="flex flex-col items-center justify-center py-32 bg-white rounded-3xl border border-dashed border-slate-300">
            <div className="bg-slate-50 p-6 rounded-full mb-4">
              <Filter size={40} className="text-slate-300" />
            </div>
            <p className="text-slate-500 font-semibold text-lg">Aucun projet trouvé</p>
            <p className="text-slate-400 text-sm">Essayez de modifier vos filtres ou votre recherche.</p>
          </div>
        ) : (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
            {filteredProjects.map((project) => (
              <div 
                key={project._id || project.id} 
                onClick={() => setSelectedProject(project)} 
                className="cursor-pointer"
              >
                <ProjectCard project={project} />
              </div>
            ))}
          </div>
        )}
      </main>

      {/* Modals */}
      <UploadModal 
        isOpen={isModalOpen} 
        onClose={() => setModalOpen(false)} 
        onUploadSuccess={() => {
          setModalOpen(false);
          fetchProjects(); // Rafraîchit la liste après un ajout
        }} 
      />

      {/* Détails du projet */}
      {selectedProject && (
        <ProjectDetails 
          project={selectedProject} 
          isOpen={!!selectedProject} 
          onClose={() => setSelectedProject(null)} 
        />
      )}
    </div>
  );
}

export default App;