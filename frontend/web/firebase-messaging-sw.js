importScripts("https://www.gstatic.com/firebasejs/9.10.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/9.10.0/firebase-messaging-compat.js");

firebase.initializeApp({
  apiKey: 'AIzaSyBChV9ezsc_PAxIMaXriWLOZG8LZxP_7lg',
  appId: '1:32513509893:web:dbf924100cd6f3d789ea6c',
  messagingSenderId: '32513509893',
  projectId: 'reallystick-d807d',
  authDomain: 'reallystick-d807d.firebaseapp.com',
  storageBucket: 'reallystick-d807d.firebasestorage.app',
});

// Necessary to receive background messages:
const messaging = firebase.messaging();

// Optional:
messaging.onBackgroundMessage((m) => {
  console.log("onBackgroundMessage", m);
});