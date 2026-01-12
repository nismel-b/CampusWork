
import React from 'react';
import { Project, ProjectStatus, UserRole } from '../types';
import { ICONS } from '../constants';

interface ProjectListProps {
  projects: Project[];
  role: UserRole;
  onEdit?: (project: Project) => void;
  onConsult?: (project: Project) => void;
  onDelete?: (projectId: string) => void;
  onLike?: (projectId: string) => void;
  onCreate?: () => void;
  isDashboard?: boolean;
  currentUser: any;
  searchQuery?: string;
  setSearchQuery?: (query: string) => void;
}

const ProjectCard: React.FC<{ project: Project; onEdit?: (project: Project) => void; onConsult?: (project: Project) => void; onDelete?: (id: string) => void; onLike?: (id: string) => void; canEdit: boolean; isAdmin: boolean; isLiked?: boolean }> = ({ project, onEdit, onConsult, onDelete, onLike, canEdit, isAdmin, isLiked }) => {
  const getStatusColor = (status: ProjectStatus) => {
    switch (status) {
      case ProjectStatus.IN_PROGRESS: return 'bg-blue-50 text-blue-600 border-blue-100';
      case ProjectStatus.COMPLETED: return 'bg-emerald-50 text-emerald-600 border-emerald-100';
      default: return 'bg-gray-50 text-gray-600 border-gray-100';
    }
  };

  const averageReview = project.reviews && project.reviews.length > 0
    ? (project.reviews.reduce((acc, r) => acc + r.rating, 0) / project.reviews.length).toFixed(1)
    : null;

  return (
   <div className="bg-white rounded-[2rem] shadow-sm border border-gray-100 flex flex-col hover:shadow-xl transition-all duration-300 group w-[340px] flex-shrink-0 snap-start border-b-4 border-b-transparent hover:border-b-blue-500 relative overflow-hidden">
      {/* images videos */}
      {/* 🆕 Image de couverture */}
      {project.coverImage && (
        <div className="relative w-full h-48 overflow-hidden">
          <img 
            src={project.coverImage} 
            alt={project.title}
            className="w-full h-full object-cover group-hover:scale-110 transition-transform duration-500"
          />
          <div className="absolute inset-0 bg-gradient-to-t from-black/60 to-transparent" />
          
          {/* Badge vidéo disponible */}
          {project.demoVideo && (
            <div className="absolute bottom-3 left-3 bg-white/90 backdrop-blur-sm px-3 py-1.5 rounded-xl flex items-center gap-2">
              <svg className="w-4 h-4 text-red-500" fill="currentColor" viewBox="0 0 20 20">
                <path d="M2 6a2 2 0 012-2h6a2 2 0 012 2v8a2 2 0 01-2 2H4a2 2 0 01-2-2V6zM14.553 7.106A1 1 0 0014 8v4a1 1 0 00.553.894l2 1A1 1 0 0018 13V7a1 1 0 00-1.447-.894l-2 1z" />
              </svg>
              <span className="text-xs font-black text-slate-800">Vidéo</span>
            </div>
          )}
        </div>
      )}
      
      <div className="p-7 flex flex-col flex-1">
        {/* Actions en haut à droite */}
        <div className="absolute top-4 right-4 flex gap-2 z-10">
          {/* ... boutons existants ... */}
        </div>
        {/* end modif */}
      </div>
     {/*<div className="bg-white rounded-[2rem] shadow-sm border border-gray-100 p-7 flex flex-col hover:shadow-xl transition-all duration-300 group w-[340px] flex-shrink-0 snap-start border-b-4 border-b-transparent hover:border-b-blue-500 relative"></div>*/}
      <div className="absolute top-4 right-4 flex gap-2">
        {onLike && (
          <button 
            onClick={(e) => { e.stopPropagation(); onLike(project.id); }}
            className={`p-2 rounded-xl transition-all shadow-sm z-10 flex items-center gap-1 ${isLiked ? 'bg-red-500 text-white' : 'bg-red-50 text-red-500 hover:bg-red-100'}`}
            title="Liker le projet"
          >
            <svg className="w-4 h-4 fill-current" viewBox="0 0 24 24"><path d="M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z" /></svg>
            <span className="text-[10px] font-black">{project.likes || 0}</span>
          </button>
        )}
        {isAdmin && onDelete && (
          <button 
            onClick={(e) => { e.stopPropagation(); onDelete(project.id); }}
            className="p-2 bg-red-50 text-red-500 rounded-xl hover:bg-red-500 hover:text-white transition-all shadow-sm z-10"
            title="Supprimer le projet"
          >
            <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" /></svg>
          </button>
        )}
      </div>
      
      <div className="flex justify-between items-start mb-2 pr-16">
        <h3 className="text-xl font-black text-gray-900 line-clamp-2 leading-tight group-hover:text-blue-600 transition-colors">{project.title}</h3>
        {project.grade && (
          <div className="bg-purple-100 text-purple-700 px-3 py-1 rounded-xl text-xs font-black shadow-sm flex-shrink-0">
            Grade: {project.grade}
          </div>
        )}
      </div>
      
      <div className="flex flex-col gap-1 mb-4">
        <span className="text-[11px] font-black text-blue-600 uppercase tracking-widest">{project.subject || project.category}</span>
        {project.lecturerName && (
          <span className="text-[10px] text-gray-400 font-bold italic">Soutenu par: {project.lecturerName}</span>
        )}
      </div>

      <p className="text-sm text-gray-500 mb-6 line-clamp-3 leading-relaxed font-medium min-h-[60px]">{project.description}</p>
      
      <div className="mt-auto space-y-5">
        <div className="flex items-center justify-between">
          <div className="flex gap-2">
            {project.githubLink && (
              <a href={project.githubLink} target="_blank" rel="noopener noreferrer" className="text-slate-400 hover:text-blue-600 transition-colors" title="GitHub">
                <svg className="w-5 h-5" fill="currentColor" viewBox="0 0 24 24"><path d="M12 0c-6.626 0-12 5.373-12 12 0 5.302 3.438 9.8 8.207 11.387.599.111.793-.261.793-.577v-2.234c-3.338.726-4.042-1.416-4.042-1.416-.546-1.387-1.333-1.756-1.333-1.756-1.089-.745.083-.729.083-.729 1.205.084 1.839 1.237 1.839 1.237 1.07 1.834 2.807 1.304 3.492.997.107-.775.418-1.305.762-1.604-2.665-.305-5.467-1.334-5.467-5.931 0-1.311.469-2.381 1.236-3.221-.124-.303-.535-1.524.117-3.176 0 0 1.008-.322 3.301 1.23.957-.266 1.983-.399 3.003-.404 1.02.005 2.047.138 3.006.404 2.291-1.552 3.297-1.23 3.297-1.23.653 1.653.242 2.874.118 3.176.77.84 1.235 1.911 1.235 3.221 0 4.609-2.807 5.624-5.479 5.921.43.372.823 1.102.823 2.222v3.293c0 .319.192.694.801.576 4.765-1.589 8.199-6.086 8.199-11.386 0-6.627-5.373-12-12-12z"/></svg>
              </a>
            )}
            {project.linkedinLink && (
              <a href={project.linkedinLink} target="_blank" rel="noopener noreferrer" className="text-slate-400 hover:text-blue-700 transition-colors" title="LinkedIn">
                <svg className="w-5 h-5" fill="currentColor" viewBox="0 0 24 24"><path d="M19 0h-14c-2.761 0-5 2.239-5 5v14c0 2.761 2.239 5 5 5h14c2.762 0 5-2.239 5-5v-14c0-2.761-2.238-5-5-5zm-11 19h-3v-11h3v11zm-1.5-12.268c-.966 0-1.75-.79-1.75-1.764s.784-1.764 1.75-1.764 1.75.79 1.75 1.764-.783 1.764-1.75 1.764zm13.5 12.268h-3v-5.604c0-3.368-4-3.113-4 0v5.604h-3v-11h3v1.765c1.396-2.586 7-2.777 7 2.476v6.759z"/></svg>
              </a>
            )}
          </div>
          <div className="flex gap-1">
            <span className={`px-4 py-1.5 rounded-xl text-[10px] font-black uppercase tracking-widest border ${getStatusColor(project.status)}`}>
              {project.status}
            </span>
            {project.isEvaluated && (
              <span className="px-4 py-1.5 rounded-xl text-[10px] font-black uppercase tracking-widest border bg-purple-50 text-purple-600 border-purple-100">
                Évalué
              </span>
            )}
          </div>
        </div>
        
        <div className="flex gap-2">
          {canEdit ? (
            <button 
              onClick={() => onEdit?.(project)}
              className="flex-1 py-4 text-[10px] font-black uppercase tracking-widest rounded-2xl transition-all shadow-lg bg-blue-600 text-white hover:bg-blue-700 shadow-blue-200 active:scale-95"
            >
              Modifier
            </button>
          ) : (
            <button 
              onClick={() => onConsult?.(project)}
              className="flex-1 py-4 text-[10px] font-black uppercase tracking-widest rounded-2xl transition-all shadow-lg bg-white border-2 border-slate-100 text-slate-400 hover:bg-slate-50 active:scale-95"
            >
              Consulter
            </button>
          )}
        </div>
      </div>
    </div>
    
  );
};

