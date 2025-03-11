import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:user_app/common/app_style.dart';
import 'package:user_app/constants/constants.dart';

class CustomReusableRowWidget extends StatelessWidget {
  const CustomReusableRowWidget({
    super.key,
    required this.iconName,
    required this.title,
    required this.color,
  });

  final IconData iconName;
  final String title;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(iconName, size: 25.sp, color: color),
        SizedBox(width: 5.w),
        SizedBox(
          width: 270.w,
          child: Text(
            title,
            style: appStyle(14, kDark, FontWeight.normal),
          ),
        ),
      ],
    );
  }
}
