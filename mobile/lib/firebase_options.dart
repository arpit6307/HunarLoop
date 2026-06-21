import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return web;
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCDGhD4x3o1NECCHZLfSqSAXpXfDASrSrA',
    appId: '1:6807760057:web:a25f98649b2f4814b2bf68',
    messagingSenderId: '6807760057',
    projectId: 'hunarloop',
    authDomain: 'hunarloop.firebaseapp.com',
    storageBucket: 'hunarloop.firebasestorage.app',
  );
}
