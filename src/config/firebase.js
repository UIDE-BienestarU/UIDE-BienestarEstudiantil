// src/config/firebase.js

import admin from 'firebase-admin';
import dotenv from 'dotenv';

dotenv.config(); // Carga las variables de .env

// Verifica que las variables existan
if (!process.env.FIREBASE_PROJECT_ID || 
    !process.env.FIREBASE_PRIVATE_KEY || 
    !process.env.FIREBASE_CLIENT_EMAIL) {
  throw new Error('Faltan variables de entorno de Firebase. Revisa tu .env');
}

// Reemplaza los \n literales por saltos de línea reales
const privateKey = process.env.FIREBASE_PRIVATE_KEY.replace(/\\n/g, '\n');

admin.initializeApp({
  credential: admin.credential.cert({
    projectId: process.env.FIREBASE_PROJECT_ID,
    privateKey: privateKey,
    clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
  }),
});

console.log('Firebase Admin SDK inicializado correctamente con variables de entorno');

export default admin;