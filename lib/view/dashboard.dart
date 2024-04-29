import 'dart:io';
import 'package:fitness/service/app_colors.dart';
import 'package:fitness/view/activity.dart';
import 'package:fitness/view/home_screen.dart';
import 'package:fitness/view/profile/profile.dart';
import 'package:fitness/view/profile/profile_interface.dart';
import 'package:fitness/view/social/home_page.dart';
import 'package:fitness/view/social/social.dart';
import 'package:fitness/view/social/upload_post_page.dart';
import 'package:fitness/view/social/widget/upload_post_main_widget.dart';
import 'package:fitness/view/workourStatistic/Statistic.dart';
import 'package:fitness/view/workout_schedule_view/workout_schedule_view.dart';
import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget {
  static String routeName = "/DashboardScreen";

  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int selectTab = 0;

  final List<Widget> _widgetOptions = <Widget>[
    const HomeScreen(),
    const Activity(),
    const HomePage(),
    const UserProfile()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      // floatingActionButton: InkWell(
      //   onTap: () {},
      //   child: SizedBox(
      //     width: 70,
      //     height: 70,
      //     child: Container(
      //       width: 65,
      //       height: 65,
      //       decoration: BoxDecoration(
      //           gradient: LinearGradient(colors: AppColors.primaryG),
      //           borderRadius: BorderRadius.circular(35),
      //           boxShadow: const [
      //             BoxShadow(color: Colors.black12, blurRadius: 2)
      //           ]),
      //       child: const Icon(Icons.search_sharp,
      //           color: AppColors.whiteColor, size: 32),
      //     ),
      //   ),
      // ),
      body: IndexedStack(
        index: selectTab,
        children: _widgetOptions,
      ),
      bottomNavigationBar: BottomAppBar(
        height: 80,
        color: Colors.transparent,
        padding: const EdgeInsets.all(0),
        child: Container(
          height: 80,
          decoration: const BoxDecoration(
              color: AppColors.whiteColor,
              boxShadow: [
                BoxShadow(
                    color: Colors.black12, blurRadius: 2, offset: Offset(0, -2))
              ]),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              TabButton(
                  icon: "icons/home_icon.png",
                  selectIcon: "icons/home_select_icon.png",
                  isActive: selectTab == 0,
                  onTap: () {
                    if (mounted) {
                      setState(() {
                        selectTab = 0;
                      });
                    }
                  }),
              TabButton(
                  icon: "icons/activity_icon.png",
                  selectIcon: "icons/activity_select_icon.png",
                  isActive: selectTab == 1,
                  onTap: () {
                    if (mounted) {
                      setState(() {
                        selectTab = 1;
                      });
                    }
                  }),
              TabButton(
                  icon: "icons/camera_icon.png",
                  selectIcon: "icons/camera_select_icon.png",
                  isActive: selectTab == 2,
                  onTap: () {
                    if (mounted) {
                      setState(() {
                        selectTab = 2;
                      });
                    }
                  }),
              TabButton(
                  icon: "icons/user_icon.png",
                  selectIcon: "icons/user_select_icon.png",
                  isActive: selectTab == 3,
                  onTap: () {
                    if (mounted) {
                      setState(() {
                        selectTab = 3;
                      });
                    }
                  }),
            ],
          ),
        ),
      ),
    );
  }
}

class TabButton extends StatelessWidget {
  final String icon;
  final String selectIcon;
  final bool isActive;
  final VoidCallback onTap;

  const TabButton(
      {Key? key,
      required this.icon,
      required this.selectIcon,
      required this.isActive,
      required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            isActive ? selectIcon : icon,
            width: 25,
            height: 25,
            fit: BoxFit.fitWidth,
          ),
          SizedBox(height: isActive ? 8 : 12),
          Visibility(
            visible: isActive,
            child: Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                  gradient: LinearGradient(colors: AppColors.secondaryG),
                  borderRadius: BorderRadius.circular(2)),
            ),
          )
        ],
      ),
    );
  }
}
