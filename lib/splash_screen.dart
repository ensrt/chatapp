import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kartoyun/auth_pages/login_page.dart';
import 'package:kartoyun/home_page.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  void checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (isLoggedIn) {
      // Eğer giriş yapılmışsa, belirli bir süre bekleyip sonra HomePage'e yönlendir
      Future.delayed(Duration(seconds: 1), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      });
    } else {
      // Eğer giriş yapılmamışsa, giriş yap ve sonra HomePage'e yönlendir
      await performLogin();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    }
  }

  Future<void> performLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String email = prefs.getString('email') ?? '';
    String password = prefs.getString('password') ?? '';
    await Future.delayed(Duration(seconds: 1));
    // Gerçek giriş işlemi tamamlandığında isLoggedIn değerini true olarak ayarla
    bool loginSuccess = true; // Bu değeri gerçek bir giriş kontrolüne göre ayarla
    if (loginSuccess) {
      prefs.setBool('isLoggedIn', true);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FlutterLogo(size: 200),
      ),
    );
  }
}
