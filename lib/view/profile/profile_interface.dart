import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness/service/app_colors.dart';
import 'package:fitness/service/round_button.dart';
import 'package:fitness/service/round_gradient_button.dart';
import 'package:fitness/view/notification_screen.dart';
import 'package:fitness/view/profile/widget/setting_row.dart';
import 'package:fitness/view/profile/widget/title_subtitle_cell.dart';
import 'package:flutter/material.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({Key? key}) : super(key: key);

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  final CollectionReference _user =
      FirebaseFirestore.instance.collection('user-info');
  final _userNameController = TextEditingController();
  String _imageURL = "";
  bool positive = false;

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
          _userNameController.text = userData['Name'];
          _imageURL = userData['Avatar'] ?? '';
        });
      } catch (e) {
        print('Error fetching user data: $e');
      }
    }
  }

  List accountArr = [
    {"image": "icons/p_personal.png", "name": "Personal Data", "tag": "1"},
    {"image": "icons/p_achi.png", "name": "Achievement", "tag": "2"},
    {"image": "icons/p_activity.png", "name": "Activity History", "tag": "3"},
    {"image": "icons/p_workout.png", "name": "Workout Progress", "tag": "4"}
  ];

  List otherArr = [
    {"image": "icons/p_contact.png", "name": "Contact Us", "tag": "5"},
    {"image": "icons/p_privacy.png", "name": "Privacy Policy", "tag": "6"},
    {"image": "icons/p_setting.png", "name": "Setting", "tag": "7"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        backgroundColor: AppColors.whiteColor,
        centerTitle: true,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          "Profile",
          style: TextStyle(
              color: AppColors.blackColor,
              fontSize: 16,
              fontWeight: FontWeight.w700),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: _imageURL.isNotEmpty
                        ? Image.network(
                            _imageURL,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          )
                        : Image.asset(
                            "images/user.png",
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _userNameController.text,
                          style: TextStyle(
                            color: AppColors.blackColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          "Lose a Fat Program",
                          style: TextStyle(
                            color: AppColors.grayColor,
                            fontSize: 12,
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 70,
                    height: 25,
                    child: RoundButton(
                      title: "Edit",
                      type: RoundButtonType.primaryBG,
                      onPressed: () {
                        Navigator.pushNamed(context, 'profile');
                      },
                    ),
                  )
                ],
              ),
              const SizedBox(
                height: 15,
              ),
              const Row(
                children: [
                  Expanded(
                    child: TitleSubtitleCell(
                      title: "180cm",
                      subtitle: "Height",
                    ),
                  ),
                  SizedBox(
                    width: 15,
                  ),
                  Expanded(
                    child: TitleSubtitleCell(
                      title: "65kg",
                      subtitle: "Weight",
                    ),
                  ),
                  SizedBox(
                    width: 15,
                  ),
                  Expanded(
                    child: TitleSubtitleCell(
                      title: "22yo",
                      subtitle: "Age",
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 25,
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                decoration: BoxDecoration(
                    color: AppColors.whiteColor,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 2)
                    ]),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Account",
                      style: TextStyle(
                        color: AppColors.blackColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: accountArr.length,
                      itemBuilder: (context, index) {
                        var iObj = accountArr[index] as Map? ?? {};
                        return SettingRow(
                          icon: iObj["image"].toString(),
                          title: iObj["name"].toString(),
                          onPressed: () {},
                        );
                      },
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 25,
              ),
              GestureDetector(
                onTap: () {
                  // Add your onPressed logic here
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => NotificationScreen()),
                  );
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  decoration: BoxDecoration(
                      color: AppColors.whiteColor,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 2)
                      ]),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Notification",
                        style: TextStyle(
                          color: AppColors.blackColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      SizedBox(
                        height: 30,
                        child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Image.asset("icons/p_notification.png",
                                  height: 15, width: 15, fit: BoxFit.contain),
                              const SizedBox(
                                width: 15,
                              ),
                              Expanded(
                                child: Text(
                                  "Pop-up Notification",
                                  style: TextStyle(
                                    color: AppColors.blackColor,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              // CustomAnimatedToggleSwitch<bool>(
                              //   current: positive,
                              //   values: [false, true],
                              //   dif: 0.0,
                              //   indicatorSize: Size.square(30.0),
                              //   animationDuration:
                              //       const Duration(milliseconds: 200),
                              //   animationCurve: Curves.linear,
                              //   onChanged: (b) => setState(() => positive = b),
                              //   iconBuilder: (context, local, global) {
                              //     return const SizedBox();
                              //   },
                              //   defaultCursor: SystemMouseCursors.click,
                              //   onTap: () => setState(() => positive = !positive),
                              //   iconsTappable: false,
                              //   wrapperBuilder: (context, global, child) {
                              //     return Stack(
                              //       alignment: Alignment.center,
                              //       children: [
                              //         Positioned(
                              //             left: 10.0,
                              //             right: 10.0,
                              //             height: 30.0,
                              //             child: DecoratedBox(
                              //               decoration: BoxDecoration(
                              //                 gradient: LinearGradient(
                              //                     colors: AppColors.secondaryG),
                              //                 borderRadius:
                              //                     const BorderRadius.all(
                              //                         Radius.circular(30.0)),
                              //               ),
                              //             )),
                              //         child,
                              //       ],
                              //     );
                              //   },
                              //   foregroundIndicatorBuilder: (context, global) {
                              //     return SizedBox.fromSize(
                              //       size: const Size(10, 10),
                              //       child: DecoratedBox(
                              //         decoration: BoxDecoration(
                              //           color: AppColors.whiteColor,
                              //           borderRadius: const BorderRadius.all(
                              //               Radius.circular(50.0)),
                              //           boxShadow: const [
                              //             BoxShadow(
                              //                 color: Colors.black38,
                              //                 spreadRadius: 0.05,
                              //                 blurRadius: 1.1,
                              //                 offset: Offset(0.0, 0.8))
                              //           ],
                              //         ),
                              //       ),
                              //     );
                              //   },
                              // ),
                            ]),
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 25,
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                decoration: BoxDecoration(
                    color: AppColors.whiteColor,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 2)
                    ]),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Other",
                      style: TextStyle(
                        color: AppColors.blackColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: otherArr.length,
                      itemBuilder: (context, index) {
                        var iObj = otherArr[index] as Map? ?? {};
                        return SettingRow(
                          icon: iObj["image"].toString(),
                          title: iObj["name"].toString(),
                          onPressed: () {},
                        );
                      },
                    )
                  ],
                ),
              ),
              Center(
                child: RoundGradientButton(
                  title: "Logout",
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    Navigator.pushNamedAndRemoveUntil(
                        context, 'login', (route) => false);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
