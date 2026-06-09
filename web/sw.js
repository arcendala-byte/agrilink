self.addEventListener("install", function(event) {
  console.log("Service Worker installed");
  self.skipWaiting();
});

self.addEventListener("activate", function(event) {
  console.log("Service Worker activated");
});

self.addEventListener("fetch", function(event) {
  event.respondWith(fetch(event.request));
});

self.addEventListener("push", function(event) {
  if (event.data) {
    const data = event.data.json();
    const options = {
      body: data.notification.body,
      icon: "/icons/icon-192.png",
      badge: "/icons/icon-192.png",
      vibrate: [200, 100, 200],
      data: {
        url: data.data?.click_action || "/"
      }
    };
    event.waitUntil(self.registration.showNotification(data.notification.title, options));
  }
});

self.addEventListener("notificationclick", function(event) {
  event.notification.close();
  const urlToOpen = event.notification.data?.url || "/";
  event.waitUntil(clients.openWindow(urlToOpen));
});
