import 'package:flutter/widgets.dart';
import '../utils/constants.dart';
import 'app_style.dart';

class CustomHeadingWidget extends StatelessWidget {
  const CustomHeadingWidget({
    super.key,
    required this.heading,
  });

  final String heading;

  @override
  Widget build(BuildContext context) {
    return Text(heading, style: appStyle(17, kDark, FontWeight.normal));
  }
}
