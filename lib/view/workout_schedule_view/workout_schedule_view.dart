import 'package:calendar_agenda/calendar_agenda.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness/service/app_colors.dart';
import 'package:fitness/service/common.dart';
import 'package:fitness/service/round_gradient_button.dart';
import 'package:fitness/view/workour/workour_detail_view.dart';
import 'package:flutter/material.dart';

import 'add_schedule_view.dart';

class WorkoutScheduleView extends StatefulWidget {
  static String routeName = "/WorkoutScheduleView";
  const WorkoutScheduleView({Key? key}) : super(key: key);

  @override
  State<WorkoutScheduleView> createState() => _WorkoutScheduleViewState();
}

class _WorkoutScheduleViewState extends State<WorkoutScheduleView> {
  CalendarAgendaController _calendarAgendaControllerAppBar =
      CalendarAgendaController();
  late DateTime _selectedDateAppBBar;

  final CollectionReference workout_schedule =
      FirebaseFirestore.instance.collection('workout_schedule');
  User? user = FirebaseAuth.instance.currentUser;

  List eventArr = [];

  List selectDayEventArr = [];

  @override
  void initState() {
    super.initState();
    _selectedDateAppBBar = DateTime.now();
    loadWorkoutScheduleData();

    setDayEventWorkoutList();
  }

  void loadWorkoutScheduleData() async {
    try {
      var querySnapshot =
          await workout_schedule.where('user_id', isEqualTo: user?.uid).get();

      eventArr = querySnapshot.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;
        var workoutName = data['workout'] ?? '';
        var date = data['date'] as Timestamp?;
        var time = data['time'] as Timestamp?;
        var markdone = data['markdone'] ?? false;

        var formattedDate = formatTimestampToDate(date);
        var formattedTime = time != null
            ? formatTime12Hour(time.toDate().toString().substring(11, 16))
            : '';

        return {
          'id': doc.id,
          'name': workoutName,
          'start_time': formattedDate + ' ' + formattedTime,
          'markdone': markdone,
        };
      }).toList();

