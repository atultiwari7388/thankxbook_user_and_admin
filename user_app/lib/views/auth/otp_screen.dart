import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../../common/app_style.dart';
import '../../common/custom_button.dart';
import '../../common/reusable_text.dart';
import '../../constants/constants.dart';
import '../../controllers/authentication_controller.dart';
import '../../utils/common_utils.dart';
import '../../utils/toast_msg.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key, required this.verificationId});

  final String verificationId;

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  late Timer _timer;
  int _secondsRemaining = 120; // 2 minutes

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(oneSec, (timer) {
      if (_secondsRemaining == 0) {
        timer.cancel();
        // Handle OTP expiration, e.g., resend OTP or display a message
      } else {
        setState(() {
          _secondsRemaining--;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    AuthenticationController authenticationController =
        Get.find<AuthenticationController>();

    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: kLightWhite,
        appBar: AppBar(),
        body: authenticationController.isVerification
            ? const Center(child: CircularProgressIndicator())
            : Container(
                padding: EdgeInsets.all(12.w),
                margin: EdgeInsets.only(left: 10.w, right: 20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // SizedBox(height: size.height * .2),
                    Image.asset("assets/otp.png",
                        height: 130.h, width: double.maxFinite),
                    SizedBox(height: size.height * .06),
                    Center(
                      child: ReusableText(
                        text: "OTP Verification",
                        style: appStyle(25, kDark, FontWeight.w500),
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Center(
                      child: Text("We have sent a verification code to",
                          style: appStyle(14, kDark, FontWeight.normal)),
                    ),
                    SizedBox(height: 5.h),
                    Center(
                      child: Text(
                          " +91${authenticationController.phoneController.text.toString()}",
                          style: appStyle(14, kDark, FontWeight.bold)),
                    ),

                    SizedBox(height: 20.h),
                    Center(
                      child: SizedBox(
                        height: size.height / 18,
                        width: size.width / 1.2,
                        child: PinCodeTextField(
                          appContext: context,
                          // controller: controller.otpController,
                          length: 6,
                          onChanged: (val) {
                            log("Otp Value $val");
                          },
                          pinTheme: PinTheme(
                            shape: PinCodeFieldShape.box,
                            borderRadius: BorderRadius.circular(18),
                            fieldHeight: size.height / 19,
                            fieldWidth: size.width / 8,
                          ),
                          keyboardType: TextInputType.number,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          onCompleted: (otp) {
                            authenticationController.otpController.text = otp;
                            authenticationController.signInWithPhoneNumber(
                                context, otp);
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ReusableText(
                            text: "Wait for OTP  ",
                            style: appStyle(18, kDark, FontWeight.w500)),
                        ReusableText(
                            text: formatTime(_secondsRemaining),
                            style: appStyle(16, kPrimary, FontWeight.w500)),
                      ],
                    ),
                    SizedBox(height: 50.h),
                    CustomButton(
                        backgroundColor: kPrimary,
                        text: "Verify",
                        onPress: () {
                          if (authenticationController
                                  .otpController.text.length ==
                              6) {
                            String otp =
                                authenticationController.otpController.text;
                            authenticationController.signInWithPhoneNumber(
                                context, otp);
                          } else {
                            showToastMessage(
                              "Error",
                              "Please enter 6-digit number",
                              Colors.red,
                            );
                          }
                        }),
                  ],
                ),
              ),
      ),
    );
  }
}
