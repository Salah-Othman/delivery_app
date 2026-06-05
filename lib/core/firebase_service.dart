import 'package:firebase_core/firebase_core.dart';

class FirebaseService {
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      _initialized = true;
    } catch (_) {
      // Already initialized or running in test environment
      _initialized = true;
    }
  }
}

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return const FirebaseOptions(
      apiKey: 'AIzaSyCX108aXZhD4kb1lL4cuEneuCdhU0vIV5M',
      appId: '1:392878462274:android:b145f73ccd537cc30424db',
      messagingSenderId: '392878462274',
      projectId: 'eid-wahda',
      storageBucket: 'eid-wahda.firebasestorage.app',
    );
  }
}
