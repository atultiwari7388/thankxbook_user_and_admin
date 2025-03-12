import 'dart:developer';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:user_app/services/firebase_collections.dart';
import 'package:user_app/utils/toast_msg.dart';
import 'package:user_app/utils/word_limit_formatter.dart';
import '../../../common/app_style.dart';
import '../../../common/custom_button.dart';
import '../../../common/custom_heading.dart';
import '../../../constants/constants.dart';

class SellYourBookWidget extends StatefulWidget {
  const SellYourBookWidget({Key? key}) : super(key: key);

  @override
  State<SellYourBookWidget> createState() => _SellYourBookWidgetState();
}

class _SellYourBookWidgetState extends State<SellYourBookWidget> {
  final TextEditingController _bookNameController = TextEditingController();
  final TextEditingController _sellingPriceController = TextEditingController();
  final TextEditingController _mrpController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  bool isLoading = false;
  List<String> addresses = [];
  String? _selectedAddress;
  List<XFile> _frontImages = [];
  final List<XFile> _otherImages = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    fetchAddresses();
  }

  Future<void> fetchAddresses() async {
    try {
      setState(() {
        isLoading = true;
      });

      if (user != null) {
        final userDataSnapshot = await FirebaseFirestore.instance
            .collection('Users')
            .doc(currentUId)
            .get();
        final userData = userDataSnapshot.data();
        if (userData != null && userData['address'] is List) {
          final List<dynamic> addressesData =
              userData['address'] as List<dynamic>;
          final List<String> fetchedAddresses =
              addressesData.map((address) => address.toString()).toList();
          log(fetchedAddresses.toList().toString());
          setState(() {
            addresses = fetchedAddresses;
            _selectedAddress = addresses.isNotEmpty ? addresses.first : null;
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
          });
          log('Address data not found or is not a list');
        }
      } else {
        setState(() {
          isLoading = false;
        });
        log('Current user not found');
      }
    } catch (error) {
      log('Error fetching addresses: $error');
    }
  }

