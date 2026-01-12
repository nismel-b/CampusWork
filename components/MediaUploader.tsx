import React, { useState } from 'react';
import { apiGateway } from '../api/gateway';

interface MediaUploaderProps {
  type: 'image' | 'video';
  currentUrl?: string;
  onUploadComplete: (url: string, videoType?: 'upload' | 'youtube' | 'vimeo') => void;
  onRemove?: () => void;
  label: string;
  accept?: string;
  maxSize?: number; // en MB
}

const MediaUploader: React.FC<MediaUploaderProps> = ({ 
  type, 
  currentUrl, 
  onUploadComplete, 
  onRemove,
  label,
  accept = type === 'image' ? 'image/*' : 'video/*',
  maxSize = type === 'image' ? 5 : 100
}) => {
  const [uploading, setUploading] = useState(false);
  const [progress, setProgress] = useState(0);
  const [error, setError] = useState<string | null>(null);
  const [videoInputType, setVideoInputType] = useState<'upload' | 'link'>('upload');
  const [videoLinkUrl, setVideoLinkUrl] = useState('');

  const handleFileUpload = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;

    // Validation taille
    const fileSizeMB = file.size / (1024 * 1024);
    if (fileSizeMB > maxSize) {
      setError(`La taille du fichier dépasse ${maxSize}MB`);
      return;
    }

    setUploading(true);
    setError(null);
    setProgress(0);

    try {
      // Simulation de progression
      const progressInterval = setInterval(() => {
        setProgress(prev => {
          if (prev >= 90) {
            clearInterval(progressInterval);
            return 90;
          }
          return prev + 10;
        });
      }, 200);

      const folder = type === 'image' ? 'project-covers' : 'project-videos';
      const uploadedUrl = await apiGateway.storage.upload(file, folder);
      
      clearInterval(progressInterval);
      setProgress(100);
      
      setTimeout(() => {
        onUploadComplete(uploadedUrl, 'upload');
        setUploading(false);
        setProgress(0);
      }, 500);
    } catch (err: any) {
      setError(err.message || 'Erreur lors de l\'upload');
      setUploading(false);
      setProgress(0);
    }
  };

  const handleVideoLinkSubmit = () => {
    if (!videoLinkUrl.trim()) {
      setError('Veuillez entrer une URL valide');
      return;
    }

    // Détection du type de lien
    let videoType: 'youtube' | 'vimeo' | 'upload' = 'upload';
    if (videoLinkUrl.includes('youtube.com') || videoLinkUrl.includes('youtu.be')) {
      videoType = 'youtube';
    } else if (videoLinkUrl.includes('vimeo.com')) {
      videoType = 'vimeo';
    }

    onUploadComplete(videoLinkUrl, videoType);
    setVideoLinkUrl('');
    setError(null);
  };

  const getVideoEmbedUrl = (url: string): string => {
    // YouTube
    if (url.includes('youtube.com/watch?v=')) {
      const videoId = url.split('v=')[1]?.split('&')[0];
      return `https://www.youtube.com/embed/${videoId}`;
    }
    if (url.includes('youtu.be/')) {
      const videoId = url.split('youtu.be/')[1]?.split('?')[0];
      return `https://www.youtube.com/embed/${videoId}`;
    }
    
    // Vimeo
    if (url.includes('vimeo.com/')) {
      const videoId = url.split('vimeo.com/')[1]?.split('?')[0];
      return `https://player.vimeo.com/video/${videoId}`;
    }
    
    return url;
  };

  return (
    <div className="space-y-4">
      <label className="text-[10px] font-black text-slate-400 uppercase tracking-widest px-4 block">
        {label}
      </label>

      {/* Preview actuel */}
      {currentUrl && (
        <div className="relative group animate-fadeIn">
          {type === 'image' ? (
            <img 
              src={currentUrl} 
              alt="Preview" 
              className="w-full h-64 object-cover rounded-[2rem] border-2 border-slate-200"
            />
          ) : (
            <div className="w-full aspect-video rounded-[2rem] border-2 border-slate-200 overflow-hidden bg-black">
              {currentUrl.includes('cloudinary') ? (
                <video 
                  src={currentUrl} 
                  controls 
                  className="w-full h-full"
                  preload="metadata"
                />
              ) : (
                <iframe
                  src={getVideoEmbedUrl(currentUrl)}
                  className="w-full h-full"
                  allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
                  allowFullScreen
                />
              )}
            </div>
          )}
          
          {onRemove && (
            <button
              onClick={onRemove}
              className="absolute top-4 right-4 bg-red-500 text-white p-3 rounded-xl hover:bg-red-600 transition-all shadow-lg opacity-0 group-hover:opacity-100"
              title="Supprimer"
            >
              <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
              </svg>
            </button>
          )}
        </div>
      )}

      {/* Zone d'upload */}
      {!currentUrl && (
        <div className="space-y-4">
          {/* Toggle pour vidéos */}
          {type === 'video' && (
            <div className="flex gap-3 p-2 bg-slate-50 rounded-2xl border border-slate-200">
              <button
                type="button"
                onClick={() => setVideoInputType('upload')}
                className={`flex-1 py-3 rounded-xl text-xs font-black uppercase tracking-widest transition-all ${
                  videoInputType === 'upload' 
                    ? 'bg-blue-600 text-white shadow-lg' 
                    : 'text-slate-400 hover:text-slate-600'
                }`}
              >
                Uploader Fichier
              </button>
              <button
                type="button"
                onClick={() => setVideoInputType('link')}
                className={`flex-1 py-3 rounded-xl text-xs font-black uppercase tracking-widest transition-all ${
                  videoInputType === 'link' 
                    ? 'bg-blue-600 text-white shadow-lg' 
                    : 'text-slate-400 hover:text-slate-600'
                }`}
              >
                Lien YouTube/Vimeo
              </button>
            </div>
          )}

          {/* Upload fichier */}
          {(type === 'image' || videoInputType === 'upload') && (
            <label className={`
              relative block w-full border-4 border-dashed rounded-[2rem] p-12
              ${uploading ? 'border-blue-400 bg-blue-50' : 'border-slate-200 bg-slate-50 hover:border-blue-400 hover:bg-blue-50'}
              transition-all cursor-pointer group
            `}>
              <input
                type="file"
                accept={accept}
                onChange={handleFileUpload}
                disabled={uploading}
                className="hidden"
              />
              
              <div className="flex flex-col items-center gap-4">
                {uploading ? (
                  <>
                    <div className="relative w-20 h-20">
                      <svg className="w-20 h-20 animate-spin text-blue-600" fill="none" viewBox="0 0 24 24">
                        <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4" />
                        <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z" />
                      </svg>
                      <div className="absolute inset-0 flex items-center justify-center">
                        <span className="text-xs font-black text-blue-600">{progress}%</span>
                      </div>
                    </div>
                    <p className="text-sm font-bold text-blue-600 animate-pulse">Upload en cours...</p>
                  </>
                ) : (
                  <>
                    <div className="w-16 h-16 bg-blue-100 rounded-2xl flex items-center justify-center group-hover:scale-110 transition-transform">
                      <svg className="w-8 h-8 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M7 16a4 4 0 01-.88-7.903A5 5 0 1115.9 6L16 6a5 5 0 011 9.9M15 13l-3-3m0 0l-3 3m3-3v12" />
                      </svg>
                    </div>
                    <div className="text-center">
                      <p className="text-sm font-black text-slate-800 mb-1">
                        Glissez votre {type === 'image' ? 'image' : 'vidéo'} ici
                      </p>
                      <p className="text-xs text-slate-500 font-medium">
                        ou cliquez pour parcourir • Max {maxSize}MB
                      </p>
                      <p className="text-[10px] text-slate-400 mt-2 font-bold uppercase tracking-widest">
                        {type === 'image' ? 'JPG, PNG, WEBP' : 'MP4, MOV, AVI'}
                      </p>
                    </div>
                  </>
                )}
              </div>

              {/* Barre de progression */}
              {uploading && (
                <div className="absolute bottom-0 left-0 right-0 h-2 bg-slate-200 rounded-b-[2rem] overflow-hidden">
                  <div 
                    className="h-full bg-blue-600 transition-all duration-300 ease-out"
                    style={{ width: `${progress}%` }}
                  />
                </div>
              )}
            </label>
          )}

          {/* Input lien vidéo */}
          {type === 'video' && videoInputType === 'link' && (
            <div className="space-y-3">
              <div className="flex gap-3">
                <input
                  type="url"
                  value={videoLinkUrl}
                  onChange={(e) => setVideoLinkUrl(e.target.value)}
                  placeholder="https://youtube.com/watch?v=..."
                  className="flex-1 px-6 py-4 bg-white border-2 border-slate-200 rounded-2xl font-medium text-slate-800 outline-none focus:border-blue-500 transition-all"
                />
                <button
                  type="button"
                  onClick={handleVideoLinkSubmit}
                  className="px-8 py-4 bg-blue-600 text-white rounded-2xl font-black uppercase tracking-widest text-xs hover:bg-blue-700 transition-all shadow-lg"
                >
                  Ajouter
                </button>
              </div>
              <p className="text-xs text-slate-500 font-medium px-4">
                💡 Formats supportés : YouTube, Vimeo, ou lien direct
              </p>
            </div>
          )}
        </div>
      )}

      {/* Message d'erreur */}
      {error && (
        <div className="bg-red-50 border-2 border-red-200 rounded-2xl p-4 flex items-center gap-3 animate-fadeIn">
          <svg className="w-5 h-5 text-red-500 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
          </svg>
          <p className="text-sm font-bold text-red-700">{error}</p>
          <button
            onClick={() => setError(null)}
            className="ml-auto text-red-400 hover:text-red-600 transition-colors"
          >
            <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
            </svg>
          </button>
        </div>
      )}
    </div>
  );
};

export default MediaUploader;