// firebaseConfig.ts

// Import the required Firebase functions
import { initializeApp } from "firebase/app";
import { getFirestore } from "firebase/firestore"; // ✅ You forgot this import

// Firebase configuration (your existing config)
const firebaseConfig = {
  apiKey: "AIzaSyBt4JTUIYBleR_uXn0a3puyIKfJFTA0YWs",
  authDomain: "todo-list-f4088.firebaseapp.com",
  projectId: "todo-list-f4088",
  storageBucket: "todo-list-f4088.firebasestorage.app",
  messagingSenderId: "563992151165",
  appId: "1:563992151165:web:732f1b16e2e6131ea31d14",
  measurementId: "G-WHZ9293X0K",
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);

// Initialize Firestore Database
const db = getFirestore(app);

// Export for use in other files
export { db };
