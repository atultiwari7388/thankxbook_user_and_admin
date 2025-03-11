import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:user_app/common/app_style.dart';
import 'package:user_app/common/custom_button.dart';
import 'package:user_app/constants/constants.dart';
import 'package:user_app/utils/toast_msg.dart';

class EditProfileScreen extends StatefulWidget {
  final String userId;
  final String currentEmail;
  final String currentUsername;
  final List<dynamic> currentAddress;
  final String? currentWhatsAppNumber;

  const EditProfileScreen({
    required this.userId,
    required this.currentEmail,
    required this.currentUsername,
    required this.currentAddress,
    required this.currentWhatsAppNumber,
  });

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  late List<TextEditingController> _addressControllers;
  final TextEditingController _whatsappController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _emailController.text = widget.currentEmail;
    _usernameController.text = widget.currentUsername;
    _addressControllers = List.generate(5, (index) => TextEditingController());
    for (int i = 0; i < widget.currentAddress.length; i++) {
      _addressControllers[i].text = widget.currentAddress[i];
    }
    _whatsappController.text = widget.currentWhatsAppNumber ?? "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text('Edit Profile', style: appStyle(20, kDark, FontWeight.normal)),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            SizedBox(height: 12.h),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            SizedBox(height: 12.h),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(
                _addressControllers.length,
                (index) {
                  return TextField(
                    controller: _addressControllers[index],
                    decoration:
                        InputDecoration(labelText: 'Address ${index + 1}'),
                  );
                },
              ),
            ),
            SizedBox(height: 12.h),
            TextField(
              controller: _whatsappController,
              decoration: const InputDecoration(labelText: 'WhatsApp Number'),
            ),
            SizedBox(height: 20.h),
            CustomButton(
                text: "Update",
                onPress: () => _updateProfile(context),
                backgroundColor: kPrimary)
          ],
        ),
      ),
    );
  }

  void _updateProfile(BuildContext context) async {
    String email = _emailController.text.trim();
    String username = _usernameController.text.trim();
    List<String> address = _addressControllers
        .map((controller) => controller.text.trim())
        .where((text) => text.isNotEmpty)
        .toList();
    String whatsappNumber = _whatsappController.text.trim();

    try {
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(widget.userId)
          .update({
        'email': email,
        'userName': username,
        'address': address,
        'whatsappNumber': whatsappNumber,
      });
      Navigator.of(context).pop();
    } catch (error) {
      // Handle error
      log('Error updating profile: $error');
      // Show error message to user
      showToastMessage(
          "Failed", "Failed to update Profile. Please try again", kRed);
      // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      //   content: Text('Failed to update profile. Please try again.'),
      // ));
    }
  }
}
