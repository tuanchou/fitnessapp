import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness/forgot_password.dart';
import 'package:fitness/service/reusable_widgets.dart';
import 'package:flutter/material.dart';

class LogIn extends StatefulWidget {
  const LogIn({super.key});

  @override
  State<LogIn> createState() => _MyLoginState();
}

class _MyLoginState extends State<LogIn> {
  TextEditingController _emailTextController = TextEditingController();
  TextEditingController _passwordTextController = TextEditingController();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [
        Image.asset(
          'images/login.png',
          fit: BoxFit.fill,
          width: double.infinity,
          height: double.infinity,
        ),
        Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                  20, MediaQuery.of(context).size.height * 0.55, 20, 0),
              child: Form(
                  key: _formKey, // Sử dụng GlobalKey<FormState> ở đây
                  child: Column(
                    children: <Widget>[
                      reusableTextField('Enter Email', Icons.email_outlined,
                          false, _emailTextController),
                      const SizedBox(
                        height: 10,
                      ),
                      reusableTextField(
                        'Enter Password',
                        Icons.lock_outline,
                        true,
                        _passwordTextController,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      loginRegisterButton(context, true, () {
                        FirebaseAuth.instance
                            .signInWithEmailAndPassword(
                                email: _emailTextController.text,
                                password: _passwordTextController.text)
                            .then((value) =>
                                {Navigator.pushNamed(context, 'home')});
                      }),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, 'forgotpassword');
                        },
                        child: const Text(
                          " Forgot Password?",
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      registerOption(),
                    ],
                  )),
            ),
          ),
        ),
      ],
    ));
  }

  Row registerOption() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Don't have account?",
          style: TextStyle(color: Colors.white70),
        ),
        GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, 'register');
          },
          child: const Text(
            " Register",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        )
      ],
    );
  }
}
