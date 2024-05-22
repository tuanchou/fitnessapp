import 'package:firebase_core/firebase_core.dart';
import 'package:fitness/view/dashboard.dart';
import 'package:fitness/view/forgot_password.dart';
import 'package:fitness/view/home_screen.dart';
import 'package:fitness/view/login.dart';
import 'package:fitness/view/profile/profile.dart';
import 'package:fitness/view/profile/profile_interface.dart';
import 'package:fitness/view/signup.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(SafeArea(
      child: MaterialApp(
    initialRoute: '/',
    debugShowCheckedModeBanner: false,
    routes: {
      '/': (context) => SplashScreen(),
      'login': (context) => const LogIn(),
      'register': (context) => const SignUp(),
      'home': (context) => const HomeScreen(),
      'profile': (context) => const Profile(),
      'profile1': (context) => const UserProfile(),
      'forgotpassword': (context) => const ForgotPassword(),
      'dashboard': (context) => const DashboardScreen(),
    },
  )));
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (isLoggedIn) {
      Navigator.of(context).pushReplacementNamed('dashboard');
    } else {
      Navigator.of(context).pushReplacementNamed('login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
