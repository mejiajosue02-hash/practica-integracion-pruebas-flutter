import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return web;
      default:
        return web;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'aqui va la apikey',
    appId: 'aqui va appID',
    messagingSenderId: 'aqui va messagingSenderId',
    projectId: 'practica-flutter-utec',
    authDomain: 'practica-flutter-utec.firebaseapp.com',
    storageBucket: 'practica-flutter-utec.firebasestorage.app',
  );
}