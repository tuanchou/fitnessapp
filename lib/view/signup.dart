import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness/service/app_colors.dart';
import 'package:fitness/service/reusable_widgets.dart';
import 'package:flutter/material.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _MyRegisterState();
}

class _MyRegisterState extends State<SignUp> {
  TextEditingController _nameTextController = TextEditingController();
  TextEditingController _emailTextController = TextEditingController();
  TextEditingController _passwordTextController = TextEditingController();
  TextEditingController _confirmPasswordTextController =
      TextEditingController();
  String _passwordError = '';
  String _emailError = '';
  bool isStrongPassword(String password) {
    final RegExp passwordRegex = RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[\W_]).{8,}$',
    );
    return passwordRegex.hasMatch(password);
  }

  bool isEmailValid(String email) {
    final RegExp emailRegex = RegExp(
      r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$',
    );
    return emailRegex.hasMatch(email);
  }

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  height: 15,
                ),
                Text(
                  "Hey there,",
                  style: TextStyle(
                    color: AppColors.blackColor,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  "Create an Account",
                  style: TextStyle(
                    color: AppColors.blackColor,
                    fontSize: 20,
                    fontFamily: "Poppins",
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                reusableTextField(
                  "Enter Your Name",
                  Icons.person_outlined,
                  false,
                  _nameTextController,
                ),
                SizedBox(
                  height: 15,
                ),
                reusableTextField("Enter Email", Icons.email_outlined, false,
                    _emailTextController),
                Text(
                  _emailError,
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 14,
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                reusableTextField(
                  "Enter Password",
                  Icons.lock_outlined,
                  true,
                  _passwordTextController,
                ),
                Text(
                  _passwordError,
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 14,
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                reusableTextField("Enter Confirm Password", Icons.lock_outlined,
                    true, _confirmPasswordTextController),
                SizedBox(
                  height: 40,
                ),
                loginRegisterButton(context, false, () async {
                  if (isEmailValid(_emailTextController.text)) {
                    if (await isEmailRegistered(_emailTextController.text)) {
                      setState(() {
                        _emailError =
                            "Email address has been previously registered.";
                      });
                    } else {
                      if (_passwordTextController.text ==
                          _confirmPasswordTextController.text) {
                        if (isStrongPassword(_passwordTextController.text)) {
                          FirebaseAuth.instance
                              .createUserWithEmailAndPassword(
                                  email: _emailTextController.text,
                                  password: _passwordTextController.text)
                              .then((userCredential) {
                            String userID = userCredential.user?.uid ?? '';
                            FirebaseFirestore.instance
                                .collection('user-info')
                                .doc(userID)
                                .set({
                              'UserID': userID,
                              'Name': _nameTextController.text,
                              'Email': _emailTextController.text,
                              'Address': null,
                              'DoB': null,
                              'Gender': null,
                              'Height': null,
                              'Weight': null,
                              'Avatar':
                                  'https://thumbs.dreamstime.com/b/default-avatar-profile-icon-social-media-user-vector-default-avatar-profile-icon-social-media-user-vector-portrait-176194876.jpg',
                            }).then((_) {
                              Navigator.pushNamed(context, 'login');
                            }).catchError((_passwordError) {
                              print("Error saving user data: $_passwordError");
                            });
                          }).catchError((_passwordError) {
                            print("Error creating user: $_passwordError");
                          });
                        } else {
                          setState(() {
                            _passwordError =
                                "Password is not strong enough.\nPassword must include lowercase letters, uppercase letters, numbers and special characters.";
                          });
                        }
                      } else {
                        setState(() {
                          _passwordError = "Passwords do not match";
                        });
                      }
                    }
                  } else {
                    setState(() {
                      _emailError = "Email address is not valid.";
                    });
                  }
                }),
                SizedBox(
                  height: 10,
                ),
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
                SizedBox(
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
                SizedBox(
                  height: 20,
                ),
                TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, "login");
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
                              text: "Already have an account? ",
                            ),
                            TextSpan(
                                text: "Login",
                                style: TextStyle(
                                    color: AppColors.secondaryColor1,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800)),
                          ]),
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Kiểm tra địa chỉ email đã tồn tại trong Firebase Authentication
  Future<bool> isEmailRegistered(String email) async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password:
            'random_password', // Chỉ cần một mật khẩu tạm thời để kiểm tra địa chỉ email
      );
      // Nếu không có lỗi xảy ra, địa chỉ email chưa được đăng ký trước đó
      await userCredential.user?.delete(); // Xóa tài khoản tạm thời
      return false;
    } catch (e) {
      // Nếu có lỗi xảy ra, địa chỉ email đã được đăng ký trước đó
      return true;
    }
  }
}
