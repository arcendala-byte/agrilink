import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return web;
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDTSQjJjyGRL_4QxtyPbrqmaC6CvdqGBeY',
    appId: '1:414602884782:web:0b229b003c7a5296bdf3f',
    messagingSenderId: '414602884782',
    projectId: 'agrilinknew-4ba5f',
    authDomain: 'agrilinknew-4ba5f.firebaseapp.com',
    storageBucket: 'agrilinknew-4ba5f.firebasestorage.app',
    measurementId: 'G-L7JDZZN88F',
  );
}
