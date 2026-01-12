
import React from 'react';
import { ICONS } from '../constants';
import { User, UserRole } from '../types';

interface HeaderProps {
  user: User | null;
  onLogout: () => void;
}

const Header: React.FC<HeaderProps> = ({ user, onLogout }) => {
  if (!user) return null;

  const getRoleLabel = (role: UserRole) => {
    switch (role) {
      case UserRole.ADMIN: return 'Administrateur';
      case UserRole.LECTURER: return 'Enseignant';
      case UserRole.STUDENT: return 'Étudiant';
      default: return 'Utilisateur';
    }
  };

  const getRoleColor = (role: UserRole) => {
    switch (role) {
      case UserRole.ADMIN: return 'bg-orange-100 text-orange-700 border-orange-200';
      case UserRole.LECTURER: return 'bg-purple-100 text-purple-700 border-purple-200';
      case UserRole.STUDENT: return 'bg-emerald-100 text-emerald-700 border-emerald-200';
      default: return 'bg-gray-100 text-gray-700 border-gray-200';
    }
  };

  return (
    <header className="h-20 bg-white/80 backdrop-blur-md border-b border-gray-200 flex items-center justify-between px-8 sticky top-0 z-10">
      <div className="flex items-center gap-4">
        {user.avatar ? (
          <img src={user.avatar} alt={user.name} className="w-10 h-10 rounded-full border-2 border-white shadow-sm" />
        ) : (
          <div className="w-10 h-10 rounded-full bg-blue-100 flex items-center justify-center text-blue-600 font-bold">
            {user.name.charAt(0)}
          </div>
        )}
        <div className="flex flex-col">
          <h2 className="text-lg font-bold text-gray-800 leading-tight">{user.name}</h2>
          <p className="text-xs text-gray-500 font-medium">{getRoleLabel(user.role)}</p>
        </div>
      </div>
      
      <div className="flex items-center gap-6">
        <div className="relative group">
          <button className="p-2.5 text-gray-400 hover:text-blue-600 transition-colors bg-gray-50 rounded-xl">
            <ICONS.Bell />
            <span className="absolute top-2.5 right-2.5 w-2.5 h-2.5 bg-red-500 border-2 border-white rounded-full"></span>
          </button>
        </div>
        
        <button 
          onClick={onLogout}
          className="flex items-center gap-2 px-4 py-2 text-sm font-semibold text-gray-600 hover:text-red-600 hover:bg-red-50 transition-all rounded-xl border border-transparent hover:border-red-100"
        >
          <ICONS.Logout />
          <span>Déconnexion</span>
        </button>
      </div>
    </header>
  );
};

export default Header;
