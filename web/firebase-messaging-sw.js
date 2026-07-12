importScripts("https://www.gstatic.com/firebasejs/10.7.1/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/10.7.1/firebase-messaging-compat.js");

firebase.initializeApp({
  apiKey: "AIzaSyCvVUyX1_3tuxHlhS3rdCruV08_FISvIG8",
  appId: "1:925585407650:web:73c0b063dc0398cf9461fb",
  messagingSenderId: "925585407650",
  projectId: "school-pulse-3d95b",
  authDomain: "school-pulse-3d95b.firebaseapp.com",
  storageBucket: "school-pulse-3d95b.firebasestorage.app",
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  console.log(
    "[firebase-messaging-sw.js] Received background message ",
    payload
  );
  const notificationTitle = payload.notification.title;
  const notificationOptions = {
    body: payload.notification.body,
    icon: "/favicon.png",
  };

  self.registration.showNotification(notificationTitle, notificationOptions);
});
