// lib/firebase_options.dart
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return const FirebaseOptions(
        apiKey:
            'AIzaSyCX108aXZhD4kb1lL4cuEneuCdhU0vIV5M', // استبدلها من إعدادات Firebase
        appId: '1:392878462274:android:b145f73ccd537cc30424db',
        messagingSenderId: '392878462274',
        projectId: 'eid-wahda',
        storageBucket: 'eid-wahda.firebasestorage.app',
      );
    }
    throw UnsupportedError(
      'DefaultFirebaseOptions are not supported for this platform.',
    );
  }
}
