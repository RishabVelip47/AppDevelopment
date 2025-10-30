// lib/firebase_options.dart
// Combined and ready for web + Android + iOS + desktop.
// Generated + corrected manually to match your Firebase Console values.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Use like this:
/// ```dart
/// import 'firebase_options.dart';
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  /// 🌐 Web Firebase configuration
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyB4D5G1HfJ7jX85tCEA5HU3oq1alX-1P3o',
    appId: '1:813569614547:web:7b9089c8e7067b75efaa26',
    messagingSenderId: '813569614547',
    projectId: 'calculator-1e662',
    authDomain: 'calculator-1e662.firebaseapp.com',
    storageBucket: 'calculator-1e662.firebasestorage.app',
    measurementId: 'G-MJ3D2LL6W5',
  );

  /// 🤖 Android Firebase configuration
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAnIbhgGg1dbqnOeYNtqU0pLy_oujK7uEg',
    appId: '1:813569614547:android:a15b25030f5ba69eefaa26',
    messagingSenderId: '813569614547',
    projectId: 'calculator-1e662',
    storageBucket: 'calculator-1e662.firebasestorage.app',
  );

  /// 🍎 iOS Firebase configuration
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDkVjfn69aqjryzZLrbBb2ycmcR9tOYnfI',
    appId: '1:813569614547:ios:750a8a80ec726411efaa26',
    messagingSenderId: '813569614547',
    projectId: 'calculator-1e662',
    storageBucket: 'calculator-1e662.firebasestorage.app',
    iosBundleId: 'com.example.calculatorFirebase',
  );

  /// 🍏 macOS Firebase configuration
  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDkVjfn69aqjryzZLrbBb2ycmcR9tOYnfI',
    appId: '1:813569614547:ios:750a8a80ec726411efaa26',
    messagingSenderId: '813569614547',
    projectId: 'calculator-1e662',
    storageBucket: 'calculator-1e662.firebasestorage.app',
    iosBundleId: 'com.example.calculatorFirebase',
  );

  /// 💻 Windows Firebase configuration
  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyB4D5G1HfJ7jX85tCEA5HU3oq1alX-1P3o',
    appId: '1:813569614547:web:a41cc391d8f52727efaa26',
    messagingSenderId: '813569614547',
    projectId: 'calculator-1e662',
    authDomain: 'calculator-1e662.firebaseapp.com',
    storageBucket: 'calculator-1e662.firebasestorage.app',
    measurementId: 'G-MFZC1ZZG8B',
  );
}
