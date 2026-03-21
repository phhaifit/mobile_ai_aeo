import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Firebase configuration generated from FlutterFire CLI + Firebase SDK config.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      default:
        throw UnsupportedError('Unsupported platform');
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDd8Arsn34R_R4ZqvcvbXbH7n4mM-3va6Y',
    appId: '1:638546750037:android:969239d12be4c8504f42dc',
    messagingSenderId: '638546750037',
    projectId: 'ai-aeo-7d1b8',
    storageBucket: 'ai-aeo-7d1b8.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDf_3EAE__XKViUjXGDF8P9exRgR-pgjro',
    appId: '1:638546750037:ios:c17178eeb0e28b444f42dc',
    messagingSenderId: '638546750037',
    projectId: 'ai-aeo-7d1b8',
    storageBucket: 'ai-aeo-7d1b8.firebasestorage.app',
    iosBundleId: 'com.iotecksolutions.flutterBoilerplateProject',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDf_3EAE__XKViUjXGDF8P9exRgR-pgjro',
    appId: '1:638546750037:ios:c17178eeb0e28b444f42dc',
    messagingSenderId: '638546750037',
    projectId: 'ai-aeo-7d1b8',
    storageBucket: 'ai-aeo-7d1b8.firebasestorage.app',
    iosBundleId: 'com.iotecksolutions.flutterBoilerplateProject',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBiyHs-oIRLyNUtNQleDOmMjzk5fYnn_z0',
    appId: '1:638546750037:web:a43cbaebae1b3a4f4f42dc',
    messagingSenderId: '638546750037',
    projectId: 'ai-aeo-7d1b8',
    storageBucket: 'ai-aeo-7d1b8.firebasestorage.app',
    authDomain: 'ai-aeo-7d1b8.firebaseapp.com',
    measurementId: 'G-YW1BGJLX9S',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBiyHs-oIRLyNUtNQleDOmMjzk5fYnn_z0',
    appId: '1:638546750037:web:7ea24b411d4a83004f42dc',
    messagingSenderId: '638546750037',
    projectId: 'ai-aeo-7d1b8',
    storageBucket: 'ai-aeo-7d1b8.firebasestorage.app',
    authDomain: 'ai-aeo-7d1b8.firebaseapp.com',
  );
}
