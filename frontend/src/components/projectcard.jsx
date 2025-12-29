import React from 'react';
import { FileText, Github , Download, ExternalLink } from 'lucide-react';

const ProjectCard = ({ project }) => {
  // Gestion de l'URL de l'image (MongoDB/Multer ou Placeholder)
  // Si ton backend stocke l'image dans 'uploads', ajuste l'URL
  const imageUrl = project.coverImage 
    ? `http://localhost:4001${project.coverImage}` 
    : 'https://images.unsplash.com/photo-1517694712202-14dd9538aa97?q=80&w=400&h=200&auto=format&fit=crop';

  return (
    <article className="group bg-white rounded-2xl shadow-sm hover:shadow-xl transition-all duration-300 border border-gray-100 overflow-hidden flex flex-col h-full">
      
      {/* 1. Header Image & Badge */}
      <div className="relative h-44 w-full overflow-hidden">
        <img 
          src={imageUrl} 
          alt={project.title} 
          className="w-full h-full object-cover transition-transform duration-500 group-hover:scale-110"
        />
        <div className="absolute top-3 left-3">
          <span className={`px-3 py-1 rounded-full text-[10px] font-bold uppercase tracking-wider shadow-sm ${
            project.status === 'public' ? 'bg-green-500 text-white' : 'bg-amber-500 text-white'
          }`}>
            {project.status === 'public' ? 'Public' : 'Privé'}
          </span>
        </div>
      </div>

      {/* 2. Contenu principal */}
      <div className="p-5 flex flex-col flex-grow">
        <div className="mb-2">
          <h3 className="text-xl font-bold text-gray-900 line-clamp-1 group-hover:text-indigo-600 transition-colors">
            {project.title}
          </h3>
          <p className="text-xs text-indigo-500 font-medium mt-1">
            {project.department} • {project.year}
          </p>
        </div>

        <p className="text-gray-600 text-sm mb-4 line-clamp-3 flex-grow">
          {project.abstract || project.description}
        </p>

        {/* 3. Tags / Keywords */}
        <div className="flex flex-wrap gap-1.5 mb-5">
          {(project.keywords || project.technologies)?.slice(0, 3).map((tag, i) => (
            <span key={i} className="px-2 py-0.5 bg-indigo-50 text-indigo-700 text-[11px] rounded-md font-medium border border-indigo-100">
              #{tag}
            </span>
          ))}
        </div>

        {/* 4. Footer avec Actions */}
        <div className="flex items-center justify-between pt-4 border-t border-gray-50">
          <div className="flex gap-1">
            {/* Lien GitHub */}
            {project.githubUrl && (
              <a 
                href={project.githubUrl} 
                target="_blank" 
                rel="noreferrer" 
                className="p-2 hover:bg-gray-900 hover:text-white rounded-lg text-gray-500 transition-colors"
                title="Voir sur GitHub"
              >
                <Github size={18} />
              </a>
            )}
            
            {/* Lien de téléchargement (Multer/Node) */}
            {project.files && project.files.length > 0 && (
              <a 
                href={`http://localhost:4001${project.files[0].url}`} 
                target="_blank" 
                rel="noreferrer" 
                className="p-2 hover:bg-blue-50 rounded-lg text-blue-600 transition-colors"
                title="Télécharger les documents"
              >
                <Download size={18} />
              </a>
            )}
          </div>

          <button className="flex items-center gap-1 text-sm font-semibold text-indigo-600 hover:text-indigo-800 transition-all">
            Détails <ExternalLink size={14} />
          </button>
        </div>
      </div>
    </article>
  );
};

export default ProjectCard;