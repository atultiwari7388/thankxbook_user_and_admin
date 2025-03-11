import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:user_app/services/firebase_collections.dart';
import 'package:user_app/services/firebase_services.dart';
import 'package:user_app/utils/toast_msg.dart';
import 'package:user_app/views/dashboard/dash_board_screen.dart';

class CompleteYourProfileController extends GetxController {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController whatsAppNumberController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  List<String> addressList = [];
  bool isLoading = false;

  void addAddress(String address) {
    addressList.add(address);
    update(); // Update the UI after adding the address
  }

  void updateUserDetails() async {
    isLoading = true;
    update();
    try {
      await DatabaseServices(uid: currentUId.toString())
          .savingUserData(
              emailController.text.toString(),
              nameController.text.toString(),
              auth.currentUser!.phoneNumber!,
              "",
              whatsAppNumberController.text.toString(),
              addressList)
          .then((value) {
        isLoading = false;
        update();
        showToastMessage("Success", "Account Created", Colors.green);
        Get.offAll(() => DashBoardScreen());
      }).onError((error, stackTrace) {
        isLoading = false;
        update();
        showToastMessage("Error", error.toString(), Colors.red);
      });
    } catch (e) {
      isLoading = false;
      update();
      showToastMessage("Error", e.toString(), Colors.red);
      log(e.toString());
    }
  }
}
