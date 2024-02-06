import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:kartoyun/auth_pages/login_page.dart';
import 'package:kartoyun/auth_pages/register_page.dart';
import 'package:kartoyun/card_pages/play_card.dart';
import 'package:kartoyun/home_page.dart';
import 'package:kartoyun/profil_pages/profil.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("onMessage: $message");
      // İsterseniz burada bildirimi işleyebilirsiniz
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("onMessageOpenedApp: $message");
      // Bildirime tıklandığında yapılacak işlemleri burada yapabilirsiniz
      if (message.data['click_action'] == 'FLUTTER_NOTIFICATION_CLICK') {
        Navigator.of(context).pushNamed('/your_target_route');
      }
    });

    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        print("getInitialMessage: $message");
        // Bildirime tıklandığında yapılacak işlemleri burada yapabilirsiniz
        if (message.data['click_action'] == 'FLUTTER_NOTIFICATION_CLICK') {
          Navigator.of(context).pushNamed('/your_target_route');
        }
      }
    });

    return MaterialApp(
      title: 'My App',
      initialRoute: 'login_page',
      routes: {
        '/': (context) => LoginPage(), // Ana sayfaya yönlendirme
        'home_page': (context) => HomePage(),
        'kart_oyna': (context) => KartOynama(),
        'profil': (context) => Profil(),
        'register_page': (context) => RegisterPage(),
        'login_page': (context) => LoginPage(),
      },
    );
  }
}
