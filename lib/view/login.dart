import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness/service/app_colors.dart';
import 'package:fitness/service/round_textfield.dart';
import 'package:fitness/view/forgot_password.dart';
import 'package:fitness/service/reusable_widgets.dart';
import 'package:fitness/view/signup.dart';
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
    var media = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center, // Center vertically
                children: [
                  SizedBox(
                    width: media.width,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: media.width * 0.5,
                        ),
                        const Text(
                          "Hey there,",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.blackColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        SizedBox(height: media.width * 0.01),
                        const Text(
                          "Welcome Back",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.blackColor,
                            fontSize: 20,
                            fontFamily: "Poppins",
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: media.width * 0.05),
                  reusableTextField('Enter Email', Icons.email_outlined, false,
                      _emailTextController),
                  SizedBox(height: media.width * 0.05),
                  reusableTextField(
                    'Enter Password',
                    Icons.lock_outline,
                    true,
                    _passwordTextController,
                  ),
                  SizedBox(height: media.width * 0.03),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, 'forgotpassword');
                    },
                    child: const Text(
                      " Forgot Password?",
                      style: TextStyle(color: AppColors.grayColor),
                    ),
                  ),
                  registerOption(),
                  loginRegisterButton(context, true, () {
                    FirebaseAuth.instance
                        .signInWithEmailAndPassword(
                            email: _emailTextController.text,
                            password: _passwordTextController.text)
                        .then((value) =>
                            {Navigator.pushNamed(context, 'dashboard')});
                  }),
                  SizedBox(height: media.width * 0.01),
                  Row(
                    children: [
                      Expanded(
                          child: Container(
                        width: double.maxFinite,
                        height: 1,
                        color: AppColors.grayColor.withOpacity(0.5),
                      )),
                      Text("  Or  ",
                          style: TextStyle(
                              color: AppColors.grayColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w400)),
                      Expanded(
                          child: Container(
                        width: double.maxFinite,
                        height: 1,
                        color: AppColors.grayColor.withOpacity(0.5),
                      )),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {},
                        child: Container(
                          width: 50,
                          height: 50,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: AppColors.primaryColor1.withOpacity(0.5),
                              width: 1,
                            ),
                          ),
                          child: Image.asset(
                            "icons/google_icon.png",
                            width: 20,
                            height: 20,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 30,
                      ),
                      GestureDetector(
                        onTap: () {},
                        child: Container(
                          width: 50,
                          height: 50,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: AppColors.primaryColor1.withOpacity(0.5),
                              width: 1,
                            ),
                          ),
                          child: Image.asset(
                            "icons/facebook_icon.png",
                            width: 20,
                            height: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, 'register');
                      },
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                            style: TextStyle(
                                color: AppColors.blackColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w400),
                            children: [
                              const TextSpan(
                                text: "Don’t have an account yet? ",
                              ),
                              TextSpan(
                                  text: "Register",
                                  style: TextStyle(
                                      color: AppColors.secondaryColor1,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500)),
                            ]),
                      )),
                ],
              ),
            ),
          ),
        ),
      ),
    );
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
