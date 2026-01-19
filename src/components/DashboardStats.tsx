
import React from 'react';
import { UserRole } from '../../types';

interface StatCardProps {
  label: string;
  value: string | number;
  icon: React.ReactNode;
  colorClass: string;
}

const StatCard: React.FC<StatCardProps> = ({ label, value, icon, colorClass }) => (
  <div className="bg-white p-6 rounded-[2.5rem] shadow-sm border border-gray-100 flex items-center justify-between hover:shadow-md transition-shadow">
    <div>
      <p className="text-xs text-gray-400 font-black uppercase tracking-widest mb-1">{label}</p>
      <p className="text-3xl font-black text-gray-800 tracking-tighter">{value}</p>
    </div>
    <div className={`p-4 rounded-2xl ${colorClass}`}>
      {icon}
    </div>
  </div>
);

interface DashboardStatsProps {
  role: UserRole;
  stats: {
    totalUsers?: number;
    students?: number;
    lecturers?: number;
    pending?: number;
    myProjects?: number;
    totalProjectsCount?: number;
    inProgressCount?: number;
    completedCount?: number;
  };
}

const DashboardStats: React.FC<DashboardStatsProps> = ({ role, stats }) => {
  if (role === UserRole.ADMIN) {
    return (
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
        <StatCard label="Utilisateurs" value={stats.totalUsers || 0} colorClass="bg-blue-50 text-blue-600" icon={<svg className="w-6 h-6" fill="currentColor" viewBox="0 0 20 20"><path d="M9 6a3 3 0 11-6 0 3 3 0 016 0zM17 6a3 3 0 11-6 0 3 3 0 016 0zM12.93 17c.046-.327.07-.66.07-1a6.97 6.97 0 00-1.5-4.33A5 5 0 0119 16v1h-6.07zM6 11a5 5 0 015 5v1H1v-1a5 5 0 015-5z" /></svg>} />
        <StatCard label="Étudiants" value={stats.students || 0} colorClass="bg-emerald-50 text-emerald-600" icon={<svg className="w-6 h-6" fill="currentColor" viewBox="0 0 20 20"><path d="M10.394 2.827a1 1 0 00-.788 0l-7 3a1 1 0 000 1.846l7 3a1 1 0 00.788 0l7-3a1 1 0 000-1.846l-7-3z" /><path d="M6.783 10.236a10.142 10.142 0 01-1.383.154l-.2.006A1 1 0 005 11.277V13.01c0 .468.263.893.684 1.097l4.245 2.06a1 1 0 00.835 0l4.245-2.06a1.001 1.001 0 00.684-1.097v-1.733c0-.52-.37-.965-.885-1.042a10.177 10.177 0 01-1.383-.154l-4.126 1.768a1 1 0 01-.788 0l-4.126-1.768z" /></svg>} />
        <StatCard label="Enseignants" value={stats.lecturers || 0} colorClass="bg-purple-50 text-purple-600" icon={<svg className="w-6 h-6" fill="currentColor" viewBox="0 0 20 20"><path fillRule="evenodd" d="M2.166 4.9L9.03 9.069a2.42 2.42 0 002.393 0L18.29 4.9A1.5 1.5 0 0016 2.25H4a1.5 1.5 0 00-1.834 2.65zM19 7.251l-7.266 4.393a4.42 4.42 0 01-4.468 0L0 7.251V17.25A2.25 2.25 0 002.25 19.5h15.5A2.25 2.25 0 0020 17.25V7.251z" clipRule="evenodd" /></svg>} />
        <StatCard label="En Attente" value={stats.pending || 0} colorClass="bg-orange-50 text-orange-600" icon={<svg className="w-6 h-6" fill="currentColor" viewBox="0 0 20 20"><path fillRule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm1-12a1 1 0 10-2 0v4a1 1 0 00.293.707l2.828 2.829a1 1 0 101.415-1.415L11 9.586V6z" clipRule="evenodd" /></svg>} />
      </div>
    );
  }

  return (
    <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
      <StatCard 
        label="Total Projets" 
        value={stats.totalProjectsCount || 0} 
        colorClass="bg-blue-50 text-blue-600" 
        icon={<svg className="w-6 h-6" fill="currentColor" viewBox="0 0 20 20"><path d="M7 3a1 1 0 000 2h6a1 1 0 100-2H7zM4 7a1 1 0 011-1h10a1 1 0 110 2H5a1 1 0 01-1-1zM2 11a2 2 0 012-2h12a2 2 0 012 2v4a2 2 0 01-2 2H4a2 2 0 01-2-2v-4z" /></svg>} 
      />
      <StatCard 
        label="En Cours" 
        value={stats.inProgressCount || 0} 
        colorClass="bg-orange-50 text-orange-600" 
        icon={<svg className="w-6 h-6" fill="currentColor" viewBox="0 0 20 20"><path fillRule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm1-12a1 1 0 10-2 0v4a1 1 0 00.293.707l2.828 2.829a1 1 0 101.415-1.415L11 9.586V6z" clipRule="evenodd" /></svg>} 
      />
      <StatCard 
        label="Terminés" 
        value={stats.completedCount || 0} 
        colorClass="bg-emerald-50 text-emerald-600" 
        icon={<svg className="w-6 h-6" fill="currentColor" viewBox="0 0 20 20"><path fillRule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clipRule="evenodd" /></svg>} 
      />
    </div>
  );
};

export default DashboardStats;
