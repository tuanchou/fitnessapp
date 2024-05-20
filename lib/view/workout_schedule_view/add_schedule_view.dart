import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness/service/app_colors.dart';
import 'package:fitness/service/common.dart';
import 'package:fitness/service/round_gradient_button.dart';
import 'package:fitness/view/workour/widget/icon_title_next_row.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AddScheduleView extends StatefulWidget {
  final DateTime date;
  final VoidCallback? onScheduleAdded;
  const AddScheduleView({super.key, required this.date, this.onScheduleAdded});

  @override
  State<AddScheduleView> createState() => _AddScheduleViewState();
}

class _AddScheduleViewState extends State<AddScheduleView> {
  String selectedWorkout = "Choose Workout";
  final CollectionReference workout_schedule =
      FirebaseFirestore.instance.collection('workout_schedule');
  User? user = FirebaseAuth.instance.currentUser;
  DateTime selectedTime = DateTime.now();
  void _saveSchedule() async {
    try {
      await workout_schedule.add({
        'user_id': user?.uid,
        'workout': selectedWorkout,
        'date': widget.date,
        'time': selectedTime,
        "markdone": false
      });

      print('Schedule added successfully!');
      if (widget.onScheduleAdded != null) {
        widget.onScheduleAdded!();
      }

      Navigator.pop(context, true);
    } catch (e) {
      print('Error adding schedule: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.whiteColor,
        centerTitle: true,
        elevation: 0,
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Container(
            margin: const EdgeInsets.all(8),
            height: 40,
            width: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: AppColors.lightGrayColor,
                borderRadius: BorderRadius.circular(10)),
            child: Image.asset(
              "icons/closed_btn.png",
              width: 15,
              height: 15,
              fit: BoxFit.contain,
            ),
          ),
        ),
        title: Text(
          "Add Schedule",
          style: TextStyle(
              color: AppColors.blackColor,
              fontSize: 16,
              fontWeight: FontWeight.w700),
        ),
        actions: [
          InkWell(
            onTap: () {},
            child: Container(
              margin: const EdgeInsets.all(8),
              height: 40,
              width: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: AppColors.lightGrayColor,
                  borderRadius: BorderRadius.circular(10)),
              child: Image.asset(
                "icons/more_icon.png",
                width: 15,
                height: 15,
                fit: BoxFit.contain,
              ),
            ),
          )
        ],
      ),
      backgroundColor: AppColors.whiteColor,
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(
            children: [
              Image.asset(
                "icons/date.png",
                width: 20,
                height: 20,
              ),
              const SizedBox(
                width: 8,
              ),
              Text(
                dateToString(widget.date, formatStr: "E, dd MMMM yyyy"),
                style: TextStyle(color: AppColors.grayColor, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          Text(
            "Time",
            style: TextStyle(
                color: AppColors.blackColor,
                fontSize: 14,
                fontWeight: FontWeight.w500),
          ),
          SizedBox(
            height: media.width * 0.35,
            child: CupertinoDatePicker(
              onDateTimeChanged: (newTime) {
                setState(() {
                  selectedTime = newTime;
                });
              },
              initialDateTime: DateTime.now(),
              use24hFormat: false,
              minuteInterval: 1,
              mode: CupertinoDatePickerMode.time,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Text(
            "Details Workout",
            style: TextStyle(
                color: AppColors.blackColor,
                fontSize: 14,
                fontWeight: FontWeight.w500),
          ),
          const SizedBox(
            height: 8,
          ),

          Container(
            decoration: BoxDecoration(
                color: AppColors.lightGrayColor,
                borderRadius: BorderRadius.circular(15)),
            child: Row(
              children: [
                Container(
                  alignment: Alignment.center,
                  width: 50,
                  height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Image.asset(
                    "icons/choose_workout.png",
                    width: 20,
                    height: 20,
                    fit: BoxFit.contain,
                    color: AppColors.grayColor,
                  ),
                ),
                Expanded(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton(
                      value: selectedWorkout,
                      items: [
                        'Choose Workout', // Giá trị mặc định không được trùng lặp
                        'Chest',
                        'Shoulder',
                        'Back',
                        'Legs'
                      ]
                          .map((name) => DropdownMenuItem(
                                value: name,
                                child: Text(
                                  name,
                                  style: const TextStyle(
                                      color: AppColors.grayColor, fontSize: 14),
                                ),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          // Map dropdown value back to _gender
                          selectedWorkout = value!;
                        });
                      },
                      isExpanded: true,
                      hint: Text(
                        "Choose Gender",
                        style: const TextStyle(
                            color: AppColors.grayColor, fontSize: 12),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 8,
                )
              ],
            ),
          ),
          // const SizedBox(
          //   height: 10,
          // ),
          // IconTitleNextRow(
          //     icon: "icons/difficulity_icon.png",
          //     title: "Difficulity",
          //     time: "Beginner",
          //     color: AppColors.lightGrayColor,
          //     onPressed: () {}),
          // const SizedBox(
          //   height: 10,
          // ),
          // IconTitleNextRow(
          //     icon: "icons/repetitions.png",
          //     title: "Custom Repetitions",
          //     time: "",
          //     color: AppColors.lightGrayColor,
          //     onPressed: () {}),
          // const SizedBox(
          //   height: 10,
          // ),
          // IconTitleNextRow(
          //     icon: "icons/repetitions.png",
          //     title: "Custom Weights",
          //     time: "",
          //     color: AppColors.lightGrayColor,
          //     onPressed: () {}),
          Spacer(),
          RoundGradientButton(
            title: "Save",
            onPressed: _saveSchedule,
          ),
          const SizedBox(
            height: 20,
          ),
        ]),
      ),
    );
  }
}
