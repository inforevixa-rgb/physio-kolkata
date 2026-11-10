// Minimal service worker placeholder. The app's existing registration will now resolve.
// No offline caching is enabled to avoid serving stale patient or application data.
self.addEventListener('install', () => self.skipWaiting());
self.addEventListener('activate', (event) => event.waitUntil(self.clients.claim()));