//========================= Select Image ====================
  Future<void> _selectImage(bool isFrontImage) async {
    try {
      final XFile? pickedFile =
          await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          if (isFrontImage) {
            _frontImages = [pickedFile];
          } else {
            _otherImages.add(pickedFile);
          }
        });
      }
    } catch (e) {
      log('Error picking image: $e');
    }
  }

  Future<void> _uploadBook() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        log('User not authenticated');
        return;
      }

      final String userId = user.uid;
      final DateTime now = DateTime.now();

      setState(() {
        isLoading = true; // Show loading indicator
      });

      // ✅ Upload front image with metadata
      final frontImageFile = File(_frontImages.first.path);
      final frontImageName = 'front_${now.microsecondsSinceEpoch}.jpg';
      final Reference frontStorageRef = FirebaseStorage.instance
          .ref()
          .child('book_images')
          .child(userId)
          .child(frontImageName);

      await frontStorageRef.putFile(
        frontImageFile,
        SettableMetadata(contentType: "image/jpeg"), // ✅ Add metadata
      );

      final String frontImageUrl = await frontStorageRef.getDownloadURL();

      // ✅ Upload other images with metadata
      List<String> otherImageUrls = [];
      for (int i = 0; i < _otherImages.length; i++) {
        final otherImageFile = File(_otherImages[i].path);
        final otherImageName = 'other_${now.microsecondsSinceEpoch}_$i.jpg';
        final Reference otherStorageRef = FirebaseStorage.instance
            .ref()
            .child('book_images')
            .child(userId)
            .child(otherImageName);

        await otherStorageRef.putFile(
          otherImageFile,
          SettableMetadata(contentType: "image/jpeg"), // ✅ Add metadata
        );

        final String otherImageUrl = await otherStorageRef.getDownloadURL();
        otherImageUrls.add(otherImageUrl);
      }

      // ✅ Store book details in Firestore
      final DocumentReference bookDocRef = FirebaseFirestore.instance
          .collection('Books')
          .doc(); // Get a reference without an ID
      final bookDocId = bookDocRef.id; // Get the auto-generated ID

      final bookData = {
        'userId': userId,
        'bookName': _bookNameController.text.toString(),
        'sellingPrice': _sellingPriceController.text.toString(),
        'mrp': _mrpController.text.toString(),
        'description': _descriptionController.text.toString(),
        'frontImageUrl': frontImageUrl,
        'otherImageUrls': otherImageUrls,
        'address': _selectedAddress,
        "enabled": false,
        "approved": false,
        "soldOut": false,
        'createdAt': FieldValue.serverTimestamp(),
        'bookDocId': bookDocId,
      };

      await bookDocRef.set(bookData);

      // ✅ Store book document ID in user's collection
      await FirebaseFirestore.instance.collection('Users').doc(userId).update({
        'uploadedBooks': FieldValue.arrayUnion([bookDocRef.id]),
      });

      _bookNameController.clear();
      _sellingPriceController.clear();
      _mrpController.clear();
      _descriptionController.clear();
      setState(() {
        _frontImages.clear();
        _otherImages.clear();
        isLoading = false; // Hide loading indicator
      });

      showToastMessage(
          "Success", "Your Book uploaded successfully", Colors.green);
      _showUploadConfirmationPopup();
      log('Book uploaded successfully');
    } catch (error) {
      setState(() {
        isLoading = false; // Hide loading indicator
      });
      log('Error uploading book: $error');
    }
  }

  void _showUploadConfirmationPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Book Uploaded"),
          content: const Text("Your ad will be live within 24 hours."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close popup
                Navigator.of(context).pop(); // Close popup
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sell Your Book"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                children: [
                  const CustomHeadingWidget(
                      heading: "Book Name (Max 70 words)"),
                  SizedBox(height: 5.h),
                  customTextFieldSection(_bookNameController,
                      maxLines: 1, maxWords: 70),
                  SizedBox(height: 20.h),
                  const CustomHeadingWidget(heading: "Selling Price"),
                  customTextFieldSection(_sellingPriceController,
                      maxLines: 1, maxWords: 5),
                  SizedBox(height: 20.h),
                  const CustomHeadingWidget(heading: "MRP"),
                  customTextFieldSection(_mrpController,
                      maxLines: 1, maxWords: 5),
                  SizedBox(height: 20.h),
                  const CustomHeadingWidget(heading: "Pick Address"),
                  DropdownButtonFormField<String>(
                    value: _selectedAddress,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedAddress = newValue;
                      });
                    },
                    items: addresses.map((String address) {
                      return DropdownMenuItem<String>(
                        value: address,
                        child: Text(address),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 20.h),
                  const CustomHeadingWidget(
                      heading: "Description (Max 150 words)"),
                  customTextFieldSection(_descriptionController,
                      maxLines: 4, maxWords: 150),
                  SizedBox(height: 20.h),
                  SizedBox(height: 20.h),
                  const CustomHeadingWidget(
                      heading: "Upload Book Photos (Max 8 photos)"),
                  SizedBox(height: 20.h),
                  Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          _selectImage(true); // Select front image
                        },
                        child: Column(
                          children: [
                            _frontImages.isEmpty
                                ? Image.asset("assets/upload.png",
                                    height: 45.h, width: 45.w)
                                : Image.file(File(_frontImages.first.path),
                                    height: 45.h, width: 45.w),
                            SizedBox(height: 5.h),
                            Text("Front Image",
                                style: appStyle(14, kGray, FontWeight.normal))
                          ],
                        ),
                      ),
                      SizedBox(height: 20.h),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            if (_otherImages
                                .isEmpty) // Check if other images list is empty
                              GestureDetector(
                                onTap: () {
                                  // Select other images
                                  _selectImage(false);
                                },
                                child: Column(
                                  children: [
                                    Image.asset("assets/upload.png",
                                        height: 45.h, width: 45.w),
                                    SizedBox(height: 5.h),
                                    Text("Other Image",
                                        style: appStyle(
                                            14, kGray, FontWeight.normal))
                                  ],
                                ),
                              ),
                            ..._otherImages.map((image) => GestureDetector(
                                  onTap: () {
                                    // Select other images
                                    _selectImage(false);
                                  },
                                  child: Column(
                                    children: [
                                      Image.file(File(image.path),
                                          height: 45.h, width: 45.w),
                                      SizedBox(height: 5.h),
                                      Text("Other Image",
                                          style: appStyle(
                                              14, kGray, FontWeight.normal))
                                    ],
                                  ),
                                )),
                            if (_otherImages.length < 8) // Maximum 8 photos
                              GestureDetector(
                                onTap: () {
                                  // Select other images
                                  _selectImage(false);
                                },
                                child: Column(
                                  children: [
                                    Image.asset("assets/upload.png",
                                        height: 45.h, width: 45.w),
                                    SizedBox(height: 5.h),
                                    Text("Other Image",
                                        style: appStyle(
                                            14, kGray, FontWeight.normal))
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 30.h),
                  CustomButton(
                      text: "Publish",
                      onPress: () => _uploadBook(),
                      backgroundColor: kPrimary)
                ],
              ),
      ),
    );
  }

  Container customTextFieldSection(TextEditingController controller,
      {int maxLines = 1, int maxWords = 70}) {
    return Container(
      padding: const EdgeInsets.all(5.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: TextField(
        controller: controller,
        decoration: const InputDecoration(border: InputBorder.none),
        maxLines: maxLines,
        inputFormatters: [
          WordLimitFormatter(maxWords: maxWords)
        ], // Apply word limit
      ),
    );
  }
}
