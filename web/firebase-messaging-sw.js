importScripts("https://www.gstatic.com/firebasejs/10.8.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/10.8.0/firebase-messaging-compat.js");

firebase.initializeApp({
  apiKey: "AIzaSyDTSQjJjyGRL_4QxtyPbrqmaC6CvdqGBeY",
  authDomain: "agrilinknew-4ba5f.firebaseapp.com",
  projectId: "agrilinknew-4ba5f",
  storageBucket: "agrilinknew-4ba5f.firebasestorage.app",
  messagingSenderId: "414602884782",
  appId: "1:414602884782:web:0b229b003c7a5296bdf3f",
  measurementId: "G-L7JDZZN88F"
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  console.log("Background message received:", payload);
  const notificationTitle = payload.notification?.title || "AgriLink Update";
  const notificationOptions = {
    body: payload.notification?.body || "You have a new notification",
    icon: "/icons/icon-192.png",
    badge: "/icons/icon-192.png",
    data: {
      url: payload.data?.click_action || "/"
    }
  };
  return self.registration.showNotification(notificationTitle, notificationOptions);
});
