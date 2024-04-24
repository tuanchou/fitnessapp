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
              borderRadius: BorderRadius.circular(20), // Bo tròn viền
            ),
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
                          '${(wObj[fieldName] as double).toStringAsFixed(0)}%', // Làm tròn giá trị và thêm ký tự "%"
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
                    ratio:
                        (wObj[fieldName] as double? ?? 0.0).clamp(10.0, 100.0) /
                            100.0,
                    direction: Axis.horizontal,
                    curve: Curves.fastLinearToSlowEaseIn,
                    duration: const Duration(seconds: 3),
                    borderRadius: BorderRadius.circular(7.5),
                    gradientColor: LinearGradient(
                      colors: [
                        Color.fromARGB(255, 93, 152, 233),
                        Color.fromARGB(255, 55, 49, 163)
                      ], // Chỉ là ví dụ, bạn có thể thay đổi gradient tùy theo nhu cầu
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WorkoutDetailView(
                            collectionName: fieldName,
                          ),
                        ),
                      );
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
}
