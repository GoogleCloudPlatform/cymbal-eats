import { initializeApp } from 'firebase/app';
import { getFirestore } from 'firebase/firestore';

const firebaseConfig = {
  projectId: "cymbal-eats",
};
const app = initializeApp(firebaseConfig);

export async function getDb() {
  return await getFirestore();
}
