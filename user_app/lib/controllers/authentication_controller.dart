import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:user_app/views/auth/complete_your_profile.dart';
import 'package:user_app/views/dashboard/dash_board_screen.dart';
import '../utils/toast_msg.dart';
import '../views/auth/phone_authentication_screen.dart';

class AuthenticationController extends GetxController {
  //create firebase instance
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore fire = FirebaseFirestore.instance;
  final TextEditingController phoneController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final TextEditingController otpController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  String vId = "";
  bool isLoading = false;
  bool isVerification = false;

  //================ check for state auth changes  ================
  Stream<User?> get authChanges => _auth.authStateChanges();

  //================ all the users data ================
  User get user => _auth.currentUser!;

//================ Verify Phone Number =======================================

  Future<void> verifyPhoneNumber() async {
    try {
      isLoading = true;
      update();
      await _auth.verifyPhoneNumber(
        phoneNumber: "+91${phoneController.text.toString()}",
        verificationCompleted:
            (PhoneAuthCredential phoneAuthCredential) async {},
        verificationFailed: (FirebaseAuthException exception) {
          log(exception.toString());
         },
        codeSent: (String verificationId, int? resendCode) {
          isLoading = false;
          update();
          vId = verificationId;
        },
        codeAutoRetrievalTimeout: (String e) {
          log(e.toString());
        },
        timeout: const Duration(seconds: 120),
      );
    } catch (e) {
      isLoading = false;
      update();
      log(e.toString());
      showToastMessage("Error", e.toString(), Colors.red);
    }
  }

  //================================= New Code ====================================

  void signInWithPhoneNumber(BuildContext context, String otp) async {
    isVerification = true;
    update();
    final PhoneAuthCredential phoneAuthCredential =
    PhoneAuthProvider.credential(
      verificationId: vId,
      smsCode: otp,
    );
    try {
      //for signIn with credential
      var signInUser = await _auth.signInWithCredential(phoneAuthCredential);

      print(signInUser);

      final User? user = signInUser.user;
      if (user != null) {
        isVerification = false;
        update();
        if (signInUser.additionalUserInfo!.isNewUser) {
          //add the data to firebase or move to complete your profile screen
          Get.offAll(() => const CompleteYourProfileScreen(),
              transition: Transition.leftToRightWithFade,
              duration: const Duration(seconds: 2));
        } else {
          final doc =
          await FirebaseFirestore.instance.doc("Users/${user.uid}").get();
          if (doc.exists) {
            if (doc["uid"] == _auth.currentUser!.uid &&
                doc["phoneNumber"] == _auth.currentUser!.phoneNumber) {
              Get.offAll(() => DashBoardScreen());
            } else {
              Get.offAll(() => const PhoneAuthenticationScreen());
            }
          } else {
            Get.offAll(() => const PhoneAuthenticationScreen());
          }
        }
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-verification-code') {
        isVerification = false;
        update();
        showToastMessage(
            "Error", "Invalid OTP. Enter correct OTP.", Colors.red);
        await _auth.signOut().then((value) {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (_) => const PhoneAuthenticationScreen()),
                  (route) => false);
        });
      }
    }
  }
  //====================== signOut from app =====================
  void signOut(BuildContext context) async {
    try {
      if (kIsWeb) {
        _auth.signOut().then((value) {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (_) => const PhoneAuthenticationScreen()),
                  (route) => false);
        });
      } else {
        await _auth.signOut().then((value) {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (_) => const PhoneAuthenticationScreen()),
                  (route) => false);
        });
      }
    } catch (e) {
      showToastMessage("Error", e.toString(), Colors.red);
    }
  }
}
