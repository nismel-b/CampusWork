
import { User, UserRole } from '../../types';
import { INITIAL_USERS } from '../../mockData';
import { firestoreService } from './firestoreService';

const delay = (ms: number = 500) => new Promise(res => setTimeout(res, ms));

/**
 * SERVICE D'AUTHENTIFICATION (Architecture Firebase Auth)
 * Prêt pour l'intégration du SDK Firebase (v9+).
 * Gère l'authentification et la récupération des rôles via Firestore.
 */
export const authService = {
  /**
   * Connexion via Google (Simule Firebase GoogleAuthProvider)
   */
  loginWithGoogle: async (): Promise<User> => {
    await delay(1000);
    console.log("Firebase Auth: Déclenchement du flux GoogleAuthProvider...");
    
    // Logique cible :
    // 1. const result = await signInWithPopup(auth, provider);
    // 2. const profile = await firestoreService.getDocument('users', result.user.uid);
    // 3. return profile;

    return INITIAL_USERS[1]; // Retourne Marie Dubois (Étudiante) pour le test
  },

  /**
   * Connexion classique (Simule signInWithEmailAndPassword)
   */
  login: async (email: string, pass: string): Promise<User> => {
    await delay(800);
    console.log(`Firebase Auth: Tentative de connexion pour ${email}...`);
    
    // Simulation de la vérification en base de données
    const user = INITIAL_USERS.find(u => u.email.toLowerCase() === email.toLowerCase());
    
    if (!user) throw new Error("Aucun compte associé à cet email.");
    if (user.pending) throw new Error("Votre compte est en attente d'approbation par un administrateur.");
    if (user.banned) throw new Error("Ce compte a été suspendu pour non-respect des règles.");

    return user;
  },

  /**
   * Inscription (Simule createUserWithEmailAndPassword)
   * Crée l'utilisateur dans Firebase Auth puis son profil dans Firestore avec son rôle.
   */
  register: async (userData: Partial<User> & { password?: string }): Promise<User> => {
    await delay(1200);
    console.log("Firebase Auth: Création de l'utilisateur et du profil Firestore...");
    
    // Le rôle est crucial ici pour les accès futurs
    const newUser: User = {
      id: `fb-${Date.now()}`,
      name: userData.name || 'Nouvel Étudiant',
      email: userData.email || '',
      role: userData.role || UserRole.STUDENT, // Attribution du rôle
      matricule: userData.matricule,
      level: userData.level,
      pending: true,
      avatar: `https://api.dicebear.com/7.x/avataaars/svg?seed=${userData.name}`
    };

    // Simulation de l'ajout dans Firestore via le service dédié
    await firestoreService.addDocument('users', newUser);
    return newUser;
  },

  /**
   * Réinitialisation de mot de passe (Simule sendPasswordResetEmail)
   */
  resetPassword: async (email: string): Promise<void> => {
    await delay(500);
    console.log(`Firebase Auth: Email de réinitialisation envoyé à ${email}`);
  },

  /**
   * Déconnexion (Simule signOut)
   */
  logout: async (): Promise<void> => {
    await delay(300);
    console.log("Firebase Auth: Session fermée.");
  }
};
