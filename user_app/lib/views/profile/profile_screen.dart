import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:user_app/common/app_style.dart';
import 'package:user_app/constants/constants.dart';
import 'package:user_app/services/firebase_collections.dart';
import 'package:user_app/views/aboutUs/about_us_screen.dart';
import 'package:user_app/views/auth/phone_authentication_screen.dart';
import 'package:user_app/views/contactDetails/contact_details_screen.dart';
import 'package:user_app/views/privacyPolicy/privacy_policy_screeen.dart';
import 'package:user_app/views/profile/profile_details_screen.dart';
import 'package:user_app/views/termsCondition/terms_condition.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Menu"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: 0.h),
              GestureDetector(
                  onTap: () => Get.to(() => ProfileDetailsScreen()),
                  child: buildTopProfileSection()),
              SizedBox(height: 10.h),
              Container(
                width: double.maxFinite,
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: kLightWhite,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          "Manage Profile",
                          style: kIsWeb
                              ? TextStyle(color: kPrimary)
                              : appStyle(18, kPrimary, FontWeight.normal),
                        ),
                        SizedBox(width: 5.w),
                        Container(width: 30.w, height: 3.h, color: kSecondary),
                      ],
                    ),
                    SizedBox(height: 15.h),
                    const Divider(color: kGrayLight),
                    SizedBox(height: 10.h),
                    buildListTile("assets/profile_bw.png", "My Profile", () {
                      Get.to(() => ProfileDetailsScreen());
                    }),
                    // buildListTile("assets/about_us_bw.png", "About us",
                    //     () => Get.to(() => AboutUsScreen())),
                    buildListTile("assets/help_bw.png", "Customer Support",
                        () => Get.to(() => ContactDetailsScreen())),
                    // buildListTile("assets/t_c_bw.png", "Terms & Conditions",
                    //     () => Get.to(() => TermsAndConditionScreen())),
                    // buildListTile("assets/privacy_bw.png", "Privacy Policy",
                    //     () => Get.to(() => PrivacyPolicyScreen())),

                    buildListTile("assets/logout.png", "Log out", () {
                      showDialog<void>(
                        context: context,
                        builder: (BuildContext dialogContext) {
                          return AlertDialog(
                            title: Text("Logout"),
                            content: Text(
                                'Are you sure you want to log out from this account'),
                            actions: [
                              TextButton(
                                child: Text('Yes',
                                    style: appStyle(
                                        15, kSecondary, FontWeight.normal)),
                                onPressed: () {
                                  logoutUser(context);
                                },
                              ),
                              TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text("No",
                                      style: appStyle(
                                          15, kPrimary, FontWeight.normal)))
                            ],
                          );
                        },
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildListTile(String iconName, String title, void Function() onTap) {
    return GestureDetector(
      onTap: onTap,
      child: ListTile(
        leading:
            Image.asset(iconName, height: 20.h, width: 20.w, color: kPrimary),
        trailing: const Icon(Icons.arrow_forward_ios, size: 18, color: kGray),
        title: Text(title,
            style: kIsWeb
                ? TextStyle(color: kDark)
                : appStyle(13, kDark, FontWeight.normal)),
        // onTap: onTap,
      ),
    );
  }

  //================================ top Profile section =============================
  Container buildTopProfileSection() {
    return Container(
      height: kIsWeb ? 180.h : 120.h,
      width: double.maxFinite,
      padding: EdgeInsets.only(left: 12.w, right: 12.w, top: 12.w),
      decoration: BoxDecoration(
        color: kLightWhite,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Users')
            .doc(currentUId)
            .snapshots(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final profilePictureUrl = data['profilePicture'] ?? '';
          final userName = data['userName'] ?? '';
          final email = data['email'] ?? '';

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 33.r,
                backgroundColor: kSecondary,
                child: profilePictureUrl.isEmpty
                    ? Text(
                        userName.isNotEmpty ? userName[0] : '',
                        style: kIsWeb
                            ? TextStyle(color: kWhite)
                            : appStyle(20, kWhite, FontWeight.bold),
                      )
                    : CircleAvatar(
                        radius: 33.r,
                        backgroundImage: NetworkImage(profilePictureUrl),
                      ),
              ),
              SizedBox(width: 10.w),
              Padding(
                padding: EdgeInsets.only(top: 15.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName.isNotEmpty ? userName : '',
                      style: kIsWeb
                          ? TextStyle(color: kDark)
                          : appStyle(15, kDark, FontWeight.bold),
                    ),
                    Text(
                      email.isNotEmpty ? email : '',
                      style: kIsWeb
                          ? TextStyle(color: kDark)
                          : appStyle(12, kDark, FontWeight.normal),
                    ),
                  ],
                ),
              )
            ],
          );
        },
      ),
    );
  }

  Future<void> logoutUser(context) async {
    await auth.signOut().then((value) => {
          Get.offAll(() => const PhoneAuthenticationScreen(),
              transition: Transition.cupertino,
              duration: const Duration(milliseconds: 900))
        });
  }
}
