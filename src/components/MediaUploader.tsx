/*import React, { useState } from 'react';
import { apiGateway } from '../api/gateway-supabase';

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
      </label>*/

      {/* Preview actuel */}
      /*{currentUrl && (
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
      )}*/

      {/* Zone d'upload */}
      /*{!currentUrl && (
        <div className="space-y-4">*/
          {/* Toggle pour vidéos */}
         /* {type === 'video' && (
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
          )}*/

          {/* Upload fichier */}
          /*{(type === 'image' || videoInputType === 'upload') && (
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
              </div>*/

              {/* Barre de progression */}
              /*{uploading && (
                <div className="absolute bottom-0 left-0 right-0 h-2 bg-slate-200 rounded-b-[2rem] overflow-hidden">
                  <div 
                    className="h-full bg-blue-600 transition-all duration-300 ease-out"
                    style={{ width: `${progress}%` }}
                  />
                </div>
              )}
            </label>
          )}*/

          {/* Input lien vidéo */}
          /*{type === 'video' && videoInputType === 'link' && (
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
      )}*/

      {/* Message d'erreur */}
      /*{error && (
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

export default MediaUploader;*/

// src/components/MediaUploader.tsx
import React, { useState } from 'react';
import { apiGateway } from '../../api/gateway-supabase'; // 🆕 Nouveau gateway

interface MediaUploaderProps {
  type: 'image' | 'video';
  label: string;
  currentUrl?: string;
  onUploadComplete: (url: string, videoType?: 'youtube' | 'vimeo' | 'cloudinary') => void;
  onRemove: () => void;
  maxSize: number; // En MB
}

