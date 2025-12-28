import React from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { X, Github, Download, User, Calendar, Book } from 'lucide-react';

const ProjectDetails = ({ project, isOpen, onClose }) => {
  if (!project) return null;

  return (
    <AnimatePresence>
      {isOpen && (
        <>
          <motion.div initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }}
            onClick={onClose} className="fixed inset-0 bg-black/30 backdrop-blur-sm z-[60]" />
          
          <motion.div initial={{ x: '100%' }} animate={{ x: 0 }} exit={{ x: '100%' }} transition={{ type: 'spring', damping: 25, stiffness: 200 }}
            className="fixed right-0 top-0 h-full w-full max-w-xl bg-white shadow-2xl z-[70] overflow-y-auto p-8">
            
            <button onClick={onClose} className="absolute top-6 left-6 p-2 hover:bg-gray-100 rounded-full transition-colors">
              <X size={24} className="text-gray-500" />
            </button>

            <div className="mt-12 space-y-8">
              {/* Vidéo si présente */}
              {project.videoUrl && (
                <div className="rounded-xl overflow-hidden bg-black aspect-video border border-gray-100 shadow-inner">
                   <video src={`http://localhost:4001${project.videoUrl}`} controls className="w-full h-full" />
                </div>
              )}

              <div>
                <h2 className="text-3xl font-bold text-slate-900">{project.title}</h2>
                <div className="flex flex-wrap gap-4 mt-4 text-slate-500">
                  <span className="flex items-center gap-2 bg-slate-100 px-3 py-1 rounded-full text-sm font-medium">
                    <User size={16} /> {project.authorName || "Auteur inconnu"}
                  </span>
                  <span className="flex items-center gap-2 bg-slate-100 px-3 py-1 rounded-full text-sm font-medium">
                    <Book size={16} /> {project.department}
                  </span>
                  <span className="flex items-center gap-2 bg-slate-100 px-3 py-1 rounded-full text-sm font-medium">
                    <Calendar size={16} /> {project.year}
                  </span>
                </div>
              </div>

              <div>
                <h3 className="font-bold text-lg mb-2">Résumé du projet</h3>
                <p className="text-slate-600 leading-relaxed whitespace-pre-line">{project.abstract}</p>
              </div>

              {project.authorBio && (
                <div className="bg-blue-50 p-4 rounded-xl border border-blue-100">
                  <h4 className="font-semibold text-blue-900 mb-1 italic">À propos de l'auteur</h4>
                  <p className="text-blue-800 text-sm leading-relaxed">{project.authorBio}</p>
                </div>
              )}

              <div className="space-y-3">
                <h3 className="font-bold text-lg">Documents et ressources</h3>
                <div className="grid gap-3">
                  {project.files?.map((file, idx) => (
                    <a key={idx} href={`http://localhost:4001${file.url}`} target="_blank" download
                      className="flex items-center justify-between p-4 border rounded-xl hover:bg-slate-50 transition-all group">
                      <div className="flex items-center gap-3">
                        <div className="p-2 bg-blue-100 text-blue-600 rounded-lg group-hover:bg-blue-600 group-hover:text-white transition-all">
                          <Download size={18} />
                        </div>
                        <span className="font-medium text-slate-700 truncate max-w-xs">{file.originalName}</span>
                      </div>
                      <span className="text-xs text-slate-400">{(file.size / 1024 / 1024).toFixed(2)} MB</span>
                    </a>
                  ))}
                  {project.githubUrl && (
                    <a href={project.githubUrl} target="_blank"
                      className="flex items-center gap-3 p-4 border rounded-xl hover:border-black hover:bg-black hover:text-white transition-all">
                      <Github size={18} />
                      <span className="font-medium">Voir le dépôt GitHub</span>
                    </a>
                  )}
                </div>
              </div>
            </div>
          </motion.div>
        </>
      )}
    </AnimatePresence>
  );
};

export default ProjectDetails;