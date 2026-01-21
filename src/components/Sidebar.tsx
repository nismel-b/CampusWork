
import React from 'react';
import { ICONS } from '../constants';
import { View, UserRole } from '../../types';
import logo_ from '../assets/logo_.jpeg';

interface SidebarProps {
  currentView: View;
  setView: (view: View) => void;
  role: UserRole;
  isCollapsed: boolean;
  setIsCollapsed: (val: boolean) => void;
}

const Sidebar: React.FC<SidebarProps> = ({ currentView, setView, role, isCollapsed, setIsCollapsed }) => {
  const menuItems: { id: View; label: string; icon: React.ReactNode; roles: UserRole[] }[] = [
    { id: 'dashboard', label: 'Dashboard', icon: <ICONS.Dashboard />, roles: [UserRole.STUDENT, UserRole.LECTURER, UserRole.ADMIN] },
    { id: 'projects', label: 'Projets', icon: <ICONS.Projects />, roles: [UserRole.STUDENT, UserRole.ADMIN] },
    { id: 'posts', label: 'Discussions', icon: <ICONS.Dashboard />, roles: [UserRole.STUDENT, UserRole.LECTURER, UserRole.ADMIN] },
    { id: 'users', label: 'Utilisateurs', icon: <ICONS.Users />, roles: [UserRole.ADMIN] },
    { id: 'settings', label: 'Paramètres', icon: <ICONS.Settings />, roles: [UserRole.STUDENT, UserRole.LECTURER, UserRole.ADMIN] },
  ];

  return (
    <div className={`${isCollapsed ? 'w-24' : 'w-72'} bg-[#1e40af] h-screen text-white flex flex-col fixed left-0 top-0 shadow-2xl z-20 transition-all duration-500 ease-[cubic-bezier(0.4,0,0.2,1)]`}>
      <div className={`p-8 flex flex-col items-center gap-4 border-b border-blue-400/20`}>
        <div className="flex items-center gap-3">
          {/*<div className="bg-white p-2 rounded-2xl shadow-lg flex-shrink-0 transform hover:rotate-12 transition-transform">*/}

            {/*<svg className="w-8 h-8 text-blue-700" fill="currentColor" viewBox="0 0 20 20">
              <path d="M9 4.804A7.993 7.993 0 002 12a5 5 0 005 5 5 5 0 005-5V4.804z" />
              <path fillRule="evenodd" d="M2 10a8 8 0 1116 0 8 8 0 01-16 0zm8-7a7 7 0 00-7 7 7 7 0 1114 0 7 7 0 00-7-7z" clipRule="evenodd" />
            </svg>*/}
            <div className="bg-white w-24 h-24 rounded-[2rem] shadow-2xl flex items-center justify-center overflow-hidden mb-8">
            <img src={logo_} alt="Logo CampusWork" className="w-full h-full object-contain p-0.8" />
            </div>
          {!isCollapsed && (
            <div className="flex flex-col">
              <h1 className="text-xl font-black tracking-tighter leading-none">CAMPUS</h1>
              <span className="text-xs font-bold text-blue-200 tracking-[0.2em]">WORK</span>
            </div>
          )}
        </div>
      </div>
      
      <div className="px-6 mt-6 mb-4">
        <button 
          onClick={() => setIsCollapsed(!isCollapsed)}
          className="w-full flex items-center justify-center p-3 rounded-2xl bg-white/10 hover:bg-white/20 transition-all group"
        >
          <div className={`transition-transform duration-500 ${isCollapsed ? 'rotate-180' : 'rotate-0'}`}>
             <svg className="w-5 h-5 text-blue-100" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M11 19l-7-7 7-7M19 19l-7-7 7-7" /></svg>
          </div>
        </button>
      </div>

      <nav className="flex-1 px-4 space-y-2 overflow-y-auto custom-scrollbar">
        {menuItems
          .filter(item => item.roles.includes(role))
          .map((item) => (
            <button
              key={item.id}
              onClick={() => setView(item.id)}
              className={`w-full flex items-center gap-4 px-5 py-4 rounded-2xl transition-all duration-300 group relative overflow-hidden ${
                currentView === item.id 
                  ? 'bg-white text-blue-800 shadow-xl' 
                  : 'text-blue-100 hover:bg-white/10 hover:text-white'
              } ${isCollapsed ? 'justify-center' : ''}`}
            >
              <span className={`transition-all duration-300 flex-shrink-0 ${currentView === item.id ? 'scale-110' : 'group-hover:scale-110 opacity-70 group-hover:opacity-100'}`}>
                {item.icon}
              </span>
              {!isCollapsed && <span className="font-bold text-sm tracking-wide truncate">{item.label}</span>}
              {currentView === item.id && !isCollapsed && (
                <div className="absolute right-0 top-0 bottom-0 w-1.5 bg-blue-800 rounded-l-full"></div>
              )}
            </button>
          ))}
      </nav>
      
      <div className="p-8 border-t border-blue-400/20 bg-blue-900/20">
        {!isCollapsed ? (
          <div className="flex flex-col gap-1">
            <p className="text-[10px] font-black text-blue-300/60 uppercase tracking-widest">Version v1.2</p>
            <p className="text-[9px] text-blue-200/40">© 2026 Digital Library</p>
          </div>
        ) : (
          <div className="text-center font-black text-[10px] text-blue-300/40 tracking-widest">v1.2</div>
        )}
      </div>

      <style>{`
        .custom-scrollbar::-webkit-scrollbar { width: 4px; }
        .custom-scrollbar::-webkit-scrollbar-track { background: transparent; }
        .custom-scrollbar::-webkit-scrollbar-thumb { background: rgba(255,255,255,0.1); border-radius: 10px; }
      `}</style>
    </div>
  );
};

