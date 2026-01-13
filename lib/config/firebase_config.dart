import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class FirebaseConfig {
  static FirebaseOptions get current {
    if (kIsWeb) return web;
    return android;
  }

  static FirebaseOptions get web => const FirebaseOptions(
        apiKey: String.fromEnvironment('FIREBASE_API_KEY_WEB'),
        appId: String.fromEnvironment('FIREBASE_APP_ID_WEB'),
        messagingSenderId:
            String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID'),
        projectId: String.fromEnvironment('FIREBASE_PROJECT_ID'),
        storageBucket: String.fromEnvironment('FIREBASE_STORAGE_BUCKET'),
        authDomain: String.fromEnvironment('FIREBASE_AUTH_DOMAIN'),
      );

  static FirebaseOptions get android => const FirebaseOptions(
        apiKey: String.fromEnvironment('FIREBASE_API_KEY_ANDROID'),
        appId: String.fromEnvironment('FIREBASE_APP_ID_ANDROID'),
        messagingSenderId:
            String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID'),
        projectId: String.fromEnvironment('FIREBASE_PROJECT_ID'),
        storageBucket: String.fromEnvironment('FIREBASE_STORAGE_BUCKET'),
      );

  static FirebaseOptions get ios => const FirebaseOptions(
        apiKey: String.fromEnvironment('FIREBASE_API_KEY_IOS'),
        appId: String.fromEnvironment('FIREBASE_APP_ID_IOS'),
        messagingSenderId:
            String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID'),
        projectId: String.fromEnvironment('FIREBASE_PROJECT_ID'),
        storageBucket: String.fromEnvironment('FIREBASE_STORAGE_BUCKET'),
        iosBundleId: String.fromEnvironment('FIREBASE_IOS_BUNDLE_ID'),
      );
}
