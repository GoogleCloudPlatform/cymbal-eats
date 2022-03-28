import { initializeApp } from 'firebase/app';
import { getFirestore } from 'firebase/firestore';

const firebaseConfig = {
  projectId: process.env.VUE_APP_PROJECT_ID
};
const app = initializeApp(firebaseConfig);

export async function getDb() {
  return await getFirestore();
}
