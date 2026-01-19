/*import React, { useState } from 'react';
import { apiGateway } from '../api/gateway-supabase';

interface FileAttachment {
  url: string;
  name: string;
  type: 'pdf' | 'docx' | 'pptx';
  size: number;
  uploadedAt: string;
}

interface FileUploaderProps {
  currentFile?: FileAttachment;
  onUploadComplete: (file: FileAttachment) => void;
  onRemove: () => void;
}

const FileUploader: React.FC<FileUploaderProps> = ({ currentFile, onUploadComplete, onRemove }) => {
  const [uploading, setUploading] = useState(false);
  const [progress, setProgress] = useState(0);
  const [error, setError] = useState<string | null>(null);

  const getFileIcon = (type: string) => {
    switch (type) {
      case 'pdf':
        return (
          <svg className="w-8 h-8 text-red-500" fill="currentColor" viewBox="0 0 20 20">
            <path fillRule="evenodd" d="M4 4a2 2 0 012-2h4.586A2 2 0 0112 2.586L15.414 6A2 2 0 0116 7.414V16a2 2 0 01-2 2H6a2 2 0 01-2-2V4zm2 6a1 1 0 011-1h6a1 1 0 110 2H7a1 1 0 01-1-1zm1 3a1 1 0 100 2h6a1 1 0 100-2H7z" clipRule="evenodd" />
          </svg>
        );
      case 'docx':
        return (
          <svg className="w-8 h-8 text-blue-500" fill="currentColor" viewBox="0 0 20 20">
            <path fillRule="evenodd" d="M4 4a2 2 0 012-2h4.586A2 2 0 0112 2.586L15.414 6A2 2 0 0116 7.414V16a2 2 0 01-2 2H6a2 2 0 01-2-2V4z" clipRule="evenodd" />
          </svg>
        );
      case 'pptx':
        return (
          <svg className="w-8 h-8 text-orange-500" fill="currentColor" viewBox="0 0 20 20">
            <path fillRule="evenodd" d="M4 4a2 2 0 012-2h4.586A2 2 0 0112 2.586L15.414 6A2 2 0 0116 7.414V16a2 2 0 01-2 2H6a2 2 0 01-2-2V4z" clipRule="evenodd" />
          </svg>
        );
      default:
        return null;
    }
  };

  const formatFileSize = (bytes: number): string => {
    if (bytes === 0) return '0 Bytes';
    const k = 1024;
    const sizes = ['Bytes', 'KB', 'MB', 'GB'];
    const i = Math.floor(Math.log(bytes) / Math.log(k));
    return Math.round(bytes / Math.pow(k, i) * 100) / 100 + ' ' + sizes[i];
  };

  const handleFileUpload = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;

    // Validation type
    const allowedTypes = ['application/pdf', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document', 'application/vnd.openxmlformats-officedocument.presentationml.presentation'];
    if (!allowedTypes.includes(file.type)) {
      setError('Format non supporté. Utilisez PDF, DOCX ou PPTX');
      return;
    }

    // Validation taille (max 25MB)
    const maxSize = 25 * 1024 * 1024;
    if (file.size > maxSize) {
      setError('Le fichier dépasse 25MB');
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
      }, 300);

      const uploadedUrl = await apiGateway.storage.upload(file, 'project-documents');
      
      clearInterval(progressInterval);
      setProgress(100);

      // Déterminer le type
      let fileType: 'pdf' | 'docx' | 'pptx' = 'pdf';
      if (file.type.includes('word')) fileType = 'docx';
      if (file.type.includes('presentation')) fileType = 'pptx';

      const attachment: FileAttachment = {
        url: uploadedUrl,
        name: file.name,
        type: fileType,
        size: file.size,
        uploadedAt: new Date().toISOString()
      };

      setTimeout(() => {
        onUploadComplete(attachment);
        setUploading(false);
        setProgress(0);
      }, 500);
    } catch (err: any) {
      setError(err.message || 'Erreur lors de l\'upload');
      setUploading(false);
      setProgress(0);
    }
  };

  return (
    <div className="space-y-4">
      <label className="text-[10px] font-black text-slate-400 uppercase tracking-widest px-4 block">
        Document Annexe (Optionnel)
      </label>*/

      {/* Fichier actuel */}
      /*{currentFile && (
        <div className="bg-white border-2 border-slate-200 rounded-[2rem] p-6 flex items-center gap-4 group hover:border-blue-300 transition-all animate-fadeIn">
          <div className="w-14 h-14 bg-slate-50 rounded-2xl flex items-center justify-center flex-shrink-0 group-hover:scale-110 transition-transform">
            {getFileIcon(currentFile.type)}
          </div>
          
          <div className="flex-1 min-w-0">
            <p className="font-bold text-slate-900 truncate text-sm">{currentFile.name}</p>
            <p className="text-xs text-slate-500 font-medium">{formatFileSize(currentFile.size)} • {currentFile.type.toUpperCase()}</p>
          </div>

          <div className="flex gap-2">
            <a
              href={currentFile.url}
              download={currentFile.name}
              target="_blank"
              rel="noopener noreferrer"
              className="p-3 bg-blue-50 text-blue-600 rounded-xl hover:bg-blue-600 hover:text-white transition-all"
              title="Télécharger"
            >
              <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4" />
              </svg>
            </a>
            <button
              onClick={onRemove}
              className="p-3 bg-red-50 text-red-500 rounded-xl hover:bg-red-500 hover:text-white transition-all"
              title="Supprimer"
            >
              <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
              </svg>
            </button>
          </div>
        </div>
      )}*/

      {/* Zone d'upload */}
      /*{!currentFile && (
        <label className={`
          relative block w-full border-4 border-dashed rounded-[2rem] p-10
          ${uploading ? 'border-blue-400 bg-blue-50' : 'border-slate-200 bg-slate-50 hover:border-blue-400 hover:bg-blue-50'}
          transition-all cursor-pointer group
        `}>
          <input
            type="file"
            accept=".pdf,.docx,.pptx,application/pdf,application/vnd.openxmlformats-officedocument.wordprocessingml.document,application/vnd.openxmlformats-officedocument.presentationml.presentation"
            onChange={handleFileUpload}
            disabled={uploading}
            className="hidden"
          />
          
          <div className="flex flex-col items-center gap-4">
            {uploading ? (
              <>
                <div className="relative w-16 h-16">
                  <svg className="w-16 h-16 animate-spin text-blue-600" fill="none" viewBox="0 0 24 24">
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
                <div className="flex gap-3">
                  <div className="w-12 h-12 bg-red-100 rounded-xl flex items-center justify-center">
                    <svg className="w-6 h-6 text-red-600" fill="currentColor" viewBox="0 0 20 20">
                      <path fillRule="evenodd" d="M4 4a2 2 0 012-2h4.586A2 2 0 0112 2.586L15.414 6A2 2 0 0116 7.414V16a2 2 0 01-2 2H6a2 2 0 01-2-2V4zm2 6a1 1 0 011-1h6a1 1 0 110 2H7a1 1 0 01-1-1zm1 3a1 1 0 100 2h6a1 1 0 100-2H7z" clipRule="evenodd" />
                    </svg>
                  </div>
                  <div className="w-12 h-12 bg-blue-100 rounded-xl flex items-center justify-center">
                    <svg className="w-6 h-6 text-blue-600" fill="currentColor" viewBox="0 0 20 20">
                      <path fillRule="evenodd" d="M4 4a2 2 0 012-2h4.586A2 2 0 0112 2.586L15.414 6A2 2 0 0116 7.414V16a2 2 0 01-2 2H6a2 2 0 01-2-2V4z" clipRule="evenodd" />
                    </svg>
                  </div>
                  <div className="w-12 h-12 bg-orange-100 rounded-xl flex items-center justify-center">
                    <svg className="w-6 h-6 text-orange-600" fill="currentColor" viewBox="0 0 20 20">
                      <path fillRule="evenodd" d="M4 4a2 2 0 012-2h4.586A2 2 0 0112 2.586L15.414 6A2 2 0 0116 7.414V16a2 2 0 01-2 2H6a2 2 0 01-2-2V4z" clipRule="evenodd" />
                    </svg>
                  </div>
                </div>
                <div className="text-center">
                  <p className="text-sm font-black text-slate-800 mb-1">
                    Ajouter un document
                  </p>
                  <p className="text-xs text-slate-500 font-medium">
                    Rapport, présentation ou documentation • Max 25MB
                  </p>
                  <p className="text-[10px] text-slate-400 mt-2 font-bold uppercase tracking-widest">
                    PDF, DOCX, PPTX
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

      <div className="bg-yellow-50 border-2 border-yellow-200 rounded-2xl p-4 flex items-start gap-3">
        <svg className="w-5 h-5 text-yellow-600 flex-shrink-0 mt-0.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
        </svg>
        <p className="text-xs text-yellow-800 font-medium">
          <strong>Note :</strong> Les visiteurs pourront uniquement télécharger ce fichier, pas le consulter en ligne.
        </p>
      </div>
    </div>
  );
};

export default FileUploader;*/

