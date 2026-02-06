importScripts("https://www.gstatic.com/firebasejs/10.7.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/10.7.0/firebase-messaging-compat.js");

firebase.initializeApp({
  apiKey: "AIzaSyAp8_ww4_nez_MClt-NOrxOk82Hf7TMG6A",
  authDomain: "iot-chong-trom-xe-may.firebaseapp.com",
  databaseURL: "https://iot-chong-trom-xe-may-default-rtdb.asia-southeast1.firebasedatabase.app",
  projectId: "iot-chong-trom-xe-may",
  storageBucket: "iot-chong-trom-xe-may.firebasestorage.app",
  messagingSenderId: "644959023893",
  appId: "1:644959023893:web:ab3e39c5c949253b73ef1c",
  measurementId: "G-LN7QV593HN"
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  self.registration.showNotification(
    payload.notification.title,
    {
      body: payload.notification.body,
    }
  );
});
