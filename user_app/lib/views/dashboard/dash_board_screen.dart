import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:get/get.dart';
import 'package:user_app/common/reusable_text.dart';
import 'package:user_app/views/auth/phone_authentication_screen.dart';
import 'package:user_app/views/sell/sell_screen.dart';
import 'package:user_app/views/wishlist/wish_list_screen.dart';
import '../../common/app_style.dart';
import '../../constants/constants.dart';
import '../../controllers/tab_index_controller.dart';
import '../home/home_screen.dart';
import '../profile/profile_screen.dart';

class DashBoardScreen extends StatefulWidget {
  const DashBoardScreen({super.key});

  @override
  State<DashBoardScreen> createState() => _DashBoardScreenState();
}

class _DashBoardScreenState extends State<DashBoardScreen> {
  bool loading = false;

  @override
  void initState() {
    super.initState();
    checkUserAuthentication();
  }

  Future<void> checkUserAuthentication() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;

    log("Checking user authentication...");

    // Simulating an asynchronous operation (e.g., fetching user data) with a delay
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      loading = true;
    });

    if (user == null) {
      // If user is not authenticated, navigate to OnboardScreen
      log("User is not authenticated. Navigating to OnboardingScreen.");

      Get.offAll(() => const PhoneAuthenticationScreen());
    } else {
      // If user is authenticated, you can perform additional actions if needed
      log("User is authenticated. UID: ${user.uid}");

      setState(() {
        loading = false;
      });
    }

    log("Check user authentication completed.");

    setState(() {
      loading = false;
    });
  }

  List<Widget> screens = const [
    HomeScreen(),
    SellScreen(),
    WishlistScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TabIndexController());
    return Obx(
      () => Scaffold(
        appBar: AppBar(
          title: ReusableText(
              text: appName, style: appStyle(20, kPrimary, FontWeight.w500)),
          centerTitle: true,
        ),
        body: loading
            ? const Center(child: CircularProgressIndicator())
            : Stack(
                children: [
                  screens[controller.getTabIndex],
                  Align(
                    alignment: Alignment.bottomCenter,
                    // child: Theme(
                    // data: Theme.of(context).copyWith(canvasColor: kPrimary),
                    child: BottomNavigationBar(
                      type: BottomNavigationBarType.fixed,
                      elevation: 0,
                      showSelectedLabels: true,
                      showUnselectedLabels: true,
                      unselectedIconTheme: const IconThemeData(color: kGray),
                      selectedItemColor: kPrimary,
                      unselectedItemColor: kGray,
                      selectedIconTheme: const IconThemeData(color: kPrimary),
                      selectedLabelStyle:
                          appStyle(12, kPrimaryLight, FontWeight.bold),
                      onTap: (value) {
                        controller.setTabIndex = value;
                      },
                      currentIndex: controller.getTabIndex,
                      items: const [
                        BottomNavigationBarItem(
                            icon: Icon(AntDesign.home), label: "Home"),
                        BottomNavigationBarItem(
                            icon: Icon(AntDesign.book), label: "Sell"),
                        BottomNavigationBarItem(
                            icon: Icon(AntDesign.heart), label: "Wishlist "),
                        BottomNavigationBarItem(
                            icon: Icon(AntDesign.user), label: "Profile"),
                      ],
                    ),
                  ),
                  // ),
                ],
              ),
      ),
    );
  }
}
