import 'package:firebase_messaging/firebase_messaging.dart';

class MyFirebaseMessaging {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> setupFirebaseMessaging() async {
    _firebaseMessaging
        .getInitialMessage()
        .then((RemoteMessage? message) {
      if (message != null) {
        print("onLaunch: $message");
        // Uygulama kapalıyken bildirimi işleyebilirsiniz.
      }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("onMessage: $message");
      // Burada bildirimi işleyebilirsiniz.
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("onResume: $message");
      // Uygulama arka planda iken bildirimi işleyebilirsiniz.
    });
  }
}

