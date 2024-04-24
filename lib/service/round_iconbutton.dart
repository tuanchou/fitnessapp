import 'package:fitness/service/app_colors.dart';
import 'package:flutter/material.dart';

class RoundIconButton extends StatelessWidget {
  final String iconAsset;
  final Function() onPressed;

  const RoundIconButton(
      {Key? key, required this.iconAsset, required this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        width: 30, // Đảm bảo nút có kích thước vuông
        height: 30, // Đảm bảo nút có kích thước vuông
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: AppColors.primaryG,
              begin: Alignment.centerLeft,
              end: Alignment.centerRight),
          shape: BoxShape.circle, // Đặt hình dạng thành hình tròn
          boxShadow: const [
            BoxShadow(
                color: Colors.black26, blurRadius: 2, offset: Offset(0, 2)),
          ],
        ),
        child: MaterialButton(
          padding: EdgeInsets.zero,
          onPressed: onPressed,
          shape: CircleBorder(), // Đặt hình dạng của nút thành hình tròn
          child: Image.asset(
            iconAsset,
            width:
                24, // Điều chỉnh kích thước của biểu tượng theo nhu cầu của bạn
            height: 24,
            color: AppColors.whiteColor,
          ),
        ),
      ),
    );
  }
}
