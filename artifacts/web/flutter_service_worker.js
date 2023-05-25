'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';
const RESOURCES = {
  "version.json": "3038fa132e4f2a8a42a5a20cb22e3966",
"index.html": "d071e7028f35616464f9e5f8009a21c0",
"/": "d071e7028f35616464f9e5f8009a21c0",
"main.dart.js": "2da13c006412ffbcc806aecb7a2228b1",
"flutter.js": "f85e6fb278b0fd20c349186fb46ae36d",
"favicon.png": "ea500d5bdb8c9511a8d4a0ea8d17499d",
"icons/Icon-192.png": "ef264c27827f85dee71cde59957cb957",
"icons/Icon-maskable-192.png": "ef264c27827f85dee71cde59957cb957",
"icons/Icon-maskable-512.png": "bc43f5bb7c1fc41f8406673e5325993b",
"icons/Icon-512.png": "bc43f5bb7c1fc41f8406673e5325993b",
"manifest.json": "74fbeff5dd29272f4df47842db83edb6",
"static.html": "a294f67025524076cadcc5039f07cfc9",
"logout.html": "26e86453230416aa62e2ff9608aa6ee9",
"assets/AssetManifest.json": "acb882cc245681b530b587e6197dccc2",
"assets/NOTICES": "01bfb1a25bff67a56941214356871cc0",
"assets/FontManifest.json": "9ce369a7051d89af704045de8322433b",
"assets/packages/google_map_location_picker_flutter/assets/location.png": "dd3be0f9820238f90516f0992e25410a",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "6d342eb68f170c97609e9da345464e5e",
"assets/packages/flutter_google_places/assets/google_white.png": "40bc3ae5444eae0b9228d83bfd865158",
"assets/packages/flutter_google_places/assets/google_black.png": "97f2acfb6e993a0c4134d9d04dff21e2",
"assets/packages/wakelock_web/assets/no_sleep.js": "7748a45cd593f33280669b29c2c8919a",
"assets/shaders/ink_sparkle.frag": "9a0bdcb8b2cdea5a40af6ab31013ae08",
"assets/lib/common_widgets/state_city_picker/assets/country.json": "0881f297fd7d79a2750013d96215e20f",
"assets/fonts/MaterialIcons-Regular.otf": "95db9098c58fd6db106f1116bae85a0b",
"assets/assets/jsons/loading.json": "d9e60c9d52b059c8dcd3b6bb64dddb35",
"assets/assets/jsons/country.json": "11b8187fd184a2d648d6b5be8c5e9908",
"assets/assets/images/card_background_2.png": "a565e2d28e5e1529a30dd4686cde2b02",
"assets/assets/images/profileBackground.png": "dc381a347e024e0df36f71090ffeb511",
"assets/assets/images/card_background_3.png": "e58ababe818a56f4030f85ddfc32c90d",
"assets/assets/images/card_background_1.png": "07c22b70d957813366670614c8ad3e2b",
"assets/assets/images/ableton.png": "95ec9cbba584e21f5f5fa60077e5b7e4",
"assets/assets/images/card_background_4.png": "d1434e083d57d86a5db928850819417e",
"assets/assets/images/card_background_5.png": "7a93336a8b537175cf3542b32fcec210",
"assets/assets/images/card_background_6.png": "2c9de249bc49eb4978d586f7319b2efe",
"assets/assets/images/guitar_blue.png": "1301813cda55cc214652f3e982d0d97b",
"assets/assets/images/fenders.png": "794e254c4fe893372ef6d2df12fdee81",
"assets/assets/images/gibson.png": "263c493426c9343d834c3dd67adc6df4",
"assets/assets/images/aas.png": "43e51f0938820a2c558ce38e26bbc151",
"assets/assets/images/warranty_image.png": "d31ed25fb42eb6caa6aaed68e7f91a50",
"assets/assets/images/map_background.png": "c377d98661bdcee781879a70163d7167",
"assets/assets/images/warehouse.png": "11b9c62057d3745ded45379341b98a95",
"assets/assets/images/a_s-crafted-products.png": "4b1ce9bfb23d7f6ad3ce45e4bc135450",
"assets/assets/images/calories.svg": "609cc04d25d5e933020f61d4192b784d",
"assets/assets/images/guitar.png": "98215034c1fdd49473408c56bf5d9f12",
"assets/assets/images/a_f-drum-co.png": "1f44f9aaf5c7546df57de22dc0de3c39",
"assets/assets/images/offer_background.jpg": "350aa326b9c5ef681b5dbf764f2d45d9",
"assets/assets/images/marshall.png": "837078896dd3e0f47a767a7c65af6e07",
"assets/assets/images/delivery_info.png": "ffef45a7f9bdff2bde6384e1d4f2df73",
"assets/assets/icons/search.svg": "266e95b90018e5b210eccf5b21ee1550",
"assets/assets/icons/notes.svg": "faacf94c2e19bfc2402021def8be5d8b",
"assets/assets/icons/checkmark.svg": "155a22e47b43465296996644f7a0d4cf",
"assets/assets/icons/closed_lost.svg": "4757cf8c3a9e9b76db605e7f0c54bddc",
"assets/assets/icons/override_rejected.png": "070400911e1c49d1dad284d960acd65e",
"assets/assets/icons/reset.svg": "8011e7a77ef2beec138167492c4349aa",
"assets/assets/icons/voice_mail_icon.svg": "0364cbdab33f5f8a58390750b042ae17",
"assets/assets/icons/deleteIcon.svg": "735ee4525f154482059f83a575c0e339",
"assets/assets/icons/credit_card_background.png": "286423362dd1e3cf17bea320f4ba16cf",
"assets/assets/icons/new_order.png": "536a1f00bfa131e6de0e3172ec771329",
"assets/assets/icons/user.svg": "7327e76079dc918fc839f75933a803f3",
"assets/assets/icons/discover.png": "ea70c496dfa0169f6a3e59412472d6c1",
"assets/assets/icons/vintageIcon.svg": "292f01a528255f47ea46c4b58d6b3428",
"assets/assets/icons/override_reset.svg": "18495b9353a74b6bad8f19068ac9aa71",
"assets/assets/icons/sparkle.svg": "82b2379d2ca021c356c0d3bd6ca2764d",
"assets/assets/icons/app_icon.png": "f13bf6d523d5a0cab1925ef012839b9f",
"assets/assets/icons/direct_mail_icon.svg": "8258c15839178a927c40abcbdc5d5a0a",
"assets/assets/icons/goToArrow.svg": "7ff8e43e36962966fad304e9bc546625",
"assets/assets/icons/delivery.svg": "fdca615cd2f485bb4b59b267322519cb",
"assets/assets/icons/accessories_not_found.svg": "710099b96afdda372d5529c5dbafcadb",
"assets/assets/icons/divide.svg": "06eb0cbc9fd0e9f248af4640c77ff8f2",
"assets/assets/icons/used_label.svg": "d998bc0f825617997d90f7631a8ffa71",
"assets/assets/icons/shipping.svg": "a9a09e2f40dc402b20995a69e838b75d",
"assets/assets/icons/runIcon.svg": "2afad992b590b6270cc96613bb5c18af",
"assets/assets/icons/open_box_lable.svg": "3e81311b42ae50220d0b98b1aae6bf88",
"assets/assets/icons/pinIcon.svg": "ea3510007e6ca1aa2d53f8a76c991d97",
"assets/assets/icons/checkbox_round_empty.svg": "8ab8d91e9366653443ac604f0ff457bc",
"assets/assets/icons/left_arrow.svg": "0e34c5a009df69a721e8980a1e97c014",
"assets/assets/icons/searchIcon.svg": "278b9e261db3a2a3020f1bc6edc2a233",
"assets/assets/icons/sad.svg": "b3f3676dc9b65c588813ea8d4b88e7b9",
"assets/assets/icons/percentage.svg": "b13dcecf3cc29397be24e08c7568461a",
"assets/assets/icons/refresh_icon.png": "a7055ee0c91dd38a8c9bc543c570782b",
"assets/assets/icons/truckship_icon.svg": "bfd1b80e4c72b097309cf7bea42b0dc4",
"assets/assets/icons/green_tick.svg": "c1614f96d8f96752bdb18c4645a6fffb",
"assets/assets/icons/credit_card.png": "a7a2052390dd6d4860934378c42aa932",
"assets/assets/icons/pickup_icon.svg": "9f1d4d30444254c088292112d8c0483a",
"assets/assets/icons/override_accepted.png": "ca55b7f6299fee88ece7cd7381c4c102",
"assets/assets/icons/chip.png": "5728d5ac34dbb1feac78ebfded493d69",
"assets/assets/icons/cart.svg": "d7f1be8bc11c2a41db9db5268c7c3262",
"assets/assets/icons/tickicon.svg": "bfc5a220d08532b3a32c43e167e73a70",
"assets/assets/icons/mail.svg": "76b0d38a44cf73af1c97038c7b1213c3",
"assets/assets/icons/filesIcon.svg": "f281e1684bbf0817b3fad8dd0fded6ea",
"assets/assets/icons/logout.png": "605605807eda83feb93c5d8cb34bf4b7",
"assets/assets/icons/empty_card.svg": "2751a71f7c3b00bdb433a22798959bca",
"assets/assets/icons/visa.png": "9db6b8c16d9afbb27b29ec0596be128b",
"assets/assets/icons/neutral.svg": "8c59b889b0da0b367661f9c7059caf71",
"assets/assets/icons/checkout_more_options.svg": "63c457b96ca47cd1e69d1fcebf604b2e",
"assets/assets/icons/more_info.svg": "9c9a847ea9fdbb3be99714e3abb57b32",
"assets/assets/icons/inventory_lookup.svg": "2cec023a59d13665a702e81ff57d5f1b",
"assets/assets/icons/feed.svg": "bada8d0d61339074b81974591bff2eee",
"assets/assets/icons/filter1.svg": "4524d8995521a8c274807391f57e5897",
"assets/assets/icons/downwardTrendIcon.svg": "fb27e0b928053f4e9b59fc86b9f82deb",
"assets/assets/icons/google_map_dark.txt": "5b4f100b89841019da37e2d6c56f9cea",
"assets/assets/icons/happy.svg": "b00012f98d24a90c9d674d55418ac66f",
"assets/assets/icons/lessonIcon.svg": "239c453152baba6421218a4253b3bd79",
"assets/assets/icons/checkbox_round_empty_file.png": "ed4d8d592962a1565a0f4a82453d0776",
"assets/assets/icons/bottomsheet_my_customer.svg": "54afe9d608323c6a8e2294493f71bf96",
"assets/assets/icons/in_stock_tick.svg": "b149b17ad33ed7205abadda266c3d46d",
"assets/assets/icons/delete_trash.svg": "600431cf7ad89952f568729765a1f160",
"assets/assets/icons/create_task_close.svg": "02aa1737aaa21d2bf20e963d55a2156a",
"assets/assets/icons/leave.svg": "3cb2a722e316b901e045babf1204627e",
"assets/assets/icons/backIcon.svg": "9327d6072134a36b88c4c2b9a2858e99",
"assets/assets/icons/bottomsheet_building.svg": "8f3aa6fc77c8eeac6efe97fa203edbd7",
"assets/assets/icons/badge.svg": "fbdbc609b70d554ae94d42d25bba8c6b",
"assets/assets/icons/914_icon.svg": "60a09834696f93be607b929a2309d3f2",
"assets/assets/icons/back.svg": "7523e3407a9719c47b4bc13e89a7da14",
"assets/assets/icons/messagePic.png": "81bbdad5f3054ff510435a32f390b2b0",
"assets/assets/icons/notification.svg": "227680514c56c533c8d8ef57d18ff69b",
"assets/assets/icons/returnable_icon.svg": "e482f88cbc9fdea0a431ed77f1d5b9e9",
"assets/assets/icons/commission_divide.svg": "ba58427c6f2fd681520e7fa631ce785c",
"assets/assets/icons/send.svg": "9bbd3f9c946499f44b55161206eb6d8e",
"assets/assets/icons/commission_log.svg": "f2928457b8eb9719beee2fe578563512",
"assets/assets/icons/message_outline.svg": "a16e591e55ee1772ace834fc0e83c142",
"assets/assets/icons/google_map_light.txt": "237e1c8fd91f0f34548fda89645566b6",
"assets/assets/icons/love.svg": "f4e440713501f36f7bfebd6b8cc07975",
"assets/assets/icons/shoppingBag.svg": "1f50e8fc1b5e901754d67bb33b82bcab",
"assets/assets/icons/more.svg": "4aab438fc3ed5ac70e51e7489f9071a5",
"assets/assets/icons/openBoxIcon.svg": "e9adca0bfbc9867d3db07ed340495017",
"assets/assets/icons/market.svg": "6bb59a5e944b22106bfd5bfdf0b573b7",
"assets/assets/icons/product_info.svg": "378f423552034265d8a1c046c6c2ddd3",
"assets/assets/icons/checkbox_round_filled_file.png": "8c00f287a500015ddc5ebcc9606ff00a",
"assets/assets/icons/guitar.svg": "7c72da6f9146685507181a7bdddc7c24",
"assets/assets/icons/star.svg": "efde00493cb8d0e78f19f9806747977c",
"assets/assets/icons/sun.svg": "5c4f23983cdb4017715729cbda8e6f86",
"assets/assets/icons/profileCertificationIcon.svg": "c35c6aa20a2071c1a94cac0068dde219",
"assets/assets/icons/no_data_found.svg": "f8d6f08e2d5ab3f4dfb76da3e7039730",
"assets/assets/icons/usedIcon.svg": "80cd187c0355b2c7515e7dcd69554941",
"assets/assets/icons/calendarIcon.svg": "822f561e4990517fb67d34bf42cd3e43",
"assets/assets/icons/music_icons/viola.svg": "cf7c6fb0a720ab53e41b1ae5149b8c5a",
"assets/assets/icons/music_icons/violin.svg": "f6bebb6730a757706d7494bb37044238",
"assets/assets/icons/music_icons/brass.svg": "2d3a191b27af36e2aa509c7a93e5d0f3",
"assets/assets/icons/music_icons/marching_percussion.svg": "1202c15aa44ce346d3ea0ae48ffb0493",
"assets/assets/icons/music_icons/bass_guitar.svg": "f65e49e1c5cb05cb40cbbcc0c38563f0",
"assets/assets/icons/music_icons/flute.svg": "c31c706473edde986e274191111bcfd6",
"assets/assets/icons/music_icons/orchestra.svg": "0a37a8290d2da18973079126f137fa1e",
"assets/assets/icons/music_icons/drum_kit.svg": "5c050e4d716ad3b172743b500c053c9b",
"assets/assets/icons/music_icons/bassoon.svg": "51e8cdbd5afbe259cbdad56928dd31cb",
"assets/assets/icons/music_icons/clarinet.svg": "932f8059ceb57bc318c441d27c7657cf",
"assets/assets/icons/music_icons/trombone.svg": "3848f7e9e5cc90cbabc3772086c5a050",
"assets/assets/icons/music_icons/saxophone.svg": "e397dde2fd4083f54197673487916819",
"assets/assets/icons/music_icons/acoustic_guitar.svg": "def21d6542362a928842badfdeb6359b",
"assets/assets/icons/music_icons/trumpet.svg": "cb25fc5b20ae04614983a03d37cff02c",
"assets/assets/icons/music_icons/cello.svg": "2268e04ae9b7555910c0b0dd02357f3c",
"assets/assets/icons/music_icons/oboe.svg": "c493b56f3527be113640d4c0b831d3b5",
"assets/assets/icons/music_icons/wood_wing.svg": "78793ff1ec7e688a4b4903865947043f",
"assets/assets/icons/music_icons/bass_acoustic.svg": "69a2a510d91fb7b941dcc8fe029db576",
"assets/assets/icons/music_icons/double_bass.svg": "cb139f29f886300c6fb6d9f44855d756",
"assets/assets/icons/music_icons/tuba.svg": "2a2ce43d986dd2cbeb61c318a6ff01fe",
"assets/assets/icons/music_icons/electric_guitar.svg": "d8d4ea307761d275193c7299133230f0",
"assets/assets/icons/shippingDetail.svg": "a0378d05f4ceefc77f9f7677a03c3b4a",
"assets/assets/icons/bar_chart_icon.png": "25768621e3643415f525fe8d6336136e",
"assets/assets/icons/commisons.svg": "4aac54c34b091553659f726ea3f0609c",
"assets/assets/icons/bottomsheet_user.svg": "aff6ba3793d642f5cc0b765c06e909a0",
"assets/assets/icons/phone.svg": "26e60ce1a6704f87a2bf932db3c3278a",
"assets/assets/icons/notificationAlert.svg": "5eb7d7d8457316fbb1fcb7d324bba6cd",
"assets/assets/icons/email_icon.svg": "f85940dd157adca95fc7d150bf3f00a9",
"assets/assets/icons/synchrony.svg": "220e95499708cf876792fd1df85900c2",
"assets/assets/icons/backorderable_icon.svg": "8dd5a55ccf31f572c4eb725446d88cb8",
"assets/assets/icons/share.svg": "b5711548d6f5a77b11e6c8bb9bda7f8c",
"assets/assets/icons/order_lookup_icon.svg": "f615307c359403443d1044ac4c69a5c4",
"assets/assets/icons/amex.png": "dad771da6513cec63005d2ef1271189f",
"assets/assets/icons/sort.svg": "b9c6d6f180ea843d7c41eca789b77bbc",
"assets/assets/icons/emailSettingIcon.svg": "085cd6317b35195f2866637a3dfd1aaf",
"assets/assets/icons/addIcon.svg": "872d5a5ed7a5d244cb1b3bb09813bc3f",
"assets/assets/icons/calendar.svg": "5ac9fdb94d9563f53a7d934deb794209",
"assets/assets/icons/order_success.svg": "e139386fb09165eea86d6f29a84a7e2f",
"assets/assets/icons/mastercard.png": "7e386dc6c169e7164bd6f88bffb733c7",
"assets/assets/icons/expansion.svg": "c05a75c6d00b91ce15be158165b24f9c",
"assets/assets/icons/clearence_icon.svg": "008ed52409b4a6314735d9018a5ae1b3",
"assets/assets/icons/quote.svg": "a2b632529cf216c02da9a3ff55e6c514",
"assets/assets/icons/map_lable.svg": "f8da5eab63f329c299184bf603f4ab1d",
"assets/assets/icons/filterIcon.svg": "15d1410516f58b38f1b3d00d84ecd4b1",
"assets/assets/icons/upwardTrendIcon.svg": "df3a7d8f895dbc2ade452e1ffda0b829",
"assets/assets/icons/quote_log.svg": "42f313ee90beacfefc98c99829d8a9ec",
"assets/assets/icons/treeStructureThin.svg": "4df7ac2bc9462bee1757ecf4c10e574d",
"assets/assets/icons/text_(sms)_icon.svg": "dcc436fd632d49353ca4717069eb87ee",
"assets/assets/icons/checkbox_round_filled.svg": "5962b64b6df452a386a980bce0e4d4a5",
"assets/assets/icons/create_task_icon.svg": "ca2b4dc4cb952e018987e56611fff430",
"assets/assets/icons/platinum_icon.svg": "3f503548aa883c8e4f9386873b32d684",
"assets/assets/icons/info_circled.svg": "edbaeae32ffb919965a3878b43d6b6b9",
"assets/assets/icons/recieptIcon.svg": "87901d329cc64a14a46bb50c12b6899a",
"assets/assets/icons/addressIcon.svg": "c0650f06751eab54d263a5641741e555",
"assets/assets/icons/reminderIcon.svg": "fc6f171440a04a598eb65abf9061a7ff",
"assets/assets/icons/grid3.svg": "56b659c16be6383d6313ab2089f8ceac",
"assets/assets/icons/print.svg": "37ad74131033b8f0be482f3500a39eee",
"assets/assets/icons/moon.svg": "fec71a1e17d7e442021e784375459624",
"assets/assets/icons/pie_chart_icon.png": "d77657a034a7be196901bb3420d3acc5",
"assets/assets/icons/loyalty.svg": "c6189a2d3e49e3f11d6e1a5301a585fe",
"assets/assets/icons/heart.svg": "ce065e577a65c2eb8b3c3af349357feb",
"assets/assets/fonts/rubik_regular.ttf": "4b3f06816033d040ef0ed60865adb2d1",
"assets/assets/fonts/rubik_light.ttf": "98df4209c27b1be565511cc954fa307d",
"assets/assets/fonts/rubik_semiBold.ttf": "a840e539f4f9f5b8ceb038072848ae2f",
"assets/assets/fonts/rubik_medium.ttf": "bb476f36e32039a411d1f3afaf5a81af",
"canvaskit/canvaskit.js": "2bc454a691c631b07a9307ac4ca47797",
"canvaskit/profiling/canvaskit.js": "38164e5a72bdad0faa4ce740c9b8e564",
"canvaskit/profiling/canvaskit.wasm": "95a45378b69e77af5ed2bc72b2209b94",
"canvaskit/canvaskit.wasm": "bf50631470eb967688cca13ee181af62"
};

// The application shell files that are downloaded before a service worker can
// start.
const CORE = [
  "main.dart.js",
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
