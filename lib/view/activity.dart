import 'package:fitness/service/app_colors.dart';
import 'package:fitness/service/customtab.dart';
import 'package:fitness/service/round_gradient_button.dart';
import 'package:fitness/service/videoplayerwidget.dart';
import 'package:fitness/view/addData.dart';
import 'package:fitness/view/social/social.dart';
import 'package:fitness/view/workour/workour_detail_view.dart';
import 'package:fitness/view/workout_schedule_view/workout_schedule_view.dart';
import 'package:flutter/material.dart';

class Activity extends StatefulWidget {
  const Activity({Key? key}) : super(key: key);

  @override
  _ActivityState createState() => _ActivityState();
}

class _ActivityState extends State<Activity> {
  int _selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.whiteColor,
        centerTitle: true,
        elevation: 0,
        title: const Text(
          "My Activity",
          style: TextStyle(
              color: AppColors.blackColor,
              fontSize: 16,
              fontWeight: FontWeight.w700),
        ),
      ),
      body: Column(
        children: [
          CustomTabBar(
            selectedIndex: _selectedIndex,
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
          ),
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: [
                Social(), // Nội dung trang Photo
                WorkoutScheduleView(), // Nội dung trang Statistic
              ],
            ),
          ),
        ],
      ),
    );
  }
}
