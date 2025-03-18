import 'dart:async';
import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:user_app/common/app_style.dart';
import 'package:user_app/views/dashboard/dash_board_screen.dart';
import '../../constants/constants.dart';
import '../auth/phone_authentication_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), () {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        Get.offAll(() => DashBoardScreen(),
            transition: Transition.cupertino,
            duration: const Duration(milliseconds: 900));
        log("User is authenticated");
      } else {
        Get.offAll(() => const PhoneAuthenticationScreen(),
            transition: Transition.cupertino,
            duration: const Duration(milliseconds: 900));
        log("User is null");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kWhite,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Image.asset(
              "assets/n_logo_remove.png",
              height: 300.h,
              fit: BoxFit.cover,
            ),
          ),
          // SizedBox(height: 10.h),
          Text(appName, style: appStyle(20, kPrimary, FontWeight.bold)),
          SizedBox(height: 5.h),
          Text(slogan, style: appStyle(16, kDarkGray, FontWeight.w500)),
        ],
      ),
    );
  }
}
