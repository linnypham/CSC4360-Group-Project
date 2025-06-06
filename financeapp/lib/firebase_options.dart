// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
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
    apiKey: 'AIzaSyC3yCO962HfNIczz_VTvuk4hNRvBrV8pVg',
    appId: '1:716611096395:web:fc6e3b4433e63a708362ce',
    messagingSenderId: '716611096395',
    projectId: 'personal-finance-manager-c4b71',
    authDomain: 'personal-finance-manager-c4b71.firebaseapp.com',
    storageBucket: 'personal-finance-manager-c4b71.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBh4vRqnrgvoLmyR1xhK42OzrGM-ll_T2A',
    appId: '1:716611096395:android:d04db3ad3f4834658362ce',
    messagingSenderId: '716611096395',
    projectId: 'personal-finance-manager-c4b71',
    storageBucket: 'personal-finance-manager-c4b71.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCg-xtG5MTyDS4lmheplpsF841kw0txBig',
    appId: '1:716611096395:ios:4884fed3267e044e8362ce',
    messagingSenderId: '716611096395',
    projectId: 'personal-finance-manager-c4b71',
    storageBucket: 'personal-finance-manager-c4b71.firebasestorage.app',
    iosBundleId: 'com.example.financeapp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCg-xtG5MTyDS4lmheplpsF841kw0txBig',
    appId: '1:716611096395:ios:4884fed3267e044e8362ce',
    messagingSenderId: '716611096395',
    projectId: 'personal-finance-manager-c4b71',
    storageBucket: 'personal-finance-manager-c4b71.firebasestorage.app',
    iosBundleId: 'com.example.financeapp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyC3yCO962HfNIczz_VTvuk4hNRvBrV8pVg',
    appId: '1:716611096395:web:ba188e12b66a955e8362ce',
    messagingSenderId: '716611096395',
    projectId: 'personal-finance-manager-c4b71',
    authDomain: 'personal-finance-manager-c4b71.firebaseapp.com',
    storageBucket: 'personal-finance-manager-c4b71.firebasestorage.app',
  );
}
