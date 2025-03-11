import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:user_app/common/app_style.dart';
import 'package:user_app/common/custom_button.dart';
import 'package:user_app/common/custom_heading.dart';
import 'package:user_app/common/custom_text_field_widget.dart';
import 'package:user_app/constants/constants.dart';
import 'package:user_app/controllers/complete_your_profile_controller.dart';

class CompleteYourProfileScreen extends StatefulWidget {
  const CompleteYourProfileScreen({super.key});

  @override
  State<CompleteYourProfileScreen> createState() =>
      _CompleteYourProfileScreenState();
}


class _CompleteYourProfileScreenState extends State<CompleteYourProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Profile",
          style: appStyle(25, kDark, FontWeight.normal),
        ),
      ),
      body: GetBuilder<CompleteYourProfileController>(
        init: CompleteYourProfileController(),
        builder: (value) {
          if (!value.isLoading) {
            return SingleChildScrollView(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 15.h),
                    const CustomHeadingWidget(heading: "Enter Your Name"),
                    SizedBox(height: 5.h),
                    CustomTextFieldWidget(
                        controller: value.nameController,
                        textInputType: TextInputType.name),
                    SizedBox(height: 20.h),
                    const CustomHeadingWidget(heading: "Enter Your Email"),
                    SizedBox(height: 5.h),
                    CustomTextFieldWidget(
                        controller: value.emailController,
                        textInputType: TextInputType.emailAddress),
                    SizedBox(height: 20.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const CustomHeadingWidget(heading: "Address"),
                        CustomButton(
                          text: "Add Address",
                          onPress: () {
                            String newAddress = value.addressController.text.toString();
                            if(newAddress.isNotEmpty && value.addressList.length<5){
                              value.addAddress(newAddress);
                              value.addressController.clear();
                            }
                          },
                          backgroundColor: kPrimary,
                          width: 60,
                          height: 38,
                        )
                      ],
                    ),
                    SizedBox(height: 5.h),
                    CustomTextFieldWidget(
                        controller: value.addressController,
                        textInputType: TextInputType.streetAddress),
                    SizedBox(height: 20.h),
                    const CustomHeadingWidget(heading: "WhatsApp Number"),
                    SizedBox(height: 5.h),
                    CustomTextFieldWidget(
                        controller: value.whatsAppNumberController,
                        textInputType: TextInputType.number),
                    SizedBox(height: 20.h),
                    if (value.addressList.isNotEmpty) ...[
                      const CustomHeadingWidget(heading: "Addresses"),
                      SizedBox(height: 5.h),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: value.addressList.map((address) {
                          return Text(address);
                        }).toList(),
                      ),
                      SizedBox(height: 20.h),
                    ],
                    Center(
                      child: CustomButton(
                          text: "Continue",
                          onPress: () => value.updateUserDetails(),
                          backgroundColor: kPrimary),
                    )
                  ],
                ),
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
