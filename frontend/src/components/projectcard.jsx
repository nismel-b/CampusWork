import React from 'react';
import { FileText, Github, Download } from 'lucide-react';

const ProjectCard = ({ project }) => {
  return (
    <div className="bg-white rounded-xl p-6 shadow-sm hover:shadow-md transition-shadow border border-gray-100">
      <div className="flex justify-between items-start mb-4">
        <div>
          <span className={`px-2 py-1 rounded text-xs font-semibold ${
            project.status === 'public' ? 'bg-green-100 text-green-700' : 'bg-yellow-100 text-yellow-700'
          }`}>
            {project.status === 'public' ? 'Public' : 'Privé'}
          </span>
          <h3 className="text-lg font-bold text-gray-900 mt-2">{project.title}</h3>
          <p className="text-sm text-gray-500">{project.department} • {project.year}</p>
        </div>
      </div>

      <p className="text-gray-600 text-sm mb-4 line-clamp-2">
        {project.abstract}
      </p>

      <div className="flex flex-wrap gap-2 mb-4">
        {project.keywords.map((tag, i) => (
          <span key={i} className="px-2 py-1 bg-gray-100 text-gray-600 text-xs rounded-md">
            #{tag}
          </span>
        ))}
      </div>

      <div className="flex items-center justify-between pt-4 border-t border-gray-100">
        <div className="flex gap-2">
            {project.githubUrl && (
                <a href={project.githubUrl} target="_blank" rel="noreferrer" className="p-2 hover:bg-gray-100 rounded-full text-gray-600">
                    <Github size={18} />
                </a>
            )}
            {project.files && project.files.length > 0 && (
                 <a href={`http://localhost:4001${project.files[0].url}`} target="_blank" rel="noreferrer" className="p-2 hover:bg-gray-100 rounded-full text-blue-600">
                    <Download size={18} />
                 </a>
            )}
        </div>
        <button className="text-sm font-medium text-blue-600 hover:text-blue-800">
          Voir détails →
        </button>
      </div>
    </div>
  );
};

export default ProjectCard;