      setDayEventWorkoutList();
    } catch (e) {
      print('Error loading workout schedule data: $e');
    }
  }

  void setDayEventWorkoutList() {
    var date = dateToStartDate(_selectedDateAppBBar);
    selectDayEventArr = eventArr.where((wObj) {
      var start_time = wObj["start_time"] as String?;
      if (start_time != null) {
        var eventDate =
            stringToDate(start_time, formatStr: "dd/MM/yyyy hh:mm aa");
        return dateToStartDate(eventDate) == date;
      }
      return false;
    }).toList();

    selectDayEventArr.sort((a, b) {
      var aTime = stringToDate(a["start_time"].toString(),
          formatStr: "dd/MM/yyyy hh:mm aa");
      var bTime = stringToDate(b["start_time"].toString(),
          formatStr: "dd/MM/yyyy hh:mm aa");
      return aTime.compareTo(bTime);
    });

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    bool isDone = false;
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CalendarAgenda(
            controller: _calendarAgendaControllerAppBar,
            appbar: false,
            selectedDayPosition: SelectedDayPosition.center,
            weekDay: WeekDay.short,
            backgroundColor: Colors.transparent,
            fullCalendarScroll: FullCalendarScroll.horizontal,
            fullCalendarDay: WeekDay.short,
            selectedDateColor: Colors.blue,
            dateColor: Colors.black,
            locale: 'en',
            initialDate: _selectedDateAppBBar,
            calendarEventColor: AppColors.primaryColor2,
            firstDate: DateTime.now().subtract(const Duration(days: 140)),
            lastDate: DateTime.now().add(const Duration(days: 60)),
            onDateSelected: (date) {
              _selectedDateAppBBar = date;
              setDayEventWorkoutList();
            },
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: media.width * 1.5,
                child: ListView.separated(
                  shrinkWrap: true,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 1),
                  itemCount: 24, // Số giờ trong ngày
                  itemBuilder: (context, hourIndex) {
                    var slotArr = selectDayEventArr.where((wObj) {
                      var eventTime = stringToDate(
                          wObj["start_time"].toString(),
                          formatStr: "dd/MM/yyyy hh:mm aa");
                      return eventTime.hour == hourIndex;
                    }).toList();

                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      height: 40,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 80,
                            child: Text(
                              getTime(hourIndex * 60),
                              style: TextStyle(
                                color: AppColors.blackColor,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          if (slotArr.isNotEmpty)
                            Expanded(
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: slotArr.map((sObj) {
                                  var eventTime = stringToDate(
                                      sObj["start_time"].toString(),
                                      formatStr: "dd/MM/yyyy hh:mm aa");
                                  var formattedTime = eventTime != null
                                      ? formatTimePA(eventTime)
                                      : '';
                                  var markdone = sObj["markdone"] ??
                                      false; // Lấy giá trị markdone
                                  var gradientColors;
                                  if (markdone) {
                                    gradientColors = AppColors.primaryG;
                                  } else {
                                    if (eventTime.isAfter(DateTime.now())) {
                                      gradientColors = AppColors.secondaryG;
                                    } else {
                                      if (eventTime.isBefore(DateTime.now())) {
                                        gradientColors = AppColors.gray;
                                      }
                                    }
                                  }

                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                          colors: gradientColors),
                                      borderRadius: BorderRadius.circular(17.5),
                                    ),
                                    child: InkWell(
                                      onTap: () {
                                        // Chỉ hiển thị hộp thoại nếu màu sắc là AppColors.secondaryG
                                        var markdone =
                                            sObj["markdone"] ?? false;
                                        var eventTime = stringToDate(
                                          sObj["start_time"].toString(),
                                          formatStr: "dd/MM/yyyy hh:mm aa",
                                        );

                                        // Kiểm tra nếu sự kiện đã được đánh dấu là hoàn thành (markdone = true)
                                        // hoặc nếu thời gian sự kiện đã qua thì không hiển thị dialog
                                        if (!markdone &&
                                            eventTime.isAfter(DateTime.now())) {
                                          var eventId = sObj["id"].toString();
                                          var eventName =
                                              sObj["name"].toString();
                                          var eventFormattedTime = eventTime;

                                          // Hiển thị dialog
                                          showEventDetailsDialog(
                                            eventId,
                                            eventName,
                                            eventFormattedTime,
                                          );
                                        }
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                              colors: gradientColors),
                                          borderRadius:
                                              BorderRadius.circular(17.5),
                                        ),
                                        child: Text(
                                          '${sObj["name"].toString()}, ${formattedTime} ',
                                          style: TextStyle(
                                            color: Color.fromARGB(255, 0, 0, 0),
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddScheduleView(
                date: _selectedDateAppBBar,
                onScheduleAdded: () {
                  // Gọi lại hàm loadWorkoutScheduleData() khi lịch được thêm thành công
                  loadWorkoutScheduleData();
                },
              ),
            ),
          );
        },
        child: Container(
          width: 55,
          height: 55,
          decoration: BoxDecoration(
              gradient: LinearGradient(colors: AppColors.secondaryG),
              borderRadius: BorderRadius.circular(27.5),
              boxShadow: const [
                BoxShadow(
                    color: Colors.black12, blurRadius: 5, offset: Offset(0, 2))
              ]),
          alignment: Alignment.center,
          child: Icon(
            Icons.add,
            size: 20,
            color: AppColors.whiteColor,
          ),
        ),
      ),
    );
  }

  void showEventDetailsDialog(
      String eventId, String eventName, DateTime formattedTime) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.transparent,
          contentPadding: EdgeInsets.zero,
          content: Container(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            decoration: BoxDecoration(
              color: AppColors.whiteColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
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
                    Text(
                      "Workout Schedule",
                      style: TextStyle(
                          color: AppColors.blackColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w700),
                    ),
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
                const SizedBox(
                  height: 15,
                ),
                Text(
                  eventName,
                  style: TextStyle(
                      color: AppColors.blackColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w700),
                ),
                const SizedBox(
                  height: 4,
                ),
                Row(children: [
                  Image.asset(
                    "icons/time_workout.png",
                    height: 20,
                    width: 20,
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Text(
                    "${getDayTitle(formattedTime)} | ${getStringDateToOtherFormat1(formattedTime.toString(), outFormatStr: "h:mm aa")}",
                    style: TextStyle(color: AppColors.grayColor, fontSize: 16),
                  )
                ]),
                const SizedBox(
                  height: 15,
                ),
                RoundGradientButton(
                    title: "Start Workout",
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WorkoutDetailView(
                            collectionName: eventName,
                          ),
                        ),
                      );
                    }),
                const SizedBox(
                  height: 10,
                ),
                RoundGradientButton(
                  title: "Mark Done",
                  onPressed: () {
                    // Cập nhật trường markdone trong Firestore
                    workout_schedule
                        .doc(eventId)
                        .update({'markdone': true}).then((_) {
                      print('markdone updated successfully');
                      // Cập nhật giao diện hoặc thực hiện các hành động khác
                      Navigator.pop(context);
                      loadWorkoutScheduleData(); // Tải lại dữ liệu sau khi cập nhật
                    }).catchError((error) {
                      print('Error updating markdone: $error');
                    });
                  },
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
