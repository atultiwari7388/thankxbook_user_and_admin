import 'package:flutter/material.dart';
import 'package:library_admin/common/app_style.dart';
import 'package:library_admin/utils/constants.dart';

class CustomTextWidget extends StatelessWidget {
  const CustomTextWidget(
      {Key? key,
        required this.text,
        this.size = 16,
        this.color = kDark,
        this.fontWeight = FontWeight.normal})
      : super(key: key);
  final String text;
  final double size;
  final Color color;
  final FontWeight fontWeight;

  @override
  Widget build(BuildContext context) {
    return Text(text,style: appStyle(size, color, fontWeight));
        // style: AppFontStyles.font16Style
        //     .copyWith(color: color, fontSize: size, fontWeight: fontWeight));
  }
}
