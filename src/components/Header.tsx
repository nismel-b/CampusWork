import React from 'react';
import { User } from '../../types';

interface HeaderProps {
  user: User;
  onLogout: () => void;
  notificationPanel?: React.ReactNode; // 🆕 Ajout du panneau de notifications
}

const Header: React.FC<HeaderProps> = ({ user, onLogout, notificationPanel }) => {
  return (
    <header className="bg-white border-b border-slate-100 sticky top-0 z-30 shadow-sm">
      <div className="px-10 py-6 flex items-center justify-between">
        {/* Informations utilisateur */}
        <div className="flex items-center gap-4">
          {user.avatar ? (
            <img 
              src={user.avatar} 
              alt={user.name}
              className="w-12 h-12 rounded-2xl border-2 border-slate-100 object-cover shadow-sm" 
            />
          ) : (
            <div className="w-12 h-12 rounded-2xl bg-blue-100 flex items-center justify-center text-blue-600 text-lg font-black border-2 border-blue-200 shadow-sm">
              {user.name.charAt(0)}
            </div>
          )}
          
          <div>
            <h2 className="text-lg font-black text-slate-900 tracking-tight">
              {user.name}
            </h2>
            <p className="text-xs text-slate-500 font-bold uppercase tracking-widest">
              {user.role}
            </p>
          </div>
        </div>

        {/* Actions à droite */}
        <div className="flex items-center gap-3">
          {/* 🔔 Panneau de notifications */}
          {notificationPanel}

          {/* Bouton déconnexion */}
          <button
            onClick={onLogout}
            className="flex items-center gap-2 px-6 py-3 bg-slate-100 text-slate-600 rounded-2xl hover:bg-red-50 hover:text-red-600 transition-all font-bold text-sm group"
          >
            <svg 
              className="w-5 h-5 group-hover:rotate-12 transition-transform" 
              fill="none" 
              stroke="currentColor" 
              viewBox="0 0 24 24"
            >
              <path 
                strokeLinecap="round" 
                strokeLinejoin="round" 
                strokeWidth={2} 
                d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1" 
              />
            </svg>
            <span className="hidden md:inline">Déconnexion</span>
          </button>
        </div>
      </div>
    </header>
  );
};

export default Header;