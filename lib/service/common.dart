import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

String getTime(int value, {String formatStr = "hh:mm a"}) {
  var format = DateFormat(formatStr);
  return format.format(
      DateTime.fromMillisecondsSinceEpoch(value * 60 * 1000, isUtc: true));
}

String getStringDateToOtherFormat1(String inputDate,
    {String outFormatStr = "h:mm aa"}) {
  // Chuyển đổi chuỗi inputDate thành đối tượng DateTime
  DateTime dateTime = DateTime.parse(inputDate);

  // Định dạng lại thời gian theo định dạng mong muốn
  String formattedTime = DateFormat(outFormatStr).format(dateTime);

  return formattedTime;
}

String getStringDateToOtherFormate(String dateStr,
    {String inputFormatStr = "dd/MM/yyyy hh:mm aa",
    String outFormatStr = "hh:mm a"}) {
  var format = DateFormat(outFormatStr);
  return format.format(stringToDate(dateStr, formatStr: inputFormatStr));
}

DateTime stringToDate(String dateStr, {String formatStr = "hh:mm a"}) {
  var format = DateFormat(formatStr);
  return format.parse(dateStr);
}

DateTime dateToStartDate(DateTime date) {
  return DateTime(date.year, date.month, date.day);
}

String dateToString(DateTime date, {String formatStr = "dd/MM/yyyy hh:mm a"}) {
  var format = DateFormat(formatStr);
  return format.format(date);
}

String formatDateTimeToString1(DateTime datetime) {
  String day = datetime.day.toString().padLeft(2, '0');
  String month = datetime.month.toString().padLeft(2, '0');
  String year = datetime.year.toString();
  String hour = datetime.hour.toString().padLeft(2, '0');
  String minute = datetime.minute.toString().padLeft(2, '0');
  String period = datetime.hour >= 12 ? 'PM' : 'AM';

  return '$day/$month/$year $hour:$minute $period';
}

String formatDateTimeToString(DateTime datetime) {
  return '${datetime.day}/${datetime.month}/${datetime.year} ${datetime.hour}:${datetime.minute}';
}

String formatTimestampToDate(Timestamp? timestamp) {
  if (timestamp == null) return ''; // Trường hợp timestamp là null

  DateTime dateTime = timestamp.toDate(); // Chuyển đổi Timestamp sang DateTime

  // Định dạng ngày tháng theo định dạng 'dd/MM/yyyy'
  String formattedDate = DateFormat('dd/MM/yyyy').format(dateTime);

  return formattedDate; // Trả về chuỗi định dạng ngày tháng
}

String formatTimePA(DateTime time) {
  var formatter = DateFormat('hh:mm a');
  return formatter.format(time);
}

String formatTime12Hour(String time) {
  // Chuyển đổi thời gian từ định dạng 24 giờ (HH:mm) sang định dạng 12 giờ (hh:mm a)
  var hourMinute = time.split(':');
  var hour = int.parse(hourMinute[0]);
  var minute = int.parse(hourMinute[1]);

  String period = (hour < 12) ? 'AM' : 'PM'; // Xác định AM hoặc PM

  // Chuyển đổi giờ sang định dạng 12 giờ
  hour = (hour > 12) ? hour - 12 : hour;
  hour = (hour == 0) ? 12 : hour; // Giờ 00:00 được chuyển thành 12:00 AM

  // Định dạng lại thời gian
  return '$hour:${minute.toString().padLeft(2, '0')} $period';
}

String getDayTitle(DateTime dateTime) {
  if (isSameDay(dateTime, DateTime.now())) {
    return "Today";
  } else if (isSameDay(dateTime, DateTime.now().add(Duration(days: 1)))) {
    return "Tomorrow";
  } else if (isSameDay(dateTime, DateTime.now().subtract(Duration(days: 1)))) {
    return "Yesterday";
  } else {
    var outFormat = DateFormat("E");
    return outFormat.format(dateTime);
  }
}

bool isSameDay(DateTime date1, DateTime date2) {
  return date1.year == date2.year &&
      date1.month == date2.month &&
      date1.day == date2.day;
}

extension DateHelpers on DateTime {
  bool get isToday {
    return DateTime(year, month, day).difference(DateTime.now()).inDays == 0;
  }

  bool get isYesterday {
    return DateTime(year, month, day).difference(DateTime.now()).inDays == -1;
  }

  bool get isTomorrow {
    return DateTime(year, month, day).difference(DateTime.now()).inDays == 1;
  }
}
