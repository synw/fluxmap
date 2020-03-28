'use strict';
const CACHE_NAME = 'flutter-app-cache';
const RESOURCES = {
  "/manifest.json": "00e0b69b49487ce4f9ff0c5fac8fda49",
"/assets/fonts/MaterialIcons-Regular.ttf": "56d3ffdef7a25659eab6a68a3fbfaf16",
"/assets/LICENSE": "3e57f48cda3c54d8b650e119a00de02b",
"/assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "115e937bb829a890521f72d2e664b632",
"/assets/AssetManifest.json": "2efbb41d7877d10aac9d091f58ccd7b9",
"/assets/FontManifest.json": "3babefb4bbd46bff633bb5f15768249a",
"/index.html": "926cd8008bef60a4e735ba8d18fbac9c",
"/main.dart.js": "1d4c392943dafd68e362cec214098faa",
"/icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"/icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"/favicon.png": "5dcef449791fa27946b3d35ad8803796"
};

self.addEventListener('activate', function (event) {
  event.waitUntil(
    caches.keys().then(function (cacheName) {
      return caches.delete(cacheName);
    }).then(function (_) {
      return caches.open(CACHE_NAME);
    }).then(function (cache) {
      return cache.addAll(Object.keys(RESOURCES));
    })
  );
});

self.addEventListener('fetch', function (event) {
  event.respondWith(
    caches.match(event.request)
      .then(function (response) {
        if (response) {
          return response;
        }
        return fetch(event.request);
      })
  );
});
