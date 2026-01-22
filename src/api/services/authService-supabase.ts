// src/api/services/authService-supabase.ts
import {
  signInWithEmailAndPassword,
  createUserWithEmailAndPassword,
  signInWithPopup,
  signOut,
  sendPasswordResetEmail,
  updateProfile,
  User as FirebaseUser,
} from 'firebase/auth';
import { auth, googleProvider } from '../config/firebase';
import { supabaseDatabaseService } from './supabaseDatabaseService';
import { TABLES } from '../config/supabase';
import { User, UserRole } from '../../../types';

/**
 * SERVICE D'AUTHENTIFICATION (Firebase Auth + Supabase DB)
 */

export const authService = {
  /**
   * Connexion via Google OAuth
   */
  loginWithGoogle: async (): Promise<User> => {
    try {
      console.log('🔐 Firebase Auth: Déclenchement Google OAuth...');

      const result = await signInWithPopup(auth, googleProvider);
      const firebaseUser = result.user;

      // Vérifier si l'utilisateur existe dans Supabase
      let userProfile = await supabaseDatabaseService.getDocument<User>(
        TABLES.USERS,
        firebaseUser.uid
      );

      if (!userProfile) {
        console.log('🆕 Nouveau compte Google, création dans Supabase...');

        const newUserData = {
          name: firebaseUser.displayName || 'Utilisateur Google',
          email: firebaseUser.email || '',
          avatar:
            firebaseUser.photoURL ||
            `https://api.dicebear.com/7.x/avataaars/svg?seed=${firebaseUser.email}`,
          role: UserRole.STUDENT,
          pending: true,
          banned: false,
        };

        await supabaseDatabaseService.setDocument(
          TABLES.USERS,
          firebaseUser.uid,
          newUserData
        );

        userProfile = await supabaseDatabaseService.getDocument<User>(
          TABLES.USERS,
          firebaseUser.uid
        );
      }

      if (!userProfile) {
        throw new Error('Erreur lors de la création du profil');
      }

      // Validation du compte
      if (userProfile.pending) {
        throw new Error('Votre compte est en attente d\'approbation.');
      }
      if (userProfile.banned) {
        throw new Error('Ce compte a été suspendu.');
      }

      console.log('✅ Connexion Google réussie:', userProfile.name);
      return userProfile;
    } catch (error: any) {
      console.error('❌ Erreur connexion Google:', error);

      if (error.code === 'auth/popup-closed-by-user') {
        throw new Error('La fenêtre de connexion a été fermée.');
      }
      if (error.code === 'auth/cancelled-popup-request') {
        throw new Error('Connexion annulée.');
      }

      throw new Error(error.message || 'Erreur lors de la connexion avec Google');
    }
  },

  /**
   * Connexion classique email/password
   */
  login: async (email: string, password: string): Promise<User> => {
    try {
      console.log(`🔐 Firebase Auth: Connexion pour ${email}...`);

      const userCredential = await signInWithEmailAndPassword(auth, email, password);
      const firebaseUser = userCredential.user;

      // Récupérer le profil dans Supabase
      const userProfile = await supabaseDatabaseService.getDocument<User>(
        TABLES.USERS,
        firebaseUser.uid
      );

      if (!userProfile) {
        throw new Error('Profil introuvable. Contactez un administrateur.');
      }

      if (userProfile.pending) {
        throw new Error('Votre compte est en attente d\'approbation.');
      }
      if (userProfile.banned) {
        throw new Error('Ce compte a été suspendu.');
      }

      console.log('✅ Connexion réussie:', userProfile.name);
      return userProfile;
    } catch (error: any) {
      console.error('❌ Erreur connexion:', error);

      if (error.code === 'auth/user-not-found') {
        throw new Error('Aucun compte associé à cet email.');
      }
      if (error.code === 'auth/wrong-password') {
        throw new Error('Mot de passe incorrect.');
      }
      if (error.code === 'auth/invalid-email') {
        throw new Error('Format d\'email invalide.');
      }
      if (error.code === 'auth/too-many-requests') {
        throw new Error('Trop de tentatives. Réessayez plus tard.');
      }
      if (error.code === 'auth/invalid-credential') {
        throw new Error('Email ou mot de passe incorrect.');
      }

      throw new Error(error.message || 'Erreur lors de la connexion');
    }
  },

  /**
   * Inscription
   */
  register: async (userData: {
    name: string;
    email: string;
    password: string;
    matricule?: string;
    level?: string;
    department?: string;
    role?: UserRole;
  }): Promise<User> => {
    try {
      console.log('📝 Firebase Auth: Création utilisateur...');

      // 1. Créer le compte Firebase
      const userCredential = await createUserWithEmailAndPassword(
        auth,
        userData.email,
        userData.password
      );
      const firebaseUser = userCredential.user;

      // 2. Mettre à jour le displayName
      await updateProfile(firebaseUser, {
        displayName: userData.name,
      });

      // 3. Créer le profil dans Supabase
      const newUserData = {
        name: userData.name,
        email: userData.email,
        avatar: `https://api.dicebear.com/7.x/avataaars/svg?seed=${userData.email}`,
        role: userData.role || UserRole.STUDENT,
        matricule: userData.matricule,
        level: userData.level,
        department: userData.department,
        pending: true,
        banned: false,
      };

      await supabaseDatabaseService.setDocument(
        TABLES.USERS,
        firebaseUser.uid,
        newUserData
      );

      const newUser = await supabaseDatabaseService.getDocument<User>(
        TABLES.USERS,
        firebaseUser.uid
      );

      if (!newUser) {
        throw new Error('Erreur lors de la création du profil');
      }

      console.log('✅ Inscription réussie:', newUser.name);
      return newUser;
    } catch (error: any) {
      console.error('❌ Erreur inscription:', error);

      if (error.code === 'auth/email-already-in-use') {
        throw new Error('Cet email est déjà utilisé.');
      }
      if (error.code === 'auth/invalid-email') {
        throw new Error('Format d\'email invalide.');
      }
      if (error.code === 'auth/weak-password') {
        throw new Error('Le mot de passe doit contenir au moins 6 caractères.');
      }

      throw new Error(error.message || 'Erreur lors de l\'inscription');
    }
  },

  /**
   * Réinitialisation de mot de passe
   */
  resetPassword: async (email: string): Promise<void> => {
    try {
      await sendPasswordResetEmail(auth, email);
      console.log(`📧 Email de réinitialisation envoyé à ${email}`);
    } catch (error: any) {
      console.error('❌ Erreur réinitialisation:', error);

      if (error.code === 'auth/user-not-found') {
        throw new Error('Aucun compte associé à cet email.');
      }
      if (error.code === 'auth/invalid-email') {
        throw new Error('Format d\'email invalide.');
      }

      throw new Error('Erreur lors de l\'envoi de l\'email');
    }
  },

  /**
   * Déconnexion
   */
  logout: async (): Promise<void> => {
    try {
      await signOut(auth);
      console.log('👋 Firebase Auth: Session fermée.');
    } catch (error) {
      console.error('❌ Erreur déconnexion:', error);
      throw new Error('Erreur lors de la déconnexion');
    }
  },

  /**
   * Récupérer l'utilisateur connecté
   */
  getCurrentUser: async (): Promise<User | null> => {
    try {
      const firebaseUser = auth.currentUser;

      if (!firebaseUser) {
        return null;
      }

      const userProfile = await supabaseDatabaseService.getDocument<User>(
        TABLES.USERS,
        firebaseUser.uid
      );
      return userProfile;
    } catch (error) {
      console.error('❌ Erreur getCurrentUser:', error);
      return null;
    }
  },

  /**
   * Écouter les changements d'authentification
   */
  onAuthStateChanged: (callback: (user: User | null) => void) => {
    return auth.onAuthStateChanged(async (firebaseUser: FirebaseUser | null) => {
      if (firebaseUser) {
        try {
          const userProfile = await supabaseDatabaseService.getDocument<User>(
            TABLES.USERS,
            firebaseUser.uid
          );
          callback(userProfile);
        } catch (error) {
          console.error('❌ Erreur onAuthStateChanged:', error);
          callback(null);
        }
      } else {
        callback(null);
      }
    });
  },
};