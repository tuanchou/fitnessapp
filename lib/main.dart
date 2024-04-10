import 'package:firebase_core/firebase_core.dart';
import 'package:fitness/forgot_password.dart';
import 'package:fitness/home_screen.dart';
import 'package:fitness/login.dart';
import 'package:fitness/profile.dart';
import 'package:fitness/signup.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(SafeArea(
      child: MaterialApp(
    initialRoute: 'login',
    debugShowCheckedModeBanner: false,
    routes: {
      'login': (context) => const LogIn(),
      'register': (context) => const SignUp(),
      'home': (context) => const HomeScreen(),
      'profile': (context) => const Profile(),
      'forgotpassword': (context) => const ForgotPassword(),
    },
  )));
}
