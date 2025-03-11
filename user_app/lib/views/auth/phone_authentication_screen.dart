import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:user_app/common/custom_button.dart';
import 'package:user_app/views/auth/otp_screen.dart';
import '../../common/app_style.dart';
import '../../constants/constants.dart';
import '../../controllers/authentication_controller.dart';
import '../../utils/toast_msg.dart';

class PhoneAuthenticationScreen extends StatelessWidget {
  const PhoneAuthenticationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authController = Get.put(AuthenticationController());
    String vId = "";
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: GetBuilder<AuthenticationController>(
        init: AuthenticationController(),
        builder: (value) {
          if (!value.isLoading) {
            return Container(
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(15)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Image or App Logo
                  Expanded(
                    flex: 1,
                    child: Container(
                      margin: EdgeInsets.all(40.h),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20.r),
                            topRight: Radius.circular(20.r)),
                        image: const DecorationImage(
                          image: AssetImage("assets/read_book.png"),
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                  ),
                  // phone auth and login section
                  Expanded(
                    flex: 1,
                    child: Column(
                      // mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        // Heading
                        SizedBox(height: 7.h),
                        Text("Login/Signup",
                            textAlign: TextAlign.center,
                            style: appStyle(20, kPrimary, FontWeight.bold)),

                        SizedBox(height: 7.h),
                        Padding(
                          padding: EdgeInsets.only(left: 18.0.w, right: 18.0.w),
                          child: Text(
                              "Enter your mobile number, we will send you OTP to verify.",
                              textAlign: TextAlign.center,
                              style: appStyle(14, kGray, FontWeight.normal)),
                        ),

                        SizedBox(height: 10.h),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0.h),
                          child: Row(
                            children: [
                              // Indian Flag Symbol
                              Container(
                                decoration: BoxDecoration(
                                    border: Border.all(color: kGrayLight),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10.r)),
                                    color: kOffWhite),
                                child: Container(
                                  padding:
                                      EdgeInsets.only(left: 4.w, right: 7.w),
                                  // Add padding for spacing around the image
                                  alignment: Alignment.center,
                                  // Center the image within its container
                                  child: Image.asset(
                                    "assets/india.png",
                                    width: 40.w,
                                    height: 40.h,
                                  ),
                                ),
                              ),

                              SizedBox(width: 16.w), // Horizontal Space

                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 5.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8.h),
                                      border: Border.all(color: kGray),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.1),
                                          spreadRadius: 2,
                                          blurRadius: 5,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: TextFormField(
                                      controller: value.phoneController,
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                          border: InputBorder.none,
                                          hintText: "  Enter your phone number",
                                          prefixText: " ",
                                          prefixStyle: appStyle(
                                              14, kDark, FontWeight.w200)),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 40.h),
                        CustomButton(
                            backgroundColor: kPrimary,
                            text: "Continue",
                            onPress: () {
                              if (authController.phoneController.text.length ==
                                  10) {
                                authController.verifyPhoneNumber();
                                Get.to(() => OtpScreen(verificationId: vId));
                              } else {
                                showToastMessage(
                                  "Error",
                                  "Please enter a valid 10-digit number",
                                  Colors.red,
                                );
                              }
                            }),
                        // SizedBox(height: 20.h),
                        const Spacer(),
                        SizedBox(
                          width: 260.w,
                          child: Text(
                              "By Continuing , you agree to our Terms of Service Privacy Policy Content Policy.",
                              textAlign: TextAlign.center,
                              style: appStyle(10, kGray, FontWeight.w500)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
