import { useState, useEffect } from 'react';
import { User } from '../../types';

// 📋 Types de notifications
export type NotificationType = 
  | 'comment_reply'      // Réponse à un commentaire
  | 'post_reply'         // Réponse à une discussion
  | 'post_like'          // Like sur une discussion
  | 'project_like'       // Like sur un projet
  | 'comment_like'       // Like sur un commentaire
  | 'project_evaluation' // Évaluation d'un projet
  | 'post_deleted'       // Post supprimé par admin
  | 'project_deleted'    // Projet supprimé
  | 'account_approved'   // Compte approuvé
  | 'account_banned'     // Compte banni
  | 'new_project';       // Nouveau projet publié

export interface Notification {
  id: string;
  userId: string;           // Destinataire
  type: NotificationType;
  title: string;
  message: string;
  actorName?: string;       // Qui a fait l'action
  relatedId?: string;       // ID du post/projet/commentaire concerné
  relatedTitle?: string;    // Titre du post/projet
  read: boolean;
  createdAt: string;
  link?: string;            // Lien vers l'élément concerné
}

// 🔔 Hook personnalisé pour gérer les notifications
export const useNotifications = (currentUser: User | null) => {
  const [notifications, setNotifications] = useState<Notification[]>([]);
  const [unreadCount, setUnreadCount] = useState(0);

  // Charger les notifications depuis le localStorage au démarrage
  useEffect(() => {
    if (!currentUser) return;
    
    const stored = localStorage.getItem(`notifications_${currentUser.id}`);
    if (stored) {
      const parsed: Notification[] = JSON.parse(stored);
      setNotifications(parsed);
      setUnreadCount(parsed.filter(n => !n.read).length);
    }
  }, [currentUser]);

  // Sauvegarder dans localStorage à chaque changement
  useEffect(() => {
    if (!currentUser || notifications.length === 0) return;
    
    localStorage.setItem(
      `notifications_${currentUser.id}`,
      JSON.stringify(notifications)
    );
    setUnreadCount(notifications.filter(n => !n.read).length);
  }, [notifications, currentUser]);

  // 📨 Ajouter une nouvelle notification
  const addNotification = (notification: Omit<Notification, 'id' | 'createdAt' | 'read'>) => {
    const newNotif: Notification = {
      ...notification,
      id: `notif-${Date.now()}-${Math.random()}`,
      createdAt: new Date().toISOString(),
      read: false
    };

    setNotifications(prev => [newNotif, ...prev]);
    
    // Limiter à 50 notifications max
    setNotifications(prev => prev.slice(0, 50));
  };

  // ✅ Marquer comme lu
  const markAsRead = (notificationId: string) => {
    setNotifications(prev =>
      prev.map(n => n.id === notificationId ? { ...n, read: true } : n)
    );
  };

  // ✅ Marquer toutes comme lues
  const markAllAsRead = () => {
    setNotifications(prev => prev.map(n => ({ ...n, read: true })));
  };

  // 🗑️ Supprimer une notification
  const deleteNotification = (notificationId: string) => {
    setNotifications(prev => prev.filter(n => n.id !== notificationId));
  };

  // 🗑️ Tout effacer
  const clearAll = () => {
    if (window.confirm('Voulez-vous vraiment supprimer toutes les notifications ?')) {
      setNotifications([]);
      if (currentUser) {
        localStorage.removeItem(`notifications_${currentUser.id}`);
      }
    }
  };

  return {
    notifications,
    unreadCount,
    addNotification,
    markAsRead,
    markAllAsRead,
    deleteNotification,
    clearAll
  };
};

// 🎨 Fonction utilitaire pour obtenir l'icône et la couleur selon le type
export const getNotificationStyle = (type: NotificationType) => {
  const styles = {
    comment_reply: {
      icon: '💬',
      color: 'blue',
      bgClass: 'bg-blue-50',
      textClass: 'text-blue-600',
      borderClass: 'border-blue-200'
    },
    post_reply: {
      icon: '📝',
      color: 'blue',
      bgClass: 'bg-blue-50',
      textClass: 'text-blue-600',
      borderClass: 'border-blue-200'
    },
    post_like: {
      icon: '❤️',
      color: 'red',
      bgClass: 'bg-red-50',
      textClass: 'text-red-600',
      borderClass: 'border-red-200'
    },
    project_like: {
      icon: '❤️',
      color: 'red',
      bgClass: 'bg-red-50',
      textClass: 'text-red-600',
      borderClass: 'border-red-200'
    },
    comment_like: {
      icon: '❤️',
      color: 'red',
      bgClass: 'bg-red-50',
      textClass: 'text-red-600',
      borderClass: 'border-red-200'
    },
    project_evaluation: {
      icon: '📊',
      color: 'purple',
      bgClass: 'bg-purple-50',
      textClass: 'text-purple-600',
      borderClass: 'border-purple-200'
    },
    post_deleted: {
      icon: '🗑️',
      color: 'orange',
      bgClass: 'bg-orange-50',
      textClass: 'text-orange-600',
      borderClass: 'border-orange-200'
    },
    project_deleted: {
      icon: '🗑️',
      color: 'orange',
      bgClass: 'bg-orange-50',
      textClass: 'text-orange-600',
      borderClass: 'border-orange-200'
    },
    account_approved: {
      icon: '✅',
      color: 'green',
      bgClass: 'bg-green-50',
      textClass: 'text-green-600',
      borderClass: 'border-green-200'
    },
    account_banned: {
      icon: '🚫',
      color: 'red',
      bgClass: 'bg-red-50',
      textClass: 'text-red-600',
      borderClass: 'border-red-200'
    },
    new_project: {
      icon: '🚀',
      color: 'emerald',
      bgClass: 'bg-emerald-50',
      textClass: 'text-emerald-600',
      borderClass: 'border-emerald-200'
    }
  };

  return styles[type] || styles.post_like;
};

