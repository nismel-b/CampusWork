/**
 * NOVU NOTIFICATION SERVICE
 * Ce service gère l'intégration avec Novu pour les notifications en temps réel.
 * - Le frontend utilise @novu/browser pour le centre de notifications (Inbox).
 * - Le déclenchement des notifications (Trigger) se fait via votre API Backend (sécurisé).
 */

export const notificationService = {
  /**
   * Initialise le centre de notification (Inbox/Bell).
   * À appeler dans App.tsx ou Header.tsx après la connexion utilisateur.
   */
  initNotificationCenter: (userId: string) => {
    const novuAppId = process.env.NOVU_APP_ID || "VOTRE_NOVU_APP_ID";
    console.log(`[Novu Frontend] Initialisation du centre pour le subscriber : ${userId}`);
    // Plus tard, vous pourrez décommenter ceci :
    /*
    import { NovuProvider } from '@novu/browser';
    // Logic pour monter l'Inbox Novu sur l'élément ICONS.Bell
    */
  },

  /**
   * Simule un appel à votre backend pour déclencher une notification Novu.
   * On ne trigger JAMAIS Novu directement depuis le front avec l'API Key secrète.
   */
  trigger: async (workflowId: string, subscriberId: string, payload: any) => {
    console.log(`[Novu Backend] Déclenchement workflow: ${workflowId} pour: ${subscriberId}`, payload);
    
    // Structure de votre futur appel API Backend :
    /*
    try {
      const response = await fetch('/api/notifications/trigger', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ workflowId, subscriberId, payload })
      });
      return await response.json();
    } catch (e) {
      console.error("Erreur trigger notification:", e);
    }
    */
    return true;
  },

  /**
   * Notification : Nouveau projet soumis (pour les Admins/Lecturers)
   */
  notifyNewProject: async (studentName: string, projectTitle: string) => {
    return await notificationService.trigger('new-project-submission', 'admin_global', {
      studentName,
      projectTitle,
      date: new Date().toLocaleDateString()
    });
  },

  /**
   * Notification : Projet évalué (pour l'Étudiant)
   */
  notifyEvaluation: async (studentId: string, projectTitle: string, grade: string) => {
    return await notificationService.trigger('project-evaluated', studentId, {
      projectTitle,
      grade,
      message: `Votre projet "${projectTitle}" a été noté : ${grade}`
    });
  },

  /**
   * Notification : Nouveau commentaire sur une discussion
   */
  notifyNewComment: async (authorId: string, postTitle: string, commentAuthor: string) => {
    return await notificationService.trigger('new-comment', authorId, {
      postTitle,
      commentAuthor
    });
  }
};