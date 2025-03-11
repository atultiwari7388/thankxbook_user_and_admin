import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:library_admin/screens/superAdminHome/super_admin_home_screen.dart';
import '../services/firebase_services.dart';
import '../utils/toast_msg.dart';

class AuthenticationController extends GetxController {
  bool isLoading = false;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

//======================= Sign in With Email and Pass ==================================

  Future<void> loginWithEmailAndPassword() async {
    isLoading = true;
    update();

    try {
      final userCredential = await auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection("admin")
          .doc(userCredential.user!.uid)
          .get();

      if (snapshot.exists) {
        // User exists, navigate to Admin Home
        Get.off(() => const SuperAdminHomeScreen(),
            transition: Transition.leftToRightWithFade,
            duration: const Duration(seconds: 2));
        log("Login Successfully");
        showToastMessage("Success", "Login Successfully", Colors.green);
      } else {
        // Handle non-admin users or user not found
        showToastMessage("Error", "User not authorized", Colors.red);
      }
    } on FirebaseAuthException catch (authError) {
      log(authError.message ?? "Authentication error");
      showToastMessage(
          "Error", authError.message ?? "Authentication error", Colors.red);
    } catch (e) {
      log(e.toString());
      showToastMessage("Error", e.toString(), Colors.red);
    } finally {
      isLoading = false;
      update();
    }
  }

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
  }
}
