import React, { useState, useEffect, useRef } from 'react';

interface PDFPreviewModalProps {
  fileUrl: string;
  fileName: string;
  onClose: () => void;
}

const PDFPreviewModal: React.FC<PDFPreviewModalProps> = ({ fileUrl, fileName, onClose }) => {
  const [scale, setScale] = useState(100);
  const [isLoading, setIsLoading] = useState(true);
  const [hasError, setHasError] = useState(false);
  const iframeRef = useRef<HTMLIFrameElement>(null);

  // Gestion de la touche Échap pour fermer
  useEffect(() => {
    const handleEscape = (e: KeyboardEvent) => {
      if (e.key === 'Escape') onClose();
    };
    document.addEventListener('keydown', handleEscape);
    return () => document.removeEventListener('keydown', handleEscape);
  }, [onClose]);

  // Prévenir le scroll du body quand la modal est ouverte
  useEffect(() => {
    document.body.style.overflow = 'hidden';
    return () => {
      document.body.style.overflow = 'unset';
    };
  }, []);

  const handleDownload = async () => {
    try {
      const response = await fetch(fileUrl);
      const blob = await response.blob();
      const url = window.URL.createObjectURL(blob);
      const link = document.createElement('a');
      link.href = url;
      link.download = fileName;
      document.body.appendChild(link);
      link.click();
      document.body.removeChild(link);
      window.URL.revokeObjectURL(url);
    } catch (error) {
      console.error('Erreur de téléchargement:', error);
      alert('Impossible de télécharger le fichier');
    }
  };

  const handleIframeLoad = () => {
    setIsLoading(false);
  };

  const handleIframeError = () => {
    setIsLoading(false);
    setHasError(true);
  };

  return (
    <div 
      className="fixed inset-0 z-[60] flex items-center justify-center p-4 animate-fadeIn"
      role="dialog"
      aria-modal="true"
      aria-labelledby="pdf-modal-title"
    >
      {/* Backdrop */}
      <div 
        className="absolute inset-0 bg-slate-900/90 dark:bg-black/95 backdrop-blur-xl"
        onClick={onClose}
        aria-hidden="true"
      />

      {/* Modal */}
      <div className="relative bg-white dark:bg-slate-800 rounded-3xl w-full max-w-6xl h-[90vh] shadow-2xl flex flex-col overflow-hidden animate-modalScale border border-slate-200 dark:border-slate-700">
        {/* Header */}
        <div className="flex items-center justify-between p-6 border-b border-slate-200 dark:border-slate-700 bg-slate-50 dark:bg-slate-900/50 shrink-0">
          <div className="flex items-center gap-4 min-w-0 flex-1">
            <div className="w-12 h-12 bg-red-100 dark:bg-red-900/30 rounded-2xl flex items-center justify-center shrink-0">
              <svg className="w-6 h-6 text-red-600 dark:text-red-400" fill="currentColor" viewBox="0 0 20 20">
                <path fillRule="evenodd" d="M4 4a2 2 0 012-2h4.586A2 2 0 0112 2.586L15.414 6A2 2 0 0116 7.414V16a2 2 0 01-2 2H6a2 2 0 01-2-2V4zm2 6a1 1 0 011-1h6a1 1 0 110 2H7a1 1 0 01-1-1zm1 3a1 1 0 100 2h6a1 1 0 100-2H7z" clipRule="evenodd" />
              </svg>
            </div>
            <div className="min-w-0 flex-1">
              <h3 
                id="pdf-modal-title"
                className="text-xl font-black text-slate-900 dark:text-white truncate"
              >
                {fileName}
              </h3>
              <p className="text-xs text-slate-500 dark:text-slate-400 font-medium">Prévisualisation PDF</p>
            </div>
          </div>

          <div className="flex items-center gap-3 shrink-0">
            {/* Zoom controls */}
            <div className="hidden sm:flex items-center gap-2 bg-white dark:bg-slate-700 rounded-2xl p-2 border border-slate-200 dark:border-slate-600">
              <button
                onClick={() => setScale(Math.max(50, scale - 25))}
                className="p-2 hover:bg-slate-100 dark:hover:bg-slate-600 rounded-xl transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
                title="Zoom arrière (50% min)"
                disabled={scale <= 50}
                aria-label="Réduire le zoom"
              >
                <svg className="w-5 h-5 text-slate-600 dark:text-slate-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0zM13 10H7" />
                </svg>
              </button>
              <span className="text-sm font-bold text-slate-700 dark:text-slate-300 min-w-[60px] text-center">
                {scale}%
              </span>
              <button
                onClick={() => setScale(Math.min(200, scale + 25))}
                className="p-2 hover:bg-slate-100 dark:hover:bg-slate-600 rounded-xl transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
                title="Zoom avant (200% max)"
                disabled={scale >= 200}
                aria-label="Augmenter le zoom"
              >
                <svg className="w-5 h-5 text-slate-600 dark:text-slate-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0zM10 7v3m0 0v3m0-3h3m-3 0H7" />
                </svg>
              </button>
            </div>

            {/* Download button */}
            <button
              onClick={handleDownload}
              className="px-4 sm:px-6 py-3 bg-blue-600 hover:bg-blue-700 text-white rounded-2xl font-black uppercase tracking-widest text-xs transition-all shadow-lg flex items-center gap-2 hover:shadow-xl"
              aria-label="Télécharger le PDF"
            >
              <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4" />
              </svg>
              <span className="hidden sm:inline">Télécharger</span>
            </button>

            {/* Close button */}
            <button
              onClick={onClose}
              className="p-3 hover:bg-red-50 dark:hover:bg-red-900/20 text-slate-400 dark:text-slate-500 hover:text-red-600 dark:hover:text-red-400 rounded-2xl transition-all"
              title="Fermer (Échap)"
              aria-label="Fermer la prévisualisation"
            >
              <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
              </svg>
            </button>
          </div>
        </div>

        {/* PDF Viewer */}
        <div className="flex-1 overflow-auto bg-slate-100 dark:bg-slate-900 p-4 sm:p-6 relative">
          {isLoading && !hasError && (
            <div className="absolute inset-0 flex items-center justify-center bg-slate-100 dark:bg-slate-900">
              <div className="flex flex-col items-center gap-4">
                <div className="w-16 h-16 border-4 border-blue-600 border-t-transparent rounded-full animate-spin" />
                <p className="text-slate-600 dark:text-slate-400 font-bold">Chargement du PDF...</p>
              </div>
            </div>
          )}

          {hasError ? (
            <div className="flex items-center justify-center h-full">
              <div className="text-center p-8 bg-white dark:bg-slate-800 rounded-2xl shadow-lg max-w-md">
                <div className="w-16 h-16 bg-red-100 dark:bg-red-900/30 rounded-full flex items-center justify-center mx-auto mb-4">
                  <svg className="w-8 h-8 text-red-600 dark:text-red-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                  </svg>
                </div>
                <h4 className="text-lg font-black text-slate-900 dark:text-white mb-2">
                  Erreur de chargement
                </h4>
                <p className="text-sm text-slate-600 dark:text-slate-400 mb-4">
                  Impossible d'afficher ce PDF. Essayez de le télécharger.
                </p>
                <button
                  onClick={handleDownload}
                  className="px-6 py-3 bg-blue-600 hover:bg-blue-700 text-white rounded-xl font-bold transition-all"
                >
                  Télécharger quand même
                </button>
              </div>
            </div>
          ) : (
            <div className="flex justify-center" style={{ minHeight: 'calc(90vh - 250px)' }}>
              <div 
                className="transition-transform duration-200"
                style={{ 
                  transform: `scale(${scale / 100})`,
                  transformOrigin: 'top center',
                  width: `${100 * (100 / scale)}%`
                }}
              >
                <iframe
                  ref={iframeRef}
                  src={`${fileUrl}#view=FitH&toolbar=1&navpanes=0`}
                  className="w-full bg-white dark:bg-slate-800 shadow-2xl rounded-2xl border border-slate-200 dark:border-slate-700"
                  style={{ 
                    height: 'calc(90vh - 250px)',
                  }}
                  title={`Prévisualisation de ${fileName}`}
                  onLoad={handleIframeLoad}
                  onError={handleIframeError}
                />
              </div>
            </div>
          )}
        </div>

        {/* Footer avec info */}
        <div className="p-4 border-t border-slate-200 dark:border-slate-700 bg-slate-50 dark:bg-slate-900/50 shrink-0">
          <div className="flex items-center justify-between flex-wrap gap-2">
            <div className="flex items-center gap-3">
              <div className="w-2 h-2 bg-green-500 rounded-full animate-pulse" />
              <span className="text-xs font-bold text-slate-600 dark:text-slate-400">
                Visualisation sécurisée
              </span>
            </div>
            <p className="text-xs text-slate-500 dark:text-slate-500 font-medium">
              💡 Utilisez les contrôles de zoom ou CTRL+molette
            </p>
          </div>
        </div>
      </div>

      <style>{`
        @keyframes modalScale {
          from { opacity: 0; transform: scale(0.95) translateY(20px); }
          to { opacity: 1; transform: scale(1) translateY(0); }
        }
        @keyframes fadeIn {
          from { opacity: 0; }
          to { opacity: 1; }
        }
        .animate-modalScale {
          animation: modalScale 0.3s cubic-bezier(0.34, 1.56, 0.64, 1) forwards;
        }
        .animate-fadeIn {
          animation: fadeIn 0.2s ease-out forwards;
        }
      `}</style>
    </div>
  );
};

export default PDFPreviewModal;