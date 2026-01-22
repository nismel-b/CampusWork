/**
 * FIREBASE CLOUD MESSAGING (FCM) SERVICE
 * Gère l'envoi de notifications push aux utilisateurs
 * Note: Les notifications réelles nécessitent Firebase Cloud Functions côté serveur
 */

// src/api/services/notificationService.ts
/**
 * FIREBASE CLOUD MESSAGING (FCM) SERVICE - VERSION CORRIGÉE
 * Gère l'envoi de notifications push aux utilisateurs
 * Utilise Supabase Database au lieu de Firestore
 */

import { supabaseDatabaseService } from './supabaseDatabaseService';
import { TABLES } from '../config/supabase';

interface Notification {
  id?: string;
  user_id: string; // ✅ snake_case pour Supabase
  title: string;
  message: string;
  type: 'evaluation' | 'new_project' | 'comment' | 'system';
  read: boolean;
  created_at: string; // ✅ snake_case
}

export const notificationService = {
  /**
   * Notifie un étudiant qu'il a reçu une évaluation
   */
  notifyEvaluation: async (
    userId: string, 
    projectTitle: string, 
    grade: string
  ): Promise<void> => {
    try {
      console.log(`📧 FCM: Envoi notification évaluation à l'utilisateur ${userId}`);
      
      const notification: Partial<Notification> = {
        user_id: userId,
        title: '📝 Nouvelle Évaluation',
        message: `Votre projet "${projectTitle}" a été évalué avec la note ${grade}`,
        type: 'evaluation',
        read: false,
        created_at: new Date().toISOString()
      };

      await supabaseDatabaseService.addDocument(TABLES.NOTIFICATIONS || 'notifications', notification);
      
      console.log('✅ Notification évaluation envoyée');
    } catch (error) {
      console.error('❌ Erreur notification évaluation:', error);
    }
  },

  /**
   * Notifie les admins qu'un nouveau projet a été créé
   */
  notifyNewProject: async (
    authorName: string, 
    projectTitle: string
  ): Promise<void> => {
    try {
      console.log(`📧 FCM: Notification nouveau projet aux admins: ${projectTitle}`);
      
      // Récupérer tous les admins
      const users = await supabaseDatabaseService.queryCollection<any>(
        TABLES.USERS,
        [{ column: 'role', operator: '==', value: 'admin' }]
      );

      // Créer une notification pour chaque admin
      const notificationPromises = users.map(admin => {
        const notification: Partial<Notification> = {
          user_id: admin.id,
          title: '🚀 Nouveau Projet',
          message: `${authorName} vient de publier "${projectTitle}"`,
          type: 'new_project',
          read: false,
          created_at: new Date().toISOString()
        };

        return supabaseDatabaseService.addDocument(
          TABLES.NOTIFICATIONS || 'notifications', 
          notification
        );
      });

      await Promise.all(notificationPromises);
      console.log(`✅ ${users.length} notifications envoyées aux admins`);
    } catch (error) {
      console.error('❌ Erreur notification nouveau projet:', error);
    }
  },

  /**
   * Notifie un utilisateur qu'il a reçu un commentaire
   */
  notifyComment: async (
    userId: string,
    commenterName: string,
    postTitle: string
  ): Promise<void> => {
    try {
      console.log(`📧 FCM: Notification commentaire à l'utilisateur ${userId}`);
      
      const notification: Partial<Notification> = {
        user_id: userId,
        title: '💬 Nouveau Commentaire',
        message: `${commenterName} a commenté votre post "${postTitle}"`,
        type: 'comment',
        read: false,
        created_at: new Date().toISOString()
      };

      await supabaseDatabaseService.addDocument(
        TABLES.NOTIFICATIONS || 'notifications', 
        notification
      );
      
      console.log('✅ Notification commentaire envoyée');
    } catch (error) {
      console.error('❌ Erreur notification commentaire:', error);
    }
  },

  /**
   * Récupère les notifications d'un utilisateur
   */
  getUserNotifications: async (userId: string): Promise<Notification[]> => {
    try {
      const notifications = await supabaseDatabaseService.queryCollection<Notification>(
        TABLES.NOTIFICATIONS || 'notifications',
        [{ column: 'user_id', operator: '==', value: userId }],
        'created_at',
        'desc',
        20
      );

      return notifications;
    } catch (error) {
      console.error('❌ Erreur récupération notifications:', error);
      return [];
    }
  },

  /**
   * Marque une notification comme lue
   */
  markAsRead: async (notificationId: string): Promise<void> => {
    try {
      await supabaseDatabaseService.updateDocument(
        TABLES.NOTIFICATIONS || 'notifications', 
        notificationId, 
        { read: true }
      );
    } catch (error) {
      console.error('❌ Erreur marquage notification:', error);
    }
  },

  /**
   * Marque toutes les notifications d'un utilisateur comme lues
   */
  markAllAsRead: async (userId: string): Promise<void> => {
    try {
      const notifications = await supabaseDatabaseService.queryCollection<Notification>(
        TABLES.NOTIFICATIONS || 'notifications',
        [
          { column: 'user_id', operator: '==', value: userId },
          { column: 'read', operator: '==', value: false }
        ]
      );

      const updatePromises = notifications.map(notif => 
        supabaseDatabaseService.updateDocument(
          TABLES.NOTIFICATIONS || 'notifications', 
          notif.id!, 
          { read: true }
        )
      );

      await Promise.all(updatePromises);
      console.log(`✅ ${notifications.length} notifications marquées comme lues`);
    } catch (error) {
      console.error('❌ Erreur marquage toutes notifications:', error);
    }
  },

  /**
   * Supprime une notification
   */
  deleteNotification: async (notificationId: string): Promise<void> => {
    try {
      await supabaseDatabaseService.deleteDocument(
        TABLES.NOTIFICATIONS || 'notifications', 
        notificationId
      );
    } catch (error) {
      console.error('❌ Erreur suppression notification:', error);
    }
  }
};