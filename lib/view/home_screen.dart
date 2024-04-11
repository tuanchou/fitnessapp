import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness/view/dashboard.dart';
import 'package:fitness/view/login.dart';
import 'package:fitness/view/profile/profile.dart';
import 'package:fitness/service/app_colors.dart';
import 'package:fitness/service/round_button.dart';
import 'package:fitness/view/signup.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  static String routeName = "/HomeScreen";

  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CollectionReference _user =
      FirebaseFirestore.instance.collection('user-info');
  final _userNameController = TextEditingController(); // Change here

  @override
  void initState() {
    super.initState();
    _getUser();
  }

  Future<void> _getUser() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        final DocumentSnapshot userSnapshot = await _user.doc(user.uid).get();
        final userData = userSnapshot.data() as Map<String, dynamic>;

        setState(() {
          _userNameController.text = userData[
              'Name']; // Lưu giá trị của userData['Name'] vào biến _userName
        });
      } catch (e) {
        print('Error fetching user data: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Form(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Welcome back",
                            style: TextStyle(
                              color: AppColors.midGrayColor,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            _userNameController.text,
                            style: const TextStyle(
                              color: AppColors.blackColor,
                              fontSize: 20,
                              fontFamily: "Poppins",
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: media.width * 0.05),
                Container(
                  height: media.width * 0.4,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: AppColors.primaryG),
                    borderRadius: BorderRadius.circular(media.width * 0.065),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.asset(
                        "icons/bg_dots.png",
                        height: media.width * 0.4,
                        width: double.maxFinite,
                        fit: BoxFit.fitHeight,
                      ),
                      Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 25, horizontal: 25),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "BMI (Body Mass Index)",
                                  style: TextStyle(
                                    color: AppColors.whiteColor,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  "You have a normal weight",
                                  style: TextStyle(
                                    color:
                                        AppColors.whiteColor.withOpacity(0.7),
                                    fontSize: 12,
                                    fontFamily: "Poppins",
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                SizedBox(height: media.width * 0.05),
                              ],
                            ),
                            // AspectRatio(
                            //   aspectRatio: 1,
                            //   child: PieChart(
                            //     PieChartData(
                            //       pieTouchData: PieTouchData(
                            //         touchCallback: (FlTouchEvent event,
                            //             pieTouchResponse) {},
                            //       ),
                            //       startDegreeOffset: 250,
                            //       borderData: FlBorderData(
                            //         show: false,
                            //       ),
                            //       sectionsSpace: 1,
                            //       centerSpaceRadius: 0,
                            //       // sections: showingSections(),
                            //     ),
                            //   ),
                            // ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(height: media.width * 0.05),
                Container(
                  height: media.width * 0.4,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: AppColors.secondaryG),
                    borderRadius: BorderRadius.circular(media.width * 0.065),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.asset(
                        "icons/bg_dots.png",
                        height: media.width * 0.4,
                        width: double.maxFinite,
                        fit: BoxFit.fitHeight,
                      ),
                      Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 25, horizontal: 25),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "BMI (Body Mass Index)",
                                  style: TextStyle(
                                    color: AppColors.whiteColor,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  "You have a normal weight",
                                  style: TextStyle(
                                    color:
                                        AppColors.whiteColor.withOpacity(0.7),
                                    fontSize: 12,
                                    fontFamily: "Poppins",
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                SizedBox(height: media.width * 0.05),
                              ],
                            ),
                            // AspectRatio(
                            //   aspectRatio: 1,
                            //   child: PieChart(
                            //     PieChartData(
                            //       pieTouchData: PieTouchData(
                            //         touchCallback: (FlTouchEvent event,
                            //             pieTouchResponse) {},
                            //       ),
                            //       startDegreeOffset: 250,
                            //       borderData: FlBorderData(
                            //         show: false,
                            //       ),
                            //       sectionsSpace: 1,
                            //       centerSpaceRadius: 0,
                            //       // sections: showingSections(),
                            //     ),
                            //   ),
                            // ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(height: media.width * 0.05),
                Container(
                  height: media.width * 0.4,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: AppColors.secondaryF),
                    borderRadius: BorderRadius.circular(media.width * 0.065),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.asset(
                        "icons/bg_dots.png",
                        height: media.width * 0.4,
                        width: double.maxFinite,
                        fit: BoxFit.fitHeight,
                      ),
                      Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 25, horizontal: 25),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "BMI (Body Mass Index)",
                                  style: TextStyle(
                                    color: AppColors.whiteColor,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  "You have a normal weight",
                                  style: TextStyle(
                                    color:
                                        AppColors.whiteColor.withOpacity(0.7),
                                    fontSize: 12,
                                    fontFamily: "Poppins",
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                SizedBox(height: media.width * 0.05),
                              ],
                            ),
                            // AspectRatio(
                            //   aspectRatio: 1,
                            //   child: PieChart(
                            //     PieChartData(
                            //       pieTouchData: PieTouchData(
                            //         touchCallback: (FlTouchEvent event,
                            //             pieTouchResponse) {},
                            //       ),
                            //       startDegreeOffset: 250,
                            //       borderData: FlBorderData(
                            //         show: false,
                            //       ),
                            //       sectionsSpace: 1,
                            //       centerSpaceRadius: 0,
                            //       // sections: showingSections(),
                            //     ),
                            //   ),
                            // ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(height: media.width * 0.05),
                Container(
                  height: media.width * 0.4,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: AppColors.secondaryH),
                    borderRadius: BorderRadius.circular(media.width * 0.065),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.asset(
                        "icons/bg_dots.png",
                        height: media.width * 0.4,
                        width: double.maxFinite,
                        fit: BoxFit.fitHeight,
                      ),
                      Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 25, horizontal: 25),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "BMI (Body Mass Index)",
                                  style: TextStyle(
                                    color: AppColors.whiteColor,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  "You have a normal weight",
                                  style: TextStyle(
                                    color:
                                        AppColors.whiteColor.withOpacity(0.7),
                                    fontSize: 12,
                                    fontFamily: "Poppins",
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                SizedBox(height: media.width * 0.05),
                              ],
                            ),
                            // AspectRatio(
                            //   aspectRatio: 1,
                            //   child: PieChart(
                            //     PieChartData(
                            //       pieTouchData: PieTouchData(
                            //         touchCallback: (FlTouchEvent event,
                            //             pieTouchResponse) {},
                            //       ),
                            //       startDegreeOffset: 250,
                            //       borderData: FlBorderData(
                            //         show: false,
                            //       ),
                            //       sectionsSpace: 1,
                            //       centerSpaceRadius: 0,
                            //       // sections: showingSections(),
                            //     ),
                            //   ),
                            // ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(height: media.width * 0.05),
                Container(
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor1.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Today Target",
                        style: TextStyle(
                          color: AppColors.blackColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(
                        width: 75,
                        height: 30,
                        child: RoundButton(
                          title: "check",
                          type: RoundButtonType.primaryBG,
                          onPressed: () {
                            Navigator.pushNamed(context, 'profile');
                          },
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      // bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }
}
