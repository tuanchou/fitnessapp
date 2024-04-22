import 'dart:async';

import 'package:fitness/service/app_colors.dart';
import 'package:fitness/service/round_gradient_button.dart';
import 'package:fitness/service/round_iconbutton.dart';
import 'package:fitness/service/videoplayerwidget.dart';
import 'package:fitness/view/workour/widget/step_detail_row.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:readmore/readmore.dart';

class ExercisesStepDetails extends StatefulWidget {
  final Map eObj;
  const ExercisesStepDetails({Key? key, required this.eObj}) : super(key: key);

  @override
  State<ExercisesStepDetails> createState() => _ExercisesStepDetailsState();
}

class _ExercisesStepDetailsState extends State<ExercisesStepDetails> {
  late int timeInSeconds = 20; // Thời gian ban đầu là 20 giây
  late Timer? timer; // Biến đếm ngược
  bool isTimerInitialized = false;

  @override
  void dispose() {
    if (isTimerInitialized && timer != null) {
      timer!.cancel(); // Hủy timer khi widget bị dispose để tránh memory leak
    } // Hủy timer khi widget bị dispose để tránh memory leak
    super.dispose();
  }

  void startTimer() {
    const oneSecond = Duration(seconds: 1);
    timer = Timer.periodic(oneSecond, (timer) {
      setState(() {
        if (timeInSeconds > 0) {
          timeInSeconds--;
        } else {
          timer.cancel(); // Hủy timer khi thời gian đếm ngược đạt 0
        }
      });
    });
    isTimerInitialized = true;
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
      ),
      backgroundColor: AppColors.whiteColor,
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.eObj["title"].toString(),
                style: TextStyle(
                    color: AppColors.blackColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w700),
              ),
              const SizedBox(
                height: 4,
              ),
              Text(
                "Easy | 390 Calories Burn",
                style: TextStyle(
                  color: AppColors.grayColor,
                  fontSize: 12,
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              Container(
                width: media.width,
                height: media.width * 0.43,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                ),
                child: widget.eObj["_videoUrl"] != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Videoplayerwidget(
                          videoUrl: widget.eObj["_videoUrl"],
                          autoPlay: false,
                        ),
                      )
                    : Placeholder(), // Placeholder hoặc widget khác để hiển thị khi không có video
              ),
              const SizedBox(
                height: 15,
              ),
              Text(
                "Descriptions",
                style: TextStyle(
                    color: AppColors.blackColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w700),
              ),
              const SizedBox(
                height: 4,
              ),
              ReadMoreText(
                widget.eObj["description"],
                trimLines: 4,
                colorClickableText: AppColors.blackColor,
                trimMode: TrimMode.Line,
                trimCollapsedText: ' Read More ...',
                trimExpandedText: ' Read Less',
                style: TextStyle(
                  color: AppColors.grayColor,
                  fontSize: 12,
                ),
                moreStyle:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              ),
              const SizedBox(
                height: 4,
              ),
              Text(
                "Note",
                style: TextStyle(
                    color: AppColors.blackColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w700),
              ),
              const SizedBox(
                height: 200,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "00:${timeInSeconds.toString().padLeft(2, '0')}",
                    style: TextStyle(
                      color: AppColors.grayColor,
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Center(
                child: RoundGradientButton(
                  title: "Start",
                  onPressed: () {
                    setState(() {
                      timeInSeconds =
                          20; // Reset thời gian về 20 giây khi nút được nhấn
                    });
                    startTimer();
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
