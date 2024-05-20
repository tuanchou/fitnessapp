import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness/service/app_colors.dart';
import 'package:fitness/service/round_gradient_button.dart';
import 'package:fitness/service/round_iconbutton.dart';
import 'package:fitness/service/videoplayerwidget.dart';
import 'package:fitness/view/workour/widget/step_detail_row.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:readmore/readmore.dart';

class ExercisesStepDetails extends StatefulWidget {
  final List<QueryDocumentSnapshot> items;
  final int currentIndex;
  final String collectionName;

  const ExercisesStepDetails(
      {Key? key,
      required this.items,
      required this.currentIndex,
      required this.collectionName})
      : super(key: key);

  @override
  State<ExercisesStepDetails> createState() => _ExercisesStepDetailsState();
}

class _ExercisesStepDetailsState extends State<ExercisesStepDetails> {
  late int timeInSeconds = 20;
  late Timer? timer;
  bool isTimerInitialized = false;
  bool isTimerVisible = false;
  bool isTimerRunning = false;
  User? user = FirebaseAuth.instance.currentUser;

  final CollectionReference _userprogress =
      FirebaseFirestore.instance.collection('userProgress');

  late int currentIndex;
  late Map<String, dynamic> currentData;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.currentIndex;
    currentData = widget.items[currentIndex].data() as Map<String, dynamic>;
  }

  @override
  void dispose() {
    if (isTimerInitialized && timer != null) {
      timer!.cancel();
    }
    super.dispose();
  }

  void startTimer() {
    const oneSecond = Duration(seconds: 1);
    timer = Timer.periodic(oneSecond, (timer) {
      setState(() {
        if (timeInSeconds > 0) {
          timeInSeconds--;
        } else {
          timer.cancel();
          onTimerFinished();
        }
      });
    });
    isTimerInitialized = true;
    isTimerRunning = true;
  }

  void stopTimer() {
    if (timer != null) {
      timer!.cancel();
    }
    setState(() {
      isTimerRunning = true;
    });
    showStopDialog();
  }

  Future<void> showStopDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Notification'),
          content:
              Text('You are about to complete the exercise, so try your best'),
          actions: <Widget>[
            TextButton(
              child: Text('Continue'),
              onPressed: () {
                Navigator.of(context).pop();
                startTimer();
              },
            ),
            TextButton(
              child: Text('Back to List'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

// Future<void> onTimerFinished() async {
//   // Lấy thông tin về item hiện tại
//   Map<String, dynamic> currentItemData = widget.items[currentIndex].data() as Map<String, dynamic>;

//   // Lấy ID của item hiện tại
//   String itemId = widget.items[currentIndex].id;

//   // Kiểm tra xem ID của item đã có trong subcollection chưa
//   bool isItemCompleted = await _checkItemCompletion(itemId);

//   // Nếu item đã hoàn thành trước đó, không thêm dữ liệu vào tiến trình
//   if (!isItemCompleted) {
//     // Thêm ID của item vào subcollection
//     await _userprogress.doc(user?.uid).collection(widget.collectionName).doc(itemId).set({'completed': true});

//     // Lấy thông tin về tiến trình của người dùng
//     DocumentSnapshot userDoc = await _userprogress.doc(user?.uid).get();

//     // Đếm tổng số item
//     int totalItems = widget.items.length;

//     // Tính phần trăm cho mỗi item
//     double percentageForEachItem = 100 / totalItems;

//     // Kiểm tra xem tiến trình của người dùng đã tồn tại hay chưa
//     if (userDoc.exists) {
//       // Lấy dữ liệu về tiến trình
//       final userData = userDoc.data() as Map<String, dynamic>;

//       // Tính toán phần trăm mới
//       double currentPercentage = userData.containsKey(widget.collectionName) ? userData[widget.collectionName] : 0.0;
//       double newPercentage = currentPercentage + percentageForEachItem;

//       // Cập nhật tiến trình của người dùng
//       await _userprogress.doc(user?.uid).set({
//         widget.collectionName: newPercentage,
//       }, SetOptions(merge: true));
//     } else {
//       // Nếu tiến trình chưa tồn tại, tạo mới và đặt phần trăm cho item đầu tiên
//       double newPercentage = percentageForEachItem;
//       await _userprogress.doc(user?.uid).set({
//         widget.collectionName: newPercentage,
//       });
//     }
//   }
// }

// Hàm kiểm tra xem ID của item đã có trong subcollection chưa
  Future<bool> _checkItemCompletion(String itemId) async {
    DocumentSnapshot itemDoc = await _userprogress
        .doc(user?.uid)
        .collection(widget.collectionName)
        .doc(itemId)
        .get();
    return itemDoc.exists;
  }

  Future<void> onTimerFinished() async {
    QuerySnapshot collectionSnapshot = await FirebaseFirestore.instance
        .collection(widget.collectionName)
        .get();
    Map<String, dynamic> currentItemData =
        widget.items[currentIndex].data() as Map<String, dynamic>;
    String itemId = widget.items[currentIndex].id;
    int totalItems = collectionSnapshot.docs.length;
    double percentageForEachItem = 100 / totalItems;
    bool isItemCompleted = await _checkItemCompletion(itemId);
    DocumentSnapshot userDoc = await _userprogress.doc(user?.uid).get();
    if (userDoc.exists) {
      if (!isItemCompleted) {
        final userData = userDoc.data() as Map<String, dynamic>;
        double currentPercentage = 0.0;
        double newPercentage = 0.0;
        if (userData != null && userData.containsKey(widget.collectionName)) {
          currentPercentage = userData[widget.collectionName];
          newPercentage = currentPercentage + percentageForEachItem;
          await _userprogress.doc(user?.uid).update({
            widget.collectionName: newPercentage,
          });
          await _userprogress
              .doc(user?.uid)
              .collection(widget.collectionName)
              .doc(itemId)
              .set({
            "complete": true,
          });
        } else {
          newPercentage = percentageForEachItem;
          await _userprogress.doc(user?.uid).set({
            widget.collectionName: newPercentage,
          }, SetOptions(merge: true));
          await _userprogress
              .doc(user?.uid)
              .collection(widget.collectionName)
              .doc(itemId)
              .set({
            "complete": true,
          });
        }
      }
    } else {
      double newPercentage = percentageForEachItem;
      await _userprogress.doc(user?.uid).set({
        widget.collectionName: newPercentage,
      });
      await _userprogress
          .doc(user?.uid)
          .collection(widget.collectionName)
          .doc(itemId)
          .set({
        "complete": true,
      });
    }
  }

  void showNextItem() {
    setState(() {
      if (currentIndex < widget.items.length - 1) {
        currentIndex++;
        currentData = widget.items[currentIndex].data() as Map<String, dynamic>;
        timeInSeconds = 20;
      }
    });
  }

  void showPreviousItem() {
    setState(() {
      if (currentIndex > 0) {
        currentIndex--;
        currentData = widget.items[currentIndex].data() as Map<String, dynamic>;
        timeInSeconds = 20;
      }
    });
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
                currentData["title"].toString(),
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
                child: currentData["_videoUrl"] != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Videoplayerwidget(
                          videoUrl: currentData["_videoUrl"],
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
                currentData["description"],
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
                height: 4,
              ),
              ReadMoreText(
                currentData["note"],
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
                height: 150,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  currentIndex > 0
                      ? GestureDetector(
                          onTap: showPreviousItem,
                          child: Image.asset(
                            "icons/ArrowLeft.png",
                            width: 24,
                            height: 24,
                            fit: BoxFit.contain,
                          ),
                        )
                      : SizedBox(width: 24),
                  SizedBox(width: 20),
                  Text(
                    "${currentIndex + 1}/${widget.items.length}",
                    style: TextStyle(
                      color: AppColors.blackColor,
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(width: 20),
                  currentIndex < widget.items.length - 1
                      ? GestureDetector(
                          onTap: showNextItem,
                          child: Image.asset(
                            "icons/ArrowRight.png",
                            width: 24,
                            height: 24,
                            fit: BoxFit.contain,
                          ),
                        )
                      : SizedBox(width: 24)
                ],
              ),
              const SizedBox(
                height: 50,
              ),
              if (isTimerVisible)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (timeInSeconds == 0)
                      Text(
                        "Hoàn thành bài tập",
                        style: TextStyle(
                          color: AppColors.grayColor,
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                        ),
                      )
                    else
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
                  title: timeInSeconds == 0
                      ? "Next"
                      : (isTimerRunning ? "Stop" : "Start"),
                  onPressed: () {
                    setState(() {
                      if (timeInSeconds == 0) {
                        showNextItem();
                        isTimerVisible = false;
                        isTimerRunning = false;
                      } else {
                        if (isTimerRunning) {
                          stopTimer();
                          isTimerVisible = true;
                        } else {
                          timeInSeconds = 5;
                          startTimer();
                          isTimerVisible = true;
                        }
                      }
                    });
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
