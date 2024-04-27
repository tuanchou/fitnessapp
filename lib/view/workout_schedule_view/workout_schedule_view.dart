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

      // Xử lý dữ liệu từ querySnapshot và cập nhật danh sách eventArr
      eventArr = querySnapshot.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;

        // Trích xuất các trường từ dữ liệu Firestore và chuyển đổi định dạng
        var workoutName = data['workout'] ?? ''; // Tên workout
        var date = data['date'] as Timestamp?; // Timestamp của ngày
        var time = data['time'] as Timestamp?; // Timestamp của thời gian
        var markdone = data['markdone'] ?? false;
        // Định dạng ngày và giờ thành định dạng mong muốn (dd/MM/yyyy hh:mm a)

        var formattedDate = formatTimestampToDate(date);
        var formattedTime = time != null
            ? formatTime12Hour(time.toDate().toString().substring(11, 16))
            : '';

        // Tạo map mới với các trường đã định dạng
        return {
          'name': workoutName,
          'start_time': formattedDate + ' ' + formattedTime,
          'markdone': markdone,
        };
      }).toList();

      // Cập nhật danh sách các sự kiện cho ngày được chọn
      setDayEventWorkoutList();
    } catch (e) {
      print('Error loading workout schedule data: $e');
    }
  }

  void setDayEventWorkoutList() {
    var date = dateToStartDate(_selectedDateAppBBar);
    selectDayEventArr = eventArr.where((wObj) {
      var start_time = wObj["start_time"] as String?; // Lấy giá trị start_time
      if (start_time != null) {
        var eventDate =
            stringToDate(start_time, formatStr: "dd/MM/yyyy hh:mm aa");
        return dateToStartDate(eventDate) == date;
      }
      return false; // Trả về false nếu start_time là null
    }).toList();

    // Sắp xếp danh sách theo thời gian
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
              "icons/back_icon.png",
              width: 15,
              height: 15,
              fit: BoxFit.contain,
            ),
          ),
        ),
        title: Text(
          "Workout Schedule",
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
            initialDate: _selectedDateAppBBar, // Sử dụng ngày được chọn
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
                                  var gradientColors = markdone
                                      ? AppColors.primaryG
                                      : AppColors.secondaryG;

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
                                        var eventName = sObj["name"].toString();
                                        var eventFormattedTime = eventTime;
                                        showEventDetailsDialog(
                                            eventName, eventFormattedTime);
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

  void showEventDetailsDialog(String eventName, DateTime formattedTime) {
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
                            collectionName:
                                eventName, // Truyền tên collection 'chest' vào WorkoutDetailView
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
                    // Tìm document tương ứng với sự kiện đang xử lý
                    var eventDoc = eventArr.firstWhere((event) =>
                        event['name'] == eventName &&
                        event['start_time'] ==
                            formatDateTimeToString(formattedTime));

                    // Lấy document ID
                    String docId = eventDoc['id'];

                    // Cập nhật trường markdone trong Firestore
                    workout_schedule
                        .doc(docId)
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
