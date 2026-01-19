import React, { useState } from 'react';
import { Notification, getNotificationStyle } from './NotificationSystem';

interface NotificationPanelProps {
  notifications: Notification[];
  unreadCount: number;
  onMarkAsRead: (id: string) => void;
  onMarkAllAsRead: () => void;
  onDelete: (id: string) => void;
  onClearAll: () => void;
  onNotificationClick?: (notification: Notification) => void;
}

const NotificationPanel: React.FC<NotificationPanelProps> = ({
  notifications,
  unreadCount,
  onMarkAsRead,
  onMarkAllAsRead,
  onDelete,
  onClearAll,
  onNotificationClick
}) => {
  const [isOpen, setIsOpen] = useState(false);
  const [filter, setFilter] = useState<'all' | 'unread'>('all');

  const filteredNotifications = filter === 'unread' 
    ? notifications.filter(n => !n.read)
    : notifications;

  const formatDate = (dateString: string) => {
    const date = new Date(dateString);
    const now = new Date();
    const diffMs = now.getTime() - date.getTime();
    const diffMins = Math.floor(diffMs / 60000);
    const diffHours = Math.floor(diffMs / 3600000);
    const diffDays = Math.floor(diffMs / 86400000);

    if (diffMins < 1) return 'À l\'instant';
    if (diffMins < 60) return `Il y a ${diffMins} min`;
    if (diffHours < 24) return `Il y a ${diffHours}h`;
    if (diffDays < 7) return `Il y a ${diffDays}j`;
    return date.toLocaleDateString('fr-FR');
  };

  const handleNotificationClick = (notif: Notification) => {
    if (!notif.read) {
      onMarkAsRead(notif.id);
    }
    if (onNotificationClick) {
      onNotificationClick(notif);
    }
  };

  return (
    <div className="relative">
      {/* 🔔 Bouton Notification */}
      <button
        onClick={() => setIsOpen(!isOpen)}
        className="relative p-3 rounded-2xl hover:bg-slate-100 transition-all group"
      >
        <svg 
          className="w-6 h-6 text-slate-600 group-hover:text-blue-600 transition-colors" 
          fill="none" 
          stroke="currentColor" 
          viewBox="0 0 24 24"
        >
          <path 
            strokeLinecap="round" 
            strokeLinejoin="round" 
            strokeWidth={2} 
            d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9" 
          />
        </svg>
        
        {/* Badge de compteur */}
        {unreadCount > 0 && (
          <span className="absolute -top-1 -right-1 w-5 h-5 bg-red-500 text-white text-[10px] font-black rounded-full flex items-center justify-center animate-pulse">
            {unreadCount > 9 ? '9+' : unreadCount}
          </span>
        )}
      </button>

      {/* 📋 Panneau des notifications */}
      {isOpen && (
        <>
          {/* Overlay */}
          <div 
            className="fixed inset-0 z-40" 
            onClick={() => setIsOpen(false)}
          />
          
          {/* Panneau */}
          <div className="absolute right-0 mt-2 w-96 max-h-[600px] bg-white rounded-3xl shadow-2xl border border-slate-100 z-50 flex flex-col animate-fadeIn">
            
            {/* En-tête */}
            <div className="p-6 border-b border-slate-100 shrink-0">
              <div className="flex items-center justify-between mb-4">
                <h3 className="text-xl font-black text-slate-900 uppercase italic">
                  Notifications
                </h3>
                {notifications.length > 0 && (
                  <button
                    onClick={onClearAll}
                    className="text-xs text-red-500 hover:text-red-700 font-bold uppercase tracking-widest"
                  >
                    Tout effacer
                  </button>
                )}
              </div>

              {/* Filtres */}
              <div className="flex gap-2">
                <button
                  onClick={() => setFilter('all')}
                  className={`flex-1 py-2 px-4 rounded-xl text-xs font-black uppercase tracking-widest transition-all ${
                    filter === 'all'
                      ? 'bg-blue-600 text-white'
                      : 'bg-slate-100 text-slate-400 hover:bg-slate-200'
                  }`}
                >
                  Toutes ({notifications.length})
                </button>
                <button
                  onClick={() => setFilter('unread')}
                  className={`flex-1 py-2 px-4 rounded-xl text-xs font-black uppercase tracking-widest transition-all ${
                    filter === 'unread'
                      ? 'bg-blue-600 text-white'
                      : 'bg-slate-100 text-slate-400 hover:bg-slate-200'
                  }`}
                >
                  Non lues ({unreadCount})
                </button>
              </div>

              {/* Marquer tout comme lu */}
              {unreadCount > 0 && (
                <button
                  onClick={onMarkAllAsRead}
                  className="mt-3 w-full py-2 text-xs text-blue-600 hover:text-blue-700 font-bold"
                >
                  ✓ Tout marquer comme lu
                </button>
              )}
            </div>

            {/* Liste des notifications */}
            <div className="flex-1 overflow-y-auto custom-scrollbar">
              {filteredNotifications.length === 0 ? (
                <div className="py-20 text-center">
                  <div className="text-6xl mb-4">🔔</div>
                  <p className="text-slate-400 font-bold text-sm">
                    {filter === 'unread' ? 'Aucune notification non lue' : 'Aucune notification'}
                  </p>
                </div>
              ) : (
                <div className="p-4 space-y-2">
                  {filteredNotifications.map((notif) => {
                    const style = getNotificationStyle(notif.type);
                    
                    return (
                      <div
                        key={notif.id}
                        className={`group relative p-4 rounded-2xl border-2 cursor-pointer transition-all ${
                          notif.read
                            ? 'bg-white border-slate-100 hover:border-slate-200'
                            : `${style.bgClass} ${style.borderClass} hover:shadow-md`
                        }`}
                        onClick={() => handleNotificationClick(notif)}
                      >
                        {/* Point non lu */}
                        {!notif.read && (
                          <div className="absolute top-4 right-4 w-2 h-2 bg-blue-500 rounded-full animate-pulse" />
                        )}

                        {/* Icône */}
                        <div className="flex gap-3">
                          <div className="text-2xl flex-shrink-0">
                            {style.icon}
                          </div>
                          
                          <div className="flex-1 min-w-0">
                            {/* Titre */}
                            <h4 className={`font-black text-sm mb-1 ${notif.read ? 'text-slate-700' : style.textClass}`}>
                              {notif.title}
                            </h4>
                            
                            {/* Message */}
                            <p className="text-slate-600 text-xs leading-relaxed mb-2">
                              {notif.message}
                            </p>
                            
                            {/* Date */}
                            <p className="text-slate-400 text-[10px] font-bold uppercase tracking-widest">
                              {formatDate(notif.createdAt)}
                            </p>
                          </div>
                        </div>

                        {/* Actions au survol */}
                        <div className="absolute bottom-2 right-2 opacity-0 group-hover:opacity-100 transition-opacity flex gap-1">
                          {!notif.read && (
                            <button
                              onClick={(e) => {
                                e.stopPropagation();
                                onMarkAsRead(notif.id);
                              }}
                              className="p-1.5 bg-blue-100 text-blue-600 rounded-lg hover:bg-blue-200 transition-all"
                              title="Marquer comme lu"
                            >
                              <svg className="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 13l4 4L19 7" />
                              </svg>
                            </button>
                          )}
                          <button
                            onClick={(e) => {
                              e.stopPropagation();
                              onDelete(notif.id);
                            }}
                            className="p-1.5 bg-red-100 text-red-600 rounded-lg hover:bg-red-200 transition-all"
                            title="Supprimer"
                          >
                            <svg className="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
                            </svg>
                          </button>
                        </div>
                      </div>
                    );
                  })}
                </div>
              )}
            </div>
          </div>
        </>
      )}

      <style>{`
        .custom-scrollbar::-webkit-scrollbar {
          width: 4px;
        }
        .custom-scrollbar::-webkit-scrollbar-track {
          background: transparent;
        }
        .custom-scrollbar::-webkit-scrollbar-thumb {
          background: #cbd5e1;
          border-radius: 10px;
        }
        .custom-scrollbar::-webkit-scrollbar-thumb:hover {
          background: #94a3b8;
        }
      `}</style>
    </div>
  );
};

export default NotificationPanel;