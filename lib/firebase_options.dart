import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyARh4h8e5JBKdWY7OTPcM_X8ULqw7yXN5c',
    appId: '1:68301565182:web:092703ac844ed616b6c9af',
    messagingSenderId: '68301565182',
    projectId: 'shabih-tracking',
    authDomain: 'shabih-tracking.firebaseapp.com',
    storageBucket: 'shabih-tracking.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyARh4h8e5JBKdWY7OTPcM_X8ULqw7yXN5c',
    appId: '1:68301565182:android:092703ac844ed616b6c9af',
    messagingSenderId: '68301565182',
    projectId: 'shabih-tracking',
    storageBucket: 'shabih-tracking.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDMm3HXVhgaHh38LQ__k-GKEw_4k8G-1yE',
    appId: '1:68301565182:ios:6db7a66f4370d535b6c9af',
    messagingSenderId: '68301565182',
    projectId: 'shabih-tracking',
    storageBucket: 'shabih-tracking.firebasestorage.app',
    iosBundleId: 'com.partnerworktracker.app.partnerWorkTracker',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDMm3HXVhgaHh38LQ__k-GKEw_4k8G-1yE',
    appId: '1:68301565182:ios:6db7a66f4370d535b6c9af',
    messagingSenderId: '68301565182',
    projectId: 'shabih-tracking',
    storageBucket: 'shabih-tracking.firebasestorage.app',
    iosBundleId: 'com.partnerworktracker.app.partnerWorkTracker',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyARh4h8e5JBKdWY7OTPcM_X8ULqw7yXN5c',
    appId: '1:68301565182:web:092703ac844ed616b6c9af',
    messagingSenderId: '68301565182',
    projectId: 'shabih-tracking',
    authDomain: 'shabih-tracking.firebaseapp.com',
    storageBucket: 'shabih-tracking.firebasestorage.app',
  );
}