export default Sidebar;
/*
import React from 'react';
import { ICONS } from '../constants';
import { View, UserRole } from '../types';

interface SidebarProps {
  currentView: View;
  setView: (view: View) => void;
  role: UserRole;
  isCollapsed: boolean;
  setIsCollapsed: (val: boolean) => void;
}

const Sidebar: React.FC<SidebarProps> = ({ 
  currentView, 
  setView, 
  role, 
  isCollapsed, 
  setIsCollapsed 
}) => {
  
  // 🔥 CRITIQUE: Vérifier que le rôle est bien défini
  if (!role) {
    console.error("❌ Sidebar: role is undefined");
    return null;
  }

  console.log("🎯 Sidebar rendering for role:", role);

  const menuItems: { 
    id: View; 
    label: string; 
    icon: React.ReactNode; 
    roles: UserRole[] 
  }[] = [
    { 
      id: 'dashboard', 
      label: 'Dashboard', 
      icon: <ICONS.Dashboard />, 
      roles: [UserRole.STUDENT, UserRole.LECTURER, UserRole.ADMIN] 
    },
    { 
      id: 'projects', 
      label: 'Projets', 
      icon: <ICONS.Projects />, 
      roles: [UserRole.STUDENT, UserRole.ADMIN] 
    },
    { 
      id: 'posts', 
      label: 'Discussions', 
      icon: <ICONS.Dashboard />, 
      roles: [UserRole.STUDENT, UserRole.LECTURER, UserRole.ADMIN] 
    },
    { 
      id: 'users', 
      label: 'Utilisateurs', 
      icon: <ICONS.Users />, 
      roles: [UserRole.ADMIN] 
    },
    { 
      id: 'settings', 
      label: 'Paramètres', 
      icon: <ICONS.Settings />, 
      roles: [UserRole.STUDENT, UserRole.LECTURER, UserRole.ADMIN] 
    },
  ];

  // 🔥 Filtrer les éléments du menu selon le rôle
  const visibleMenuItems = menuItems.filter(item => item.roles.includes(role));

  console.log(`📋 Visible menu items for ${role}:`, visibleMenuItems.map(i => i.label));

  return (
    <div className={`${isCollapsed ? 'w-24' : 'w-72'} bg-[#1e40af] h-screen text-white flex flex-col fixed left-0 top-0 shadow-2xl z-20 transition-all duration-500`}>
      */{/* Header */}
      /*<div className={`p-8 flex flex-col items-center gap-4 border-b border-blue-400/20`}>
        <div className="flex items-center gap-3">
          <div className="bg-white w-16 h-16 rounded-[2rem] shadow-2xl flex items-center justify-center overflow-hidden">
            <svg className="w-12 h-12 text-blue-700" fill="currentColor" viewBox="0 0 20 20">
              <path d="M10.394 2.827a1 1 0 00-.788 0l-7 3a1 1 0 000 1.846l7 3a1 1 0 00.788 0l7-3a1 1 0 000-1.846l-7-3z" />
              <path d="M6.783 10.236a10.142 10.142 0 01-1.383.154l-.2.006A1 1 0 005 11.277V13.01c0 .468.263.893.684 1.097l4.245 2.06a1 1 0 00.835 0l4.245-2.06a1.001 1.001 0 00.684-1.097v-1.733c0-.52-.37-.965-.885-1.042a10.177 10.177 0 01-1.383-.154l-4.126 1.768a1 1 0 01-.788 0l-4.126-1.768z" />
            </svg>
          </div>

          {!isCollapsed && (
            <div className="flex flex-col">
              <h1 className="text-xl font-black tracking-tighter leading-none">CAMPUS</h1>
              <span className="text-xs font-bold text-blue-200 tracking-[0.2em]">WORK</span>
            </div>
          )}
        </div>
      </div>*/
      
      {/* Toggle button */}
      /*<div className="px-6 mt-6 mb-4">
        <button 
          onClick={() => setIsCollapsed(!isCollapsed)}
          className="w-full flex items-center justify-center p-3 rounded-2xl bg-white/10 hover:bg-white/20 transition-all group"
        >
          <div className={`transition-transform duration-500 ${isCollapsed ? 'rotate-180' : 'rotate-0'}`}>
             <svg className="w-5 h-5 text-blue-100" fill="none" stroke="currentColor" viewBox="0 0 24 24">
               <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M11 19l-7-7 7-7M19 19l-7-7 7-7" />
             </svg>
          </div>
        </button>
      </div>*/

      {/* Navigation */}
      /*<nav className="flex-1 px-4 space-y-2 overflow-y-auto custom-scrollbar">
        {visibleMenuItems.length === 0 ? (
          <div className="text-center text-blue-200 text-xs p-4">
            Aucun menu disponible
          </div>
        ) : (
          visibleMenuItems.map((item) => (
            <button
              key={item.id}
              onClick={() => {
                console.log(`🔄 Changing view to: ${item.id}`);
                setView(item.id);
              }}
              className={`w-full flex items-center gap-4 px-5 py-4 rounded-2xl transition-all duration-300 group relative overflow-hidden ${
                currentView === item.id 
                  ? 'bg-white text-blue-800 shadow-xl' 
                  : 'text-blue-100 hover:bg-white/10 hover:text-white'
              } ${isCollapsed ? 'justify-center' : ''}`}
            >
              <span className={`transition-all duration-300 flex-shrink-0 ${
                currentView === item.id 
                  ? 'scale-110' 
                  : 'group-hover:scale-110 opacity-70 group-hover:opacity-100'
              }`}>
                {item.icon}
              </span>
              
              {!isCollapsed && (
                <span className="font-bold text-sm tracking-wide truncate">
                  {item.label}
                </span>
              )}
              
              {currentView === item.id && !isCollapsed && (
                <div className="absolute right-0 top-0 bottom-0 w-1.5 bg-blue-800 rounded-l-full"></div>
              )}
            </button>
          ))
        )}
      </nav>*/
      
      {/* Footer */}
      /*<div className="p-8 border-t border-blue-400/20 bg-blue-900/20">
        {!isCollapsed ? (
          <div className="flex flex-col gap-1">
            <p className="text-[10px] font-black text-blue-300/60 uppercase tracking-widest">
              Version v1.2
            </p>
            <p className="text-[9px] text-blue-200/40">© 2025 Digital Library</p>
            <p className="text-[8px] text-blue-300/40 mt-2">Rôle: {role}</p>
          </div>
        ) : (
          <div className="text-center font-black text-[10px] text-blue-300/40 tracking-widest">
            v1.2
          </div>
        )}
      </div>

      <style>{`
        .custom-scrollbar::-webkit-scrollbar { width: 4px; }
        .custom-scrollbar::-webkit-scrollbar-track { background: transparent; }
        .custom-scrollbar::-webkit-scrollbar-thumb { 
          background: rgba(255,255,255,0.1); 
          border-radius: 10px; 
        }
      `}</style>
    </div>
  );
};

export default Sidebar;*/