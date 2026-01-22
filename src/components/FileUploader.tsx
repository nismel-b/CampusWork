

// src/components/FileUploader.tsx
import React, { useState } from 'react';
import { apiGateway } from '../api/gateway-supabase'; // 🆕 Nouveau gateway

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