const MediaUploader: React.FC<MediaUploaderProps> = ({
  type,
  label,
  currentUrl,
  onUploadComplete,
  onRemove,
  maxSize,
}) => {
  const [isUploading, setIsUploading] = useState(false);
  const [uploadProgress, setUploadProgress] = useState(0);
  const [error, setError] = useState<string | null>(null);
  const [externalLink, setExternalLink] = useState('');
  const [linkType, setLinkType] = useState<'upload' | 'youtube' | 'vimeo'>('upload');

  const handleFileUpload = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;

    // Validation de la taille
    const fileSizeMB = file.size / (1024 * 1024);
    if (fileSizeMB > maxSize) {
      setError(`Le fichier dépasse ${maxSize}MB. Taille actuelle: ${fileSizeMB.toFixed(2)}MB`);
      return;
    }

    // Validation du type
    if (type === 'image' && !file.type.startsWith('image/')) {
      setError('Veuillez sélectionner une image valide');
      return;
    }
    if (type === 'video' && !file.type.startsWith('video/')) {
      setError('Veuillez sélectionner une vidéo valide');
      return;
    }

    setIsUploading(true);
    setError(null);
    setUploadProgress(0);

    try {
      let url: string;

      if (type === 'image') {
        console.log('📤 Upload image vers Supabase Storage...');
        // Simuler la progression
        const interval = setInterval(() => {
          setUploadProgress(prev => Math.min(prev + 10, 90));
        }, 200);

        url = await apiGateway.storage.uploadCover(file);
        
        clearInterval(interval);
        setUploadProgress(100);
      } else {
        console.log('📤 Upload vidéo vers Supabase Storage...');
        const interval = setInterval(() => {
          setUploadProgress(prev => Math.min(prev + 5, 90));
        }, 300);

        url = await apiGateway.storage.uploadVideo(file);
        
        clearInterval(interval);
        setUploadProgress(100);
      }

      console.log('✅ Upload réussi:', url);
      onUploadComplete(url, 'cloudinary'); // Type par défaut pour uploads locaux
      
      setTimeout(() => {
        setIsUploading(false);
        setUploadProgress(0);
      }, 500);
    } catch (error: any) {
      console.error('❌ Erreur upload:', error);
      setError(error.message || 'Erreur lors de l\'upload');
      setIsUploading(false);
      setUploadProgress(0);
    }
  };

  const handleExternalLink = () => {
    if (!externalLink.trim()) {
      setError('Veuillez entrer un lien valide');
      return;
    }

    // Détection automatique du type de lien
    let detectedType: 'youtube' | 'vimeo' | 'cloudinary' = 'cloudinary';
    
    if (externalLink.includes('youtube.com') || externalLink.includes('youtu.be')) {
      detectedType = 'youtube';
    } else if (externalLink.includes('vimeo.com')) {
      detectedType = 'vimeo';
    }

    console.log('🔗 Lien externe détecté:', detectedType, externalLink);
    onUploadComplete(externalLink, detectedType);
    setExternalLink('');
    setError(null);
  };

  const handleRemove = () => {
    if (window.confirm('Voulez-vous vraiment supprimer ce média ?')) {
      onRemove();
      setError(null);
      setExternalLink('');
    }
  };

  return (
    <div className="space-y-4">
      <label className="text-[10px] font-black text-slate-400 uppercase tracking-widest px-4 block">
        {label}
      </label>

      {/* Média existant */}
      {currentUrl && !isUploading && (
        <div className="relative group">
          {type === 'image' ? (
            <div className="relative rounded-3xl overflow-hidden border-2 border-slate-100 shadow-lg">
              <img
                src={currentUrl}
                alt="Preview"
                className="w-full h-64 object-cover"
              />
              <div className="absolute inset-0 bg-black/50 opacity-0 group-hover:opacity-100 transition-opacity flex items-center justify-center gap-4">
                <button
                  onClick={handleRemove}
                  className="px-6 py-3 bg-red-600 text-white rounded-2xl font-black text-xs uppercase hover:bg-red-700 transition-all"
                >
                  Supprimer
                </button>
              </div>
            </div>
          ) : (
            <div className="relative rounded-3xl overflow-hidden border-2 border-slate-100 shadow-lg bg-black">
              {currentUrl.includes('youtube') || currentUrl.includes('vimeo') ? (
                <iframe
                  src={
                    currentUrl.includes('youtube')
                      ? currentUrl.replace('watch?v=', 'embed/').split('&')[0]
                      : currentUrl.replace('vimeo.com/', 'player.vimeo.com/video/')
                  }
                  className="w-full h-64"
                  allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
                  allowFullScreen
                />
              ) : (
                <video src={currentUrl} controls className="w-full h-64" />
              )}
              <div className="absolute top-4 right-4">
                <button
                  onClick={handleRemove}
                  className="px-6 py-3 bg-red-600 text-white rounded-2xl font-black text-xs uppercase hover:bg-red-700 transition-all shadow-xl"
                >
                  Supprimer
                </button>
              </div>
            </div>
          )}
        </div>
      )}

      {/* Zone d'upload */}
      {!currentUrl && !isUploading && (
        <div className="space-y-4">
          {/* Sélecteur de type pour vidéos */}
          {type === 'video' && (
            <div className="flex gap-2 p-1 bg-slate-100 rounded-2xl">
              <button
                onClick={() => setLinkType('upload')}
                className={`flex-1 py-3 rounded-xl text-xs font-black uppercase transition-all ${
                  linkType === 'upload'
                    ? 'bg-white text-blue-600 shadow-md'
                    : 'text-slate-400 hover:text-slate-600'
                }`}
              >
                📤 Upload Local
              </button>
              <button
                onClick={() => setLinkType('youtube')}
                className={`flex-1 py-3 rounded-xl text-xs font-black uppercase transition-all ${
                  linkType === 'youtube'
                    ? 'bg-white text-red-600 shadow-md'
                    : 'text-slate-400 hover:text-slate-600'
                }`}
              >
                ▶️ YouTube
              </button>
              <button
                onClick={() => setLinkType('vimeo')}
                className={`flex-1 py-3 rounded-xl text-xs font-black uppercase transition-all ${
                  linkType === 'vimeo'
                    ? 'bg-white text-blue-600 shadow-md'
                    : 'text-slate-400 hover:text-slate-600'
                }`}
              >
                🎬 Vimeo
              </button>
            </div>
          )}

          {/* Upload de fichier */}
          {(type === 'image' || linkType === 'upload') && (
            <div className="border-4 border-dashed border-slate-200 rounded-[2.5rem] p-10 text-center hover:border-blue-300 transition-all cursor-pointer bg-slate-50">
              <input
                type="file"
                accept={type === 'image' ? 'image/*' : 'video/*'}
                onChange={handleFileUpload}
                className="hidden"
                id={`${type}-upload`}
              />
              <label htmlFor={`${type}-upload`} className="cursor-pointer">
                <div className="w-16 h-16 bg-blue-100 rounded-2xl mx-auto mb-4 flex items-center justify-center">
                  <svg className="w-8 h-8 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M7 16a4 4 0 01-.88-7.903A5 5 0 1115.9 6L16 6a5 5 0 011 9.9M15 13l-3-3m0 0l-3 3m3-3v12" />
                  </svg>
                </div>
                <p className="font-black text-slate-900 mb-2">
                  Cliquez pour sélectionner {type === 'image' ? 'une image' : 'une vidéo'}
                </p>
                <p className="text-xs text-slate-500 font-medium">
                  Taille max: {maxSize}MB • {type === 'image' ? 'JPG, PNG, GIF' : 'MP4, MOV, AVI'}
                </p>
              </label>
            </div>
          )}

          {/* Lien externe (YouTube/Vimeo) */}
          {type === 'video' && linkType !== 'upload' && (
            <div className="space-y-3">
              <div className="relative">
                <input
                  type="url"
                  value={externalLink}
                  onChange={(e) => setExternalLink(e.target.value)}
                  placeholder={`Coller le lien ${linkType === 'youtube' ? 'YouTube' : 'Vimeo'}`}
                  className="w-full px-8 py-5 bg-slate-50 border-2 border-slate-100 rounded-[2rem] font-bold text-slate-900 outline-none focus:border-blue-500 transition-all"
                />
              </div>
              <button
                onClick={handleExternalLink}
                className="w-full py-4 bg-blue-600 text-white rounded-2xl font-black uppercase text-xs tracking-widest hover:bg-blue-700 transition-all"
              >
                Valider le lien
              </button>
            </div>
          )}
        </div>
      )}

      {/* Barre de progression */}
      {isUploading && (
        <div className="space-y-4 p-8 bg-blue-50 rounded-3xl border-2 border-blue-100">
          <div className="flex items-center justify-between mb-2">
            <span className="text-sm font-black text-blue-900">Upload en cours...</span>
            <span className="text-sm font-black text-blue-600">{uploadProgress}%</span>
          </div>
          <div className="w-full h-3 bg-blue-100 rounded-full overflow-hidden">
            <div
              className="h-full bg-blue-600 transition-all duration-300 rounded-full"
              style={{ width: `${uploadProgress}%` }}
            />
          </div>
        </div>
      )}

      {/* Erreur */}
      {error && (
        <div className="p-6 bg-red-50 border-2 border-red-200 rounded-2xl">
          <div className="flex items-start gap-3">
            <svg className="w-5 h-5 text-red-600 flex-shrink-0 mt-0.5" fill="currentColor" viewBox="0 0 20 20">
              <path fillRule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clipRule="evenodd" />
            </svg>
            <p className="text-sm font-bold text-red-800">{error}</p>
          </div>
        </div>
      )}
    </div>
  );
};

export default MediaUploader;