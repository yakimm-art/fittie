import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    return web;
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBUhi-B9Tjpey-BBd6MADcKv3sRU9MZtBQ',
    authDomain: 'f44oou9czhl8p9li59he09z2h5afp1.firebaseapp.com',
    projectId: 'f44oou9czhl8p9li59he09z2h5afp1',
    storageBucket: 'f44oou9czhl8p9li59he09z2h5afp1.firebasestorage.app',
    messagingSenderId: '437170438175',
    appId: '1:437170438175:web:d138efdaa2f9c5c0da152a',
  );
}
