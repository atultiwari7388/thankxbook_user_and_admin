import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SellYourBookController extends GetxController {
  final TextEditingController bookNameController = TextEditingController();
  final TextEditingController sellingPriceController = TextEditingController();
  final TextEditingController mrpController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  bool isUploading = false;


}