const ProjectList: React.FC<ProjectListProps> = ({ projects, role, onEdit, onConsult, onDelete, onLike, onCreate, isDashboard, currentUser, searchQuery, setSearchQuery }) => {
  const inProgress = projects.filter(p => p.status === ProjectStatus.IN_PROGRESS);
  const completed = projects.filter(p => p.status === ProjectStatus.COMPLETED);
  const isAdmin = role === UserRole.ADMIN;

  const canModify = (project: Project) => {
    if (!currentUser) return false;
    // Rule: All projects displayed in the dashboard are viewable only.
    if (isDashboard) return false;
    // Rule: Student projects can only be modified by the respective students themselves (author or collaborators).
    // This applies only in the "Projects" tab (where isDashboard is false/undefined).
    return project.authorId === currentUser.id || project.collaborators?.some(c => c.name === currentUser.name);
  };

  const renderHorizontalScroll = (title: string | null, list: Project[]) => (
    <div className="space-y-6">
      {title && (
        <div className="flex items-center justify-between px-2">
          <h3 className="text-xl font-black text-slate-800 flex items-center gap-3">
            {title} 
            <span className="text-xs bg-slate-200/50 text-slate-500 px-3 py-1 rounded-full">{list.length}</span>
          </h3>
        </div>
      )}
      <div className="relative group">
        <div className="overflow-x-auto pb-10 hide-scrollbar flex gap-8 snap-x scroll-smooth px-2">
          {list.map(project => (
            <ProjectCard 
              key={project.id}
              project={project} 
              onEdit={onEdit} 
              onConsult={onConsult}
              onDelete={onDelete}
              onLike={onLike}
              isLiked={project.likedBy?.includes(currentUser.id)}
              canEdit={canModify(project)}
              isAdmin={isAdmin}
            />
          ))}
          {list.length === 0 && (
            <div className="w-full py-20 bg-white/50 border-4 border-dashed border-slate-100 rounded-[3rem] flex flex-col items-center justify-center text-slate-400">
               <svg className="w-12 h-12 mb-3 opacity-20" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 11H5m14 0a2 2 0 012 2v6a2 2 0 01-2 2H5a2 2 0 01-2-2v-6a2 2 0 012-2m14 0V9a2 2 0 00-2-2M5 11V9a2 2 0 012-2m0 0V5a2 2 0 012-2h6a2 2 0 012 2v2M7 7h10" /></svg>
               <span className="font-bold text-sm text-gray-600">Aucun projet trouvé</span>
            </div>
          )}
        </div>
      </div>
    </div>
  );

  return (
    <div className="space-y-12 animate-fadeIn">
      {!isDashboard && (
        <div className="flex flex-col md:flex-row md:items-end justify-between gap-6">
          <div className="flex-1">
            <h2 className="text-4xl font-black text-gray-900 tracking-tighter leading-none mb-2 uppercase italic">
              {isAdmin ? "Gestion des Projets (Admin)" : "Bibliothèque Digitale"}
            </h2>
            <p className="text-slate-500 font-bold text-sm tracking-wide mb-6">
              {isAdmin ? "Accès total au catalogue : consultation, modification et suppression." : (role === UserRole.STUDENT ? 'Gérez vos propres contributions académiques.' : 'Supervision et catalogage de l\'ensemble des travaux.')}
            </p>
            {setSearchQuery && (
              <div className="max-w-md relative group">
                <div className="absolute inset-y-0 left-0 pl-4 flex items-center pointer-events-none">
                  <ICONS.Search />
                </div>
                <input
                  type="text"
                  placeholder="Rechercher par titre, matière ou auteur..."
                  value={searchQuery}
                  onChange={(e) => setSearchQuery(e.target.value)}
                  className="w-full pl-12 pr-6 py-4 bg-white border border-slate-100 rounded-[1.5rem] shadow-sm outline-none focus:ring-4 focus:ring-blue-100 focus:border-blue-300 transition-all font-medium text-sm text-gray-900"
                />
              </div>
            )}
          </div>
          {onCreate && (
            <button 
              onClick={onCreate}
              className="bg-blue-600 hover:bg-blue-700 text-white px-8 py-4 rounded-[1.5rem] font-black flex items-center gap-3 shadow-2xl shadow-blue-200 transition-all active:scale-95 uppercase tracking-widest text-[10px]"
            >
              <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={3} d="M12 6v6m0 0v6m0-6h6m-6 0H6" /></svg>
              Nouveau Projet
            </button>
          )}
        </div>
      )}

      {!isDashboard && (
        <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
          <div className="bg-[#1e40af] p-8 rounded-[2.5rem] text-white shadow-2xl shadow-blue-100 relative overflow-hidden group">
            <div className="absolute -right-10 -bottom-10 w-40 h-40 bg-white/10 rounded-full blur-3xl group-hover:scale-150 transition-transform duration-700"></div>
            <p className="text-blue-200 text-xs font-black uppercase tracking-widest mb-2">Total Projets</p>
            <p className="text-6xl font-black tracking-tighter">{projects.length}</p>
          </div>
          <div className="bg-white p-8 rounded-[2.5rem] border-2 border-blue-50 shadow-xl shadow-slate-100/50">
            <div className="flex items-center gap-3 mb-2">
              <div className="w-2 h-2 rounded-full bg-blue-500 animate-pulse"></div>
              <p className="text-slate-400 text-xs font-black uppercase tracking-widest">En cours</p>
            </div>
            <p className="text-5xl font-black text-slate-800 tracking-tighter">{inProgress.length}</p>
          </div>
          <div className="bg-white p-8 rounded-[2.5rem] border-2 border-emerald-50 shadow-xl shadow-slate-100/50">
            <div className="flex items-center gap-3 mb-2">
              <div className="w-2 h-2 rounded-full bg-emerald-500"></div>
              <p className="text-slate-400 text-xs font-black uppercase tracking-widest">Terminés</p>
            </div>
            <p className="text-5xl font-black text-slate-800 tracking-tighter">{completed.length}</p>
          </div>
        </div>
      )}

      <div className="space-y-16">
        {isDashboard ? (
          renderHorizontalScroll(null, projects)
        ) : (
          <>
            {renderHorizontalScroll("Projets Actifs", inProgress)}
            {renderHorizontalScroll("Archives & Réussites", completed)}
          </>
        )}
      </div>

      <style>{`
        .hide-scrollbar::-webkit-scrollbar { display: none; }
        .hide-scrollbar { -ms-overflow-style: none; scrollbar-width: none; }
        @keyframes fadeIn {
          from { opacity: 0; transform: translateY(20px); }
          to { opacity: 1; transform: translateY(0); }
        }
        .animate-fadeIn { animation: fadeIn 0.6s cubic-bezier(0.2, 0.8, 0.2, 1) forwards; }
      `}</style>
    </div>
  );
};

export default ProjectList;
