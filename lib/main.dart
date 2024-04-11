import 'package:firebase_core/firebase_core.dart';
import 'package:fitness/view/dashboard.dart';
import 'package:fitness/view/forgot_password.dart';
import 'package:fitness/view/home_screen.dart';
import 'package:fitness/view/login.dart';
import 'package:fitness/view/profile/profile.dart';
import 'package:fitness/view/signup.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(SafeArea(
      child: MaterialApp(
    initialRoute: 'dashboard',
    debugShowCheckedModeBanner: false,
    routes: {
      'login': (context) => const LogIn(),
      'register': (context) => const SignUp(),
      'home': (context) => const HomeScreen(),
      'profile': (context) => const Profile(),
      'forgotpassword': (context) => const ForgotPassword(),
      'dashboard': (context) => const DashboardScreen(),
    },
  )));
}
