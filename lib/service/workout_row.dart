import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness/service/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:fitness/view/workour/workour_detail_view.dart';
import 'package:simple_animation_progress_bar/simple_animation_progress_bar.dart';

class WorkoutRow extends StatelessWidget {
  final Map<String, dynamic> wObj;
  const WorkoutRow({Key? key, required this.wObj}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    List<String> fieldNames = wObj.keys.toList(); // Lấy danh sách các key

    return Column(
      children: [
        for (var fieldName in fieldNames)
          Card(
            elevation: 2, // Độ đổ bóng
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30), // Bo tròn viền
            ),
            color: Color.fromARGB(255, 169, 207, 245),
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fieldName,
                          style: TextStyle(color: Colors.black, fontSize: 20),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${(wObj[fieldName] is double ? wObj[fieldName] as double : (wObj[fieldName] as int).toDouble()).toStringAsFixed(0)}%',
                          style: TextStyle(color: Colors.black, fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                      ],
                    ),
                  ),
                  SimpleAnimationProgressBar(
                    height: 15,
                    width: media.width *
                        0.5, // Điều chỉnh chiều rộng tùy theo nhu cầu
                    backgroundColor: Colors.grey.shade100,
                    foregrondColor: Color.fromARGB(255, 169, 9, 9),
                    ratio: ((wObj[fieldName] is double
                                ? wObj[fieldName]
                                : (wObj[fieldName] as int).toDouble())
                            .clamp(10.0, 100.0) /
                        100.0),

                    direction: Axis.horizontal,
                    curve: Curves.fastLinearToSlowEaseIn,
                    duration: const Duration(seconds: 3),
                    borderRadius: BorderRadius.circular(20),
                    gradientColor: LinearGradient(
                      colors: [
                        AppColors.primaryColor1,
                        AppColors.secondaryColor1
                      ], // Chỉ là ví dụ, bạn có thể thay đổi gradient tùy theo nhu cầu
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      // Kiểm tra nếu giá trị là 100%
                      if (wObj[fieldName] == 100) {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text("Note"),
                              content: Text(
                                  "You have completed $fieldName, do you want to reset it?"),
                              actions: <Widget>[
                                TextButton(
                                  child: Text("No"),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                                TextButton(
                                  child: Text("Yes"),
                                  onPressed: () {
                                    String userId =
                                        FirebaseAuth.instance.currentUser!.uid;
                                    deleteUserProgressAndSubcollection(
                                        fieldName, context, userId);
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      } else {
                        // Nếu giá trị không phải 100%, điều hướng đến trang WorkoutDetailView
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => WorkoutDetailView(
                              collectionName: fieldName,
                            ),
                          ),
                        );
                      }
                    },
                    icon: Image.asset(
                      "icons/next_icon.png",
                      width: 20,
                      height: 20,
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Future<void> deleteUserProgressAndSubcollection(
      String fieldName, BuildContext context, String userId) async {
    try {
      // Delete the field from the user's document in the userProgress collection
      await FirebaseFirestore.instance
          .collection('userProgress')
          .doc(userId)
          .update({
        fieldName: FieldValue.delete(),
      });

      // Delete the subcollection
      QuerySnapshot subcollectionSnapshot = await FirebaseFirestore.instance
          .collection('userProgress')
          .doc(userId)
          .collection(fieldName)
          .get();
      for (DocumentSnapshot doc in subcollectionSnapshot.docs) {
        await doc.reference.delete();
      }

      // Show a snackbar to indicate successful deletion
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Data has been deleted successfully')),
      );
    } catch (error) {
      // Handle any errors that occur during the process
      print('Error deleting data: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred while deleting data')),
      );
    }
  }
}
