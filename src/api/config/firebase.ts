
import { initializeApp } from "firebase/app";
import { getAuth, GoogleAuthProvider } from 'firebase/auth';
import { getFirestore } from 'firebase/firestore';
import { getMessaging, isSupported } from 'firebase/messaging';

const firebaseConfig = {
  apiKey: "AIzaSyBok247FQsxeKmrONSVv30bXflvT3THfb8",
  authDomain: "campuswork.firebaseapp.com",
  projectId: "campuswork",
  storageBucket: "campuswork.firebasestorage.app",
  messagingSenderId: "737984533050",
  appId: "1:737984533050:web:cfdb77314519661361db03"
};


const app = initializeApp(firebaseConfig);
export const auth = getAuth(app);
export const db = getFirestore(app);
export const googleProvider = new GoogleAuthProvider();
// Firebase Cloud Messaging (optionnel, uniquement si supporté)
export const messaging = (async () => {
  try {
    const supported = await isSupported();
    return supported ? getMessaging(app) : null;
  } catch {
    return null;
  }
})();
googleProvider.setCustomParameters({
  prompt: 'select_account' // Force la sélection du compte à chaque connexion
});