// src/components/FileUploader.tsx
import React, { useState } from 'react';
import { apiGateway } from '../../api/gateway-supabase'; // 🆕 Nouveau gateway

interface AttachedFile {
  name: string;
  url: string;
  size: number;
  type: string;
}

interface FileUploaderProps {
  currentFile?: AttachedFile;
  onUploadComplete: (file: AttachedFile) => void;
  onRemove: () => void;
}

const FileUploader: React.FC<FileUploaderProps> = ({
  currentFile,
  onUploadComplete,
  onRemove,
}) => {
  const [isUploading, setIsUploading] = useState(false);
  const [uploadProgress, setUploadProgress] = useState(0);
  const [error, setError] = useState<string | null>(null);

  const MAX_FILE_SIZE = 10 * 1024 * 1024; // 10MB

  const ACCEPTED_TYPES = [
    'application/pdf',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    'application/msword',
    'application/vnd.openxmlformats-officedocument.presentationml.presentation',
    'application/vnd.ms-powerpoint',
    'application/zip',
    'application/x-rar-compressed',
  ];

  const getFileIcon = (type: string) => {
    if (type.includes('pdf')) {
      return '📄';
    } else if (type.includes('word') || type.includes('document')) {
      return '📝';
    } else if (type.includes('presentation') || type.includes('powerpoint')) {
      return '📊';
    } else if (type.includes('zip') || type.includes('rar')) {
      return '🗜️';
    }
    return '📎';
  };

  const getFileColor = (type: string) => {
    if (type.includes('pdf')) {
      return 'bg-red-50 border-red-200 text-red-600';
    } else if (type.includes('word') || type.includes('document')) {
      return 'bg-blue-50 border-blue-200 text-blue-600';
    } else if (type.includes('presentation') || type.includes('powerpoint')) {
      return 'bg-orange-50 border-orange-200 text-orange-600';
    } else if (type.includes('zip') || type.includes('rar')) {
      return 'bg-purple-50 border-purple-200 text-purple-600';
    }
    return 'bg-slate-50 border-slate-200 text-slate-600';
  };

  const formatFileSize = (bytes: number): string => {
    if (bytes < 1024) return bytes + ' B';
    if (bytes < 1024 * 1024) return (bytes / 1024).toFixed(2) + ' KB';
    return (bytes / (1024 * 1024)).toFixed(2) + ' MB';
  };

  const handleFileUpload = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;

    // Validation de la taille
    if (file.size > MAX_FILE_SIZE) {
      setError(`Le fichier dépasse 10MB. Taille actuelle: ${formatFileSize(file.size)}`);
      return;
    }

    // Validation du type
    if (!ACCEPTED_TYPES.includes(file.type)) {
      setError('Type de fichier non supporté. Formats acceptés: PDF, DOCX, PPTX, ZIP, RAR');
      return;
    }

    setIsUploading(true);
    setError(null);
    setUploadProgress(0);

    try {
      console.log('📤 Upload fichier vers Supabase Storage...');
      
      // Simuler la progression
      const interval = setInterval(() => {
        setUploadProgress(prev => Math.min(prev + 10, 90));
      }, 200);

      // Upload vers Supabase
      const uploadedFile = await apiGateway.storage.uploadFile(file);
      
      clearInterval(interval);
      setUploadProgress(100);

      console.log('✅ Fichier uploadé:', uploadedFile);
      onUploadComplete(uploadedFile);

      setTimeout(() => {
        setIsUploading(false);
        setUploadProgress(0);
      }, 500);
    } catch (error: any) {
      console.error('❌ Erreur upload fichier:', error);
      setError(error.message || 'Erreur lors de l\'upload du fichier');
      setIsUploading(false);
      setUploadProgress(0);
    }
  };

  const handleRemove = () => {
    if (window.confirm('Voulez-vous vraiment supprimer ce fichier ?')) {
      onRemove();
      setError(null);
    }
  };

  return (
    <div className="space-y-4">
      {/* Fichier existant */}
      {currentFile && !isUploading && (
        <div className={`p-6 rounded-3xl border-2 shadow-lg ${getFileColor(currentFile.type)} relative group animate-fadeIn`}>
          <div className="flex items-center gap-4">
            <div className="w-16 h-16 bg-white rounded-2xl flex items-center justify-center text-3xl flex-shrink-0 shadow-inner">
              {getFileIcon(currentFile.type)}
            </div>
            
            <div className="flex-1 min-w-0">
              <p className="font-black text-lg mb-1 truncate">
                {currentFile.name}
              </p>
              <p className="text-sm font-medium opacity-80">
                {formatFileSize(currentFile.size)} • {currentFile.type.split('/')[1].toUpperCase()}
              </p>
            </div>

            <div className="flex gap-2 flex-shrink-0">
              <a
                href={currentFile.url}
                download={currentFile.name}
                target="_blank"
                rel="noopener noreferrer"
                className="px-6 py-3 bg-white rounded-2xl font-black text-xs uppercase hover:shadow-xl transition-all flex items-center gap-2"
              >
                <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4" />
                </svg>
                Télécharger
              </a>
              
              <button
                onClick={handleRemove}
                className="px-6 py-3 bg-red-600 text-white rounded-2xl font-black text-xs uppercase hover:bg-red-700 transition-all"
              >
                Supprimer
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Zone d'upload */}
      {!currentFile && !isUploading && (
        <div className="border-4 border-dashed border-slate-200 rounded-[2.5rem] p-12 text-center hover:border-blue-300 transition-all cursor-pointer bg-slate-50">
          <input
            type="file"
            accept=".pdf,.doc,.docx,.ppt,.pptx,.zip,.rar"
            onChange={handleFileUpload}
            className="hidden"
            id="file-upload"
          />
          <label htmlFor="file-upload" className="cursor-pointer">
            <div className="w-20 h-20 bg-blue-100 rounded-3xl mx-auto mb-6 flex items-center justify-center">
              <svg className="w-10 h-10 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M7 16a4 4 0 01-.88-7.903A5 5 0 1115.9 6L16 6a5 5 0 011 9.9M15 13l-3-3m0 0l-3 3m3-3v12" />
              </svg>
            </div>
            
            <p className="font-black text-slate-900 text-lg mb-3">
              Cliquez pour ajouter un document
            </p>
            
            <p className="text-sm text-slate-500 font-medium mb-6">
              Taille max: 10MB
            </p>

            <div className="grid grid-cols-2 md:grid-cols-4 gap-3 max-w-2xl mx-auto">
              <div className="p-3 bg-red-50 border border-red-100 rounded-xl">
                <p className="text-2xl mb-1">📄</p>
                <p className="text-xs font-black text-red-600">PDF</p>
              </div>
              <div className="p-3 bg-blue-50 border border-blue-100 rounded-xl">
                <p className="text-2xl mb-1">📝</p>
                <p className="text-xs font-black text-blue-600">DOCX</p>
              </div>
              <div className="p-3 bg-orange-50 border border-orange-100 rounded-xl">
                <p className="text-2xl mb-1">📊</p>
                <p className="text-xs font-black text-orange-600">PPTX</p>
              </div>
              <div className="p-3 bg-purple-50 border border-purple-100 rounded-xl">
                <p className="text-2xl mb-1">🗜️</p>
                <p className="text-xs font-black text-purple-600">ZIP</p>
              </div>
            </div>
          </label>
        </div>
      )}

      {/* Barre de progression */}
      {isUploading && (
        <div className="space-y-4 p-8 bg-blue-50 rounded-3xl border-2 border-blue-100 animate-fadeIn">
          <div className="flex items-center gap-4 mb-4">
            <div className="w-12 h-12 bg-blue-100 rounded-2xl flex items-center justify-center animate-pulse">
              <svg className="w-6 h-6 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M7 16a4 4 0 01-.88-7.903A5 5 0 1115.9 6L16 6a5 5 0 011 9.9M15 13l-3-3m0 0l-3 3m3-3v12" />
              </svg>
            </div>
            <div className="flex-1">
              <p className="font-black text-blue-900 mb-1">Upload en cours...</p>
              <p className="text-sm font-bold text-blue-600">{uploadProgress}% complété</p>
            </div>
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
        <div className="p-6 bg-red-50 border-2 border-red-200 rounded-2xl animate-fadeIn">
          <div className="flex items-start gap-3">
            <svg className="w-5 h-5 text-red-600 flex-shrink-0 mt-0.5" fill="currentColor" viewBox="0 0 20 20">
              <path fillRule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clipRule="evenodd" />
            </svg>
            <div>
              <p className="font-black text-red-900 mb-1">Erreur d'upload</p>
              <p className="text-sm font-bold text-red-700">{error}</p>
            </div>
          </div>
        </div>
      )}

      {/* Info */}
      <div className="p-4 bg-slate-50 border border-slate-200 rounded-2xl">
        <p className="text-xs text-slate-600 font-medium text-center">
          💡 Rapport de projet, présentation, code source compressé, etc.
        </p>
      </div>
    </div>
  );
};

export default FileUploader;