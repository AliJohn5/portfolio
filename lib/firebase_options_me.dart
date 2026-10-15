// File: lib/firebase_option.dart (or update your existing firebase_options.dart)
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    throw UnsupportedError(
      'DefaultFirebaseOptions have not been configured for this platform.',
    );
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: String.fromEnvironment('FIREBASE_API_KEY',
        defaultValue: 'LOCAL_API_KEY'),
    appId:
        String.fromEnvironment('FIREBASE_APP_ID', defaultValue: 'LOCAL_APP_ID'),
    messagingSenderId: String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID',
        defaultValue: 'LOCAL_SENDER_ID'),
    projectId: String.fromEnvironment('FIREBASE_PROJECT_ID',
        defaultValue: 'LOCAL_PROJECT_ID'),
    authDomain: String.fromEnvironment('FIREBASE_AUTH_DOMAIN',
        defaultValue: 'LOCAL_AUTH_DOMAIN'),
    storageBucket: String.fromEnvironment('FIREBASE_STORAGE_BUCKET',
        defaultValue: 'LOCAL_STORAGE_BUCKET'),
    measurementId: String.fromEnvironment('FIREBASE_MEASUREMENT_ID',
        defaultValue: 'LOCAL_MEASUREMENT_ID'),
  );
}
