import React, { useState } from 'react';
import { X, Upload, Loader, AlertCircle } from 'lucide-react';
import api from '../services/api';

const UploadModal = ({ isOpen, onClose, onUploadSuccess }) => {
  const [loading, setLoading] = useState(false);
  const [progress, setProgress] = useState(0);
  const [error, setError] = useState('');
  const [files, setFiles] = useState([]);
  const [formData, setFormData] = useState({
    title: '',
    abstract: '',
    department: '',
    githubUrl: '',
    keywords: '',
    authorBio: ''
  });

  if (!isOpen) return null;

  const handleFileChange = (e) => {
    setFiles(Array.from(e.target.files));
    setError('');
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (files.length === 0) return setError("Veuillez sélectionner au moins un fichier.");
    
    setLoading(true);
    setError('');
    setProgress(0);

    const data = new FormData();
    Object.keys(formData).forEach(key => data.append(key, formData[key]));
    files.forEach(file => data.append('projectFiles', file));

    try {
      await api.post('/api/projects', data, {
        onUploadProgress: (progressEvent) => {
          const percent = Math.round((progressEvent.loaded * 100) / progressEvent.total);
          setProgress(percent);
        }
      });
      onUploadSuccess();
      onClose();
    } catch (err) {
      setError(err.response?.data?.message || "Erreur lors de l'upload. Vérifiez la taille des fichiers.");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="fixed inset-0 bg-black/60 backdrop-blur-sm flex items-center justify-center z-[100] p-4">
      <div className="bg-white rounded-2xl w-full max-w-2xl max-h-[90vh] overflow-y-auto shadow-2xl">
        <div className="sticky top-0 bg-white px-8 py-6 border-b flex justify-between items-center z-10">
          <div>
            <h2 className="text-2xl font-bold text-slate-900">Publier un projet</h2>
            <p className="text-sm text-slate-500">Remplissez les informations pour la bibliothèque</p>
          </div>
          <button onClick={onClose} className="p-2 hover:bg-slate-100 rounded-full transition-colors">
            <X size={24} className="text-slate-400" />
          </button>
        </div>

        <form onSubmit={handleSubmit} className="p-8 space-y-6">
          {error && (
            <div className="flex items-center gap-2 p-4 bg-red-50 text-red-700 border border-red-100 rounded-xl">
              <AlertCircle size={20} />
              <span className="text-sm font-medium">{error}</span>
            </div>
          )}

          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div className="md:col-span-2">
              <label className="block text-sm font-semibold text-slate-700 mb-2">Titre du projet *</label>
              <input required type="text" className="w-full px-4 py-3 border border-slate-200 rounded-xl focus:ring-2 focus:ring-blue-500 outline-none"
                placeholder="Ex: Système de Gestion de Bibliothèque" value={formData.title} 
                onChange={e => setFormData({...formData, title: e.target.value})} />
            </div>

            <div>
              <label className="block text-sm font-semibold text-slate-700 mb-2">Département / Matière</label>
              <input required type="text" className="w-full px-4 py-3 border border-slate-200 rounded-xl focus:ring-2 focus:ring-blue-500 outline-none"
                placeholder="Ex: Génie Logiciel" value={formData.department} 
                onChange={e => setFormData({...formData, department: e.target.value})} />
            </div>

            <div>
              <label className="block text-sm font-semibold text-slate-700 mb-2">Lien GitHub</label>
              <input type="url" className="w-full px-4 py-3 border border-slate-200 rounded-xl focus:ring-2 focus:ring-blue-500 outline-none"
                placeholder="https://github.com/..." value={formData.githubUrl} 
                onChange={e => setFormData({...formData, githubUrl: e.target.value})} />
            </div>
          </div>

          <div>
            <label className="block text-sm font-semibold text-slate-700 mb-2">Résumé détaillé *</label>
            <textarea required rows="4" className="w-full px-4 py-3 border border-slate-200 rounded-xl focus:ring-2 focus:ring-blue-500 outline-none resize-none"
              placeholder="Décrivez votre projet en quelques lignes..." value={formData.abstract} 
              onChange={e => setFormData({...formData, abstract: e.target.value})} />
          </div>

          <div>
            <label className="block text-sm font-semibold text-slate-700 mb-2">Ma biographie (Optionnel)</label>
            <input type="text" className="w-full px-4 py-3 border border-slate-200 rounded-xl focus:ring-2 focus:ring-blue-500 outline-none"
              placeholder="Étudiant passionné par le Web..." value={formData.authorBio} 
              onChange={e => setFormData({...formData, authorBio: e.target.value})} />
          </div>

          <div className="border-2 border-dashed border-slate-200 rounded-2xl p-8 text-center hover:bg-slate-50 transition-all cursor-pointer relative">
            <input type="file" multiple onChange={handleFileChange} className="absolute inset-0 opacity-0 cursor-pointer" />
            <Upload className="mx-auto text-blue-500 mb-3" size={32} />
            <p className="text-sm font-bold text-slate-700">Cliquez pour ajouter vos fichiers</p>
            <p className="text-xs text-slate-400 mt-1">PDF, ZIP, MP4 (Vidéo max 2 min)</p>
            {files.length > 0 && (
              <div className="mt-4 flex flex-wrap gap-2 justify-center">
                {files.map((f, i) => (
                  <span key={i} className="text-[10px] bg-blue-100 text-blue-700 px-2 py-1 rounded font-bold uppercase">{f.name}</span>
                ))}
              </div>
            )}
          </div>

          {loading && (
            <div className="space-y-2">
              <div className="flex justify-between text-xs font-bold text-blue-600 uppercase tracking-wider">
                <span>Téléchargement en cours</span>
                <span>{progress}%</span>
              </div>
              <div className="w-full bg-slate-100 rounded-full h-2 overflow-hidden">
                <div className="bg-blue-600 h-full transition-all duration-300" style={{ width: `${progress}%` }}></div>
              </div>
            </div>
          )}

          <div className="flex gap-4 pt-4 border-t">
            <button type="button" onClick={onClose} className="flex-1 py-3 border border-slate-200 rounded-xl font-bold text-slate-600 hover:bg-slate-50 transition-all">
              Annuler
            </button>
            <button disabled={loading} type="submit" className="flex-1 py-3 bg-blue-600 text-white rounded-xl font-bold hover:bg-blue-700 shadow-lg shadow-blue-200 flex items-center justify-center gap-2 disabled:bg-slate-400">
              {loading ? <Loader className="animate-spin" size={20} /> : "Publier le projet"}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
};

export default UploadModal;