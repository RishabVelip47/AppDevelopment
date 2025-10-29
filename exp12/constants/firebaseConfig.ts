import { initializeApp, getApps, getApp } from "firebase/app";
import { getAuth, GoogleAuthProvider, RecaptchaVerifier } from "firebase/auth";
import { getFirestore } from "firebase/firestore";

const firebaseConfig = {
  apiKey: "AIzaSyB8SRw5WwxZYwyuBTjEjz3lF59Gw9UhwUA",
  authDomain: "auth-app-60cc3.firebaseapp.com",
  projectId: "auth-app-60cc3",
  storageBucket: "auth-app-60cc3.appspot.com",
  messagingSenderId: "422624538509",
  appId: "1:422624538509:web:678463f3dc7e7cc43cd7c4",
  measurementId: "G-BG9PC91SB1",
};

const app = !getApps().length ? initializeApp(firebaseConfig) : getApp();
const auth = getAuth(app);
const db = getFirestore(app);
const googleProvider = new GoogleAuthProvider();

export { app, auth, db, googleProvider, RecaptchaVerifier, firebaseConfig };
