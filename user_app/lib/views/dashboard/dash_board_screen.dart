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
  final TabIndexController controller =
      Get.put(TabIndexController()); // ✅ Controller initialized once
  bool loading = false;

  @override
  void initState() {
    super.initState();
    checkUserAuthentication();
  }

  Future<void> checkUserAuthentication() async {
    setState(() {
      loading = true;
    });

    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;

    log("Checking user authentication...");

    await Future.delayed(const Duration(seconds: 2)); // Simulating an API call

    if (user == null) {
      log("User is not authenticated. Navigating to OnboardingScreen.");
      Get.offAll(() => const PhoneAuthenticationScreen());
    } else {
      log("User is authenticated. UID: ${user.uid}");
    }

    setState(() {
      loading = false;
    });
  }

  final List<Widget> screens = const [
    HomeScreen(),
    SellScreen(),
    WishlistScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ReusableText(
          text: appName,
          style: appStyle(20, kPrimary, FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Obx(() =>
              screens[controller.getTabIndex]), // ✅ Wrap only the body in Obx
      bottomNavigationBar: Obx(() => BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            elevation: 0,
            showSelectedLabels: true,
            showUnselectedLabels: true,
            unselectedIconTheme: const IconThemeData(color: kGray),
            selectedItemColor: kPrimary,
            unselectedItemColor: kGray,
            selectedIconTheme: const IconThemeData(color: kPrimary),
            selectedLabelStyle: appStyle(12, kPrimaryLight, FontWeight.bold),
            onTap: (value) {
              controller.setTabIndex = value; // ✅ Updates Rx variable
            },
            currentIndex: controller.getTabIndex, // ✅ Observable usage
            items: const [
              BottomNavigationBarItem(
                  icon: Icon(AntDesign.home), label: "Home"),
              BottomNavigationBarItem(
                  icon: Icon(AntDesign.book), label: "Sell"),
              BottomNavigationBarItem(
                  icon: Icon(AntDesign.heart), label: "Wishlist"),
              BottomNavigationBarItem(
                  icon: Icon(AntDesign.user), label: "Profile"),
            ],
          )),
    );
  }
}
