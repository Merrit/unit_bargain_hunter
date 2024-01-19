'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"flutter.js": "7d69e653079438abfbb24b82a655b0a4",
"manifest.json": "47c96efbdd10596a79e7b59bf4e306d5",
"index.html": "f4786a87fa5a420c90aed1468d1afccf",
"/": "f4786a87fa5a420c90aed1468d1afccf",
"CNAME": "2e6d2b0f8e886f7762feeef694eb0c3c",
"assets/pubspec.yaml": "c8af365b1e77a62623872ece94280852",
"assets/AssetManifest.bin": "9e4dff671c0c584c1c9a81ce5286f823",
"assets/fonts/MaterialIcons-Regular.otf": "cdd498d54ea2a0f2c398949f458b661a",
"assets/assets/icon/icon.png": "20c60c484043fd8491da6b5f8d766bc2",
"assets/AssetManifest.bin.json": "d0ddf7d2ba5abe8410c5c34adce699e2",
"assets/FontManifest.json": "3ddd9b2ab1c2ae162d46e3cc7b78ba88",
"assets/shaders/ink_sparkle.frag": "4096b5150bac93c41cbc9b45276bd90f",
"assets/NOTICES": "60c01a494809ccd9aa2a495a38d1568c",
"assets/AssetManifest.json": "86a7d738b1ae1ef0cb881cd821e70ea6",
"assets/packages/font_awesome_flutter/lib/fonts/fa-regular-400.ttf": "5178af1d278432bec8fc830d50996d6f",
"assets/packages/font_awesome_flutter/lib/fonts/fa-solid-900.ttf": "aa1ec80f1b30a51d64c72f669c1326a7",
"assets/packages/font_awesome_flutter/lib/fonts/fa-brands-400.ttf": "b37ae0f14cbc958316fac4635383b6e8",
"assets/packages/window_manager/images/ic_chrome_close.png": "75f4b8ab3608a05461a31fc18d6b47c2",
"assets/packages/window_manager/images/ic_chrome_maximize.png": "af7499d7657c8b69d23b85156b60298c",
"assets/packages/window_manager/images/ic_chrome_unmaximize.png": "4a90c1909cb74e8f0d35794e2f61d8bf",
"assets/packages/window_manager/images/ic_chrome_minimize.png": "4282cd84cb36edf2efb950ad9269ca62",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"main.dart.js": "77dcc684ec66de646efc30013d791579",
"version.json": "81e6ae9be76d9e6bf5ced9dae9b2eb73",
"canvaskit/canvaskit.wasm": "73584c1a3367e3eaf757647a8f5c5989",
"canvaskit/skwasm.js": "87063acf45c5e1ab9565dcf06b0c18b8",
"canvaskit/skwasm.wasm": "2fc47c0a0c3c7af8542b601634fe9674",
"canvaskit/skwasm.worker.js": "bfb704a6c714a75da9ef320991e88b03",
"canvaskit/canvaskit.js": "eb8797020acdbdf96a12fb0405582c1b",
"canvaskit/chromium/canvaskit.wasm": "143af6ff368f9cd21c863bfa4274c406",
"canvaskit/chromium/canvaskit.js": "0ae8bbcc58155679458a0f7a00f66873",
"icons/apple-icon-precomposed.png": "4aff56ccc3d4d81d14a902f0ae39ac4a",
"icons/manifest.json": "aa3f5711cbea1aa61df14adec56c2b89",
"icons/apple-icon-114x114.png": "065ff462e9ef5cd60b3adc700289f5ef",
"icons/apple-icon-76x76.png": "5d43e150b87e42fd7dea48ac9ee1e544",
"icons/apple-icon-120x120.png": "1259790f1c3b0ef780ecba06dfd5b44d",
"icons/android-icon-192x192.png": "7fc92d2ef9a71a9aceaf01bea9a674e1",
"icons/ms-icon-70x70.png": "ec7c4e4d3c3a8422f0bab7169b011b48",
"icons/android-icon-36x36.png": "28cf6440d17da80817db85d209c2ab01",
"icons/browserconfig.xml": "653d077300a12f09a69caeea7a8947f8",
"icons/android-icon-48x48.png": "9699e17021a83fe4fb35152d0022a783",
"icons/apple-icon-72x72.png": "a708b97907ec95650995d3d4e66544b9",
"icons/ms-icon-150x150.png": "ce852434b7dfdbad9a31551705aad49a",
"icons/favicon-32x32.png": "09c0d2172b500d809e798d0de61e3330",
"icons/apple-icon-152x152.png": "d820b5d140d73094eb68cff4221a80be",
"icons/apple-icon-180x180.png": "141057a844e931b137468f1ebdff6291",
"icons/apple-icon-144x144.png": "a97f1942534ff62a316d2c5174926bc7",
"icons/android-icon-144x144.png": "a97f1942534ff62a316d2c5174926bc7",
"icons/favicon-16x16.png": "2697f88f2e1d80f7bb47cc5957bc0db0",
"icons/apple-icon.png": "4aff56ccc3d4d81d14a902f0ae39ac4a",
"icons/favicon.ico": "a5c5b83e81e17f0b9c2db9ca2c01f6b7",
"icons/ms-icon-144x144.png": "a97f1942534ff62a316d2c5174926bc7",
"icons/ms-icon-310x310.png": "a02ce0c282205afa90582fa3224c18bc",
"icons/apple-icon-60x60.png": "6de4b466106aebcb1e2f33eea2c060a9",
"icons/apple-icon-57x57.png": "79f9415ea822546cf110703be7d610f2",
"icons/android-icon-72x72.png": "a708b97907ec95650995d3d4e66544b9",
"icons/favicon-96x96.png": "526d740da00e8ae51e42cdd450c6b1de",
"icons/android-icon-96x96.png": "526d740da00e8ae51e42cdd450c6b1de"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
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
        // Claim client to enable caching on first launch
        self.clients.claim();
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
      // Claim client to enable caching on first launch
      self.clients.claim();
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
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
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