// 📝 Fonctions helper pour créer des notifications spécifiques
export const NotificationHelpers = {
  // 💬 Quelqu'un répond à votre commentaire
  createCommentReply: (userId: string, actorName: string, postTitle: string, postId: string): Omit<Notification, 'id' | 'createdAt' | 'read'> => ({
    userId,
    type: 'comment_reply',
    title: 'Nouvelle réponse',
    message: `${actorName} a répondu à votre commentaire sur "${postTitle}"`,
    actorName,
    relatedId: postId,
    relatedTitle: postTitle,
    link: `/discussion/${postId}`
  }),

  // 📝 Quelqu'un répond à votre post
  createPostReply: (userId: string, actorName: string, postTitle: string, postId: string): Omit<Notification, 'id' | 'createdAt' | 'read'> => ({
    userId,
    type: 'post_reply',
    title: 'Nouveau commentaire',
    message: `${actorName} a commenté votre discussion "${postTitle}"`,
    actorName,
    relatedId: postId,
    relatedTitle: postTitle,
    link: `/discussion/${postId}`
  }),

  // ❤️ Quelqu'un like votre post
  createPostLike: (userId: string, actorName: string, postTitle: string, postId: string): Omit<Notification, 'id' | 'createdAt' | 'read'> => ({
    userId,
    type: 'post_like',
    title: 'Nouveau like',
    message: `${actorName} a aimé votre discussion "${postTitle}"`,
    actorName,
    relatedId: postId,
    relatedTitle: postTitle,
    link: `/discussion/${postId}`
  }),

  // ❤️ Quelqu'un like votre projet
  createProjectLike: (userId: string, actorName: string, projectTitle: string, projectId: string): Omit<Notification, 'id' | 'createdAt' | 'read'> => ({
    userId,
    type: 'project_like',
    title: 'Nouveau like',
    message: `${actorName} a aimé votre projet "${projectTitle}"`,
    actorName,
    relatedId: projectId,
    relatedTitle: projectTitle,
    link: `/project/${projectId}`
  }),

  // 📊 Évaluation de projet
  createProjectEvaluation: (userId: string, evaluatorName: string, projectTitle: string, grade: string, projectId: string): Omit<Notification, 'id' | 'createdAt' | 'read'> => ({
    userId,
    type: 'project_evaluation',
    title: 'Nouvelle évaluation',
    message: `${evaluatorName} a évalué votre projet "${projectTitle}" avec la note ${grade}`,
    actorName: evaluatorName,
    relatedId: projectId,
    relatedTitle: projectTitle,
    link: `/project/${projectId}`
  }),

  // 🗑️ Post supprimé
  createPostDeleted: (userId: string, postTitle: string): Omit<Notification, 'id' | 'createdAt' | 'read'> => ({
    userId,
    type: 'post_deleted',
    title: 'Discussion supprimée',
    message: `Votre discussion "${postTitle}" a été supprimée par un administrateur`,
    relatedTitle: postTitle
  }),
   createProjectDeleted: (recipientId: string, projectTitle: string) => ({
    id: `notif-${Date.now()}-${Math.random()}`,
    userId: recipientId,
    type: 'project_deleted' as const,
    title: '🗑️ Projet supprimé',
    message: `Votre projet "${projectTitle}" a été supprimé par un administrateur`,
    read: false,
    createdAt: new Date().toISOString(),
    link: '/projects'
  }),

  /*// 🗑️ Projet supprimé
  createProjectDeleted: (userId: string, projectTitle: string): Omit<Notification, 'id' | 'createdAt' | 'read'> => ({
    userId,
    type: 'project_deleted',
    title: 'Projet supprimé',
    message: `Votre projet "${projectTitle}" a été supprimé`,
    relatedTitle: projectTitle
  }),*/

  // ✅ Compte approuvé
  createAccountApproved: (userId: string): Omit<Notification, 'id' | 'createdAt' | 'read'> => ({
    userId,
    type: 'account_approved',
    title: 'Compte approuvé !',
    message: 'Votre compte a été approuvé. Vous pouvez maintenant accéder à toutes les fonctionnalités.'
  }),

  // 🚫 Compte banni
  createAccountBanned: (userId: string): Omit<Notification, 'id' | 'createdAt' | 'read'> => ({
    userId,
    type: 'account_banned',
    title: 'Compte suspendu',
    message: 'Votre compte a été suspendu. Contactez un administrateur pour plus d\'informations.'
  }),

  // 🚀 Nouveau projet (pour les enseignants/admins)
  createNewProject: (userId: string, authorName: string, projectTitle: string, projectId: string): Omit<Notification, 'id' | 'createdAt' | 'read'> => ({
    userId,
    type: 'new_project',
    title: 'Nouveau projet',
    message: `${authorName} a publié un nouveau projet : "${projectTitle}"`,
    actorName: authorName,
    relatedId: projectId,
    relatedTitle: projectTitle,
    link: `/project/${projectId}`
  })
};