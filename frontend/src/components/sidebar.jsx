import React from 'react';
import { LayoutDashboard, FolderUp, Star, LogOut, BookOpen } from 'lucide-react';

const Sidebar = () => {
  return (
    <div className="w-64 h-screen bg-sidebar text-white fixed left-0 top-0 flex flex-col">
      <div className="p-6">
        <h1 className="text-2xl font-bold flex items-center gap-2">
          <div className="w-8 h-8 bg-blue-600 rounded flex items-center justify-center text-sm">SP</div>
          StudentProjects
        </h1>
        <p className="text-xs text-gray-400 mt-1">Plateforme académique</p>
      </div>

      <nav className="flex-1 px-4 space-y-2">
        <NavItem icon={<LayoutDashboard size={20} />} label="Projets" active />
        <NavItem icon={<FolderUp size={20} />} label="Mes Rendus" />
        <NavItem icon={<Star size={20} />} label="Favoris" />
        
        <div className="pt-8 pb-2 text-xs text-gray-500 font-semibold uppercase">Filtres</div>
        <NavItem icon={<BookOpen size={20} />} label="Par Cours" />
      </nav>

      <div className="p-4 border-t border-gray-800">
        <div className="flex items-center gap-3">
          <div className="w-8 h-8 rounded-full bg-yellow-500 flex items-center justify-center text-black font-bold">
            ET
          </div>
          <div className="flex-1">
            <p className="text-sm font-medium">Étudiant Test</p>
            <p className="text-xs text-gray-400">Licence 3</p>
          </div>
          <button onClick={() => {localStorage.removeItem('token'); window.location.reload()}} className="text-gray-400 hover:text-white">
            <LogOut size={18} />
          </button>
        </div>
      </div>
    </div>
  );
};

const NavItem = ({ icon, label, active }) => (
  <button className={`w-full flex items-center gap-3 px-4 py-3 rounded-lg transition-colors ${
    active ? 'bg-blue-600 text-white' : 'text-gray-400 hover:bg-slate-800 hover:text-white'
  }`}>
    {icon}
    <span className="text-sm font-medium">{label}</span>
  </button>
);

export default Sidebar;