// Import the functions you need from the SDKs you need
import { initializeApp } from "firebase/app";
import { getAnalytics } from "firebase/analytics";
// TODO: Add SDKs for Firebase products that you want to use
// https://firebase.google.com/docs/web/setup#available-libraries

// Your web app's Firebase configuration
// For Firebase JS SDK v7.20.0 and later, measurementId is optional
const firebaseConfig = {
  apiKey: "AIzaSyDUZXuhQnvS3fw2RxEtKIsdgFqi4HsQsco",
  authDomain: "interactive-storytelling-1323c.firebaseapp.com",
  databaseURL: "https://interactive-storytelling-1323c-default-rtdb.asia-southeast1.firebasedatabase.app",
  projectId: "interactive-storytelling-1323c",
  storageBucket: "interactive-storytelling-1323c.appspot.com",
  messagingSenderId: "120027546584",
  appId: "1:120027546584:web:91120db9ac0d769526a8ad",
  measurementId: "G-0KTH0HS81G"
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);
const analytics = getAnalytics(app);