import { initializeApp } from 'firebase/app';
import { getFirestore } from 'firebase/firestore';
import {
  onAuthStateChanged,
  getAuth,
  GoogleAuthProvider,
  signInWithPopup,
  signOut
} from 'firebase/auth';

const firebaseConfig = {
  projectId: process.env.VUE_APP_PROJECT_ID,
  apiKey: process.env.VUE_APP_API_KEY,
  authDomain: process.env.VUE_APP_AUTH_DOMAIN
};
const app = initializeApp(firebaseConfig);
const auth = getAuth(app);

export async function getDb() {
  return await getFirestore();
}

export async function logIn() {
  const provider = new GoogleAuthProvider();
  provider.setCustomParameters({prompt: 'select_account'});
  const result = await signInWithPopup(auth, provider);
  return result.user;
}

export async function logOut() {
  signOut(auth);
}

export async function getToken() {
  return await auth.currentUser?.getIdToken(true);
}
