'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';
const RESOURCES = {
  "favicon.png": "5dcef449791fa27946b3d35ad8803796",
"canvaskit/canvaskit.js": "c2b4e5f3d7a3d82aed024e7249a78487",
"canvaskit/profiling/canvaskit.js": "ae2949af4efc61d28a4a80fffa1db900",
"canvaskit/profiling/canvaskit.wasm": "95e736ab31147d1b2c7b25f11d4c32cd",
"canvaskit/canvaskit.wasm": "4b83d89d9fecbea8ca46f2f760c5a9ba",
"index.html": "7e896ab0e821c05854620381644be19d",
"/": "7e896ab0e821c05854620381644be19d",
"flutter.js": "eb2682e33f25cd8f1fc59011497c35f8",
"icons/apple-icon-120x120.png": "1259790f1c3b0ef780ecba06dfd5b44d",
"icons/apple-icon-144x144.png": "a97f1942534ff62a316d2c5174926bc7",
"icons/ms-icon-70x70.png": "ec7c4e4d3c3a8422f0bab7169b011b48",
"icons/apple-icon.png": "4aff56ccc3d4d81d14a902f0ae39ac4a",
"icons/android-icon-144x144.png": "a97f1942534ff62a316d2c5174926bc7",
"icons/apple-icon-180x180.png": "141057a844e931b137468f1ebdff6291",
"icons/favicon-16x16.png": "2697f88f2e1d80f7bb47cc5957bc0db0",
"icons/apple-icon-57x57.png": "79f9415ea822546cf110703be7d610f2",
"icons/apple-icon-152x152.png": "d820b5d140d73094eb68cff4221a80be",
"icons/ms-icon-150x150.png": "ce852434b7dfdbad9a31551705aad49a",
"icons/android-icon-72x72.png": "a708b97907ec95650995d3d4e66544b9",
"icons/android-icon-96x96.png": "526d740da00e8ae51e42cdd450c6b1de",
"icons/ms-icon-144x144.png": "a97f1942534ff62a316d2c5174926bc7",
"icons/apple-icon-60x60.png": "6de4b466106aebcb1e2f33eea2c060a9",
"icons/favicon-32x32.png": "09c0d2172b500d809e798d0de61e3330",
"icons/manifest.json": "aa3f5711cbea1aa61df14adec56c2b89",
"icons/android-icon-192x192.png": "7fc92d2ef9a71a9aceaf01bea9a674e1",
"icons/apple-icon-114x114.png": "065ff462e9ef5cd60b3adc700289f5ef",
"icons/android-icon-36x36.png": "28cf6440d17da80817db85d209c2ab01",
"icons/favicon.ico": "a5c5b83e81e17f0b9c2db9ca2c01f6b7",
"icons/apple-icon-precomposed.png": "4aff56ccc3d4d81d14a902f0ae39ac4a",
"icons/android-icon-48x48.png": "9699e17021a83fe4fb35152d0022a783",
"icons/browserconfig.xml": "653d077300a12f09a69caeea7a8947f8",
"icons/apple-icon-72x72.png": "a708b97907ec95650995d3d4e66544b9",
"icons/ms-icon-310x310.png": "a02ce0c282205afa90582fa3224c18bc",
"icons/apple-icon-76x76.png": "5d43e150b87e42fd7dea48ac9ee1e544",
"icons/favicon-96x96.png": "526d740da00e8ae51e42cdd450c6b1de",
"manifest.json": "47c96efbdd10596a79e7b59bf4e306d5",
"version.json": "98c01ebb213d4838223c58ac182708b8",
"assets/packaging/linux/updater/pubspec.yaml": "24e79f42cb048eaf3d6a00ac2c38043b",
"assets/pubspec.yaml": "ca2f40d7310a478f434daaa5cac19587",
"assets/FontManifest.json": "3ddd9b2ab1c2ae162d46e3cc7b78ba88",
"assets/fonts/MaterialIcons-Regular.otf": "95db9098c58fd6db106f1116bae85a0b",
"assets/AssetManifest.json": "6d2304d226e100215a952ae03fc82109",
"assets/assets/icon/icon.png": "20c60c484043fd8491da6b5f8d766bc2",
"assets/assets/images/theme_switch/moon.png": "0d916355f05dc4d4721b081989528c6d",
"assets/assets/images/theme_switch/sun.png": "096527538f5e1fb81c185a742d40da92",
"assets/packages/font_awesome_flutter/lib/fonts/fa-regular-400.ttf": "5178af1d278432bec8fc830d50996d6f",
"assets/packages/font_awesome_flutter/lib/fonts/fa-solid-900.ttf": "aa1ec80f1b30a51d64c72f669c1326a7",
"assets/packages/font_awesome_flutter/lib/fonts/fa-brands-400.ttf": "b37ae0f14cbc958316fac4635383b6e8",
"assets/NOTICES": "b4f0cc811449dd07a0915bba21156598",
"main.dart.js": "20c9637c08fa9c3c198cb50d46a74dad",
"CNAME": "2e6d2b0f8e886f7762feeef694eb0c3c"
};

// The application shell files that are downloaded before a service worker can
// start.
const CORE = [
  "main.dart.js",
"index.html",
"assets/NOTICES",
"assets/AssetManifest.json",
"assets/FontManifest.json"];
// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});

// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});

// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache.
        return response || fetch(event.request).then((response) => {
          cache.put(event.request, response.clone());
          return response;
        });
      })
    })
  );
});

self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});

// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}

// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
