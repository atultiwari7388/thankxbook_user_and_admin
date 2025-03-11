import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:user_app/common/custom_button.dart';
import 'package:user_app/common/custom_heading.dart';
import 'package:user_app/services/firebase_collections.dart';
import 'package:user_app/utils/toast_msg.dart';
import 'package:user_app/utils/word_limit_formatter.dart';

class EditYourBookScreen extends StatefulWidget {
  final String bookId;

  const EditYourBookScreen({Key? key, required this.bookId}) : super(key: key);

  @override
  _EditYourBookScreenState createState() => _EditYourBookScreenState();
}

class _EditYourBookScreenState extends State<EditYourBookScreen> {
  final TextEditingController _bookNameController = TextEditingController();
  final TextEditingController _sellingPriceController = TextEditingController();
  final TextEditingController _mrpController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool isLoading = false;
  List<String> addresses = [];
  String? _selectedAddress;

  String? _frontImageUrl; // Holds default front image URL
  XFile? _newFrontImage; // Holds new front image if user selects one
  List<String> _otherImageUrls = []; // Holds default other image URLs
  List<XFile> _newOtherImages = []; // Holds new selected other images
  final ImagePicker _picker = ImagePicker();
  List<String> _removedOtherImages = [];

  @override
  void initState() {
    super.initState();
    _fetchBookDetails();
    fetchAddresses();
  }

  Future<void> fetchAddresses() async {
    try {
      setState(() {
        isLoading = true;
      });

      final userDataSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(currentUId) // Replace with actual user ID
          .get();
      final userData = userDataSnapshot.data();

      if (userData != null && userData['address'] is List) {
        addresses = List<String>.from(userData['address']);
      }
    } catch (error) {
      log('Error fetching addresses: $error');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _fetchBookDetails() async {
    try {
      DocumentSnapshot bookSnapshot = await FirebaseFirestore.instance
          .collection('Books')
          .doc(widget.bookId)
          .get();

      if (bookSnapshot.exists) {
        var data = bookSnapshot.data() as Map<String, dynamic>;

        setState(() {
          _bookNameController.text = data['bookName'];
          _sellingPriceController.text = data['sellingPrice'].toString();
          _mrpController.text = data['mrp'].toString();
          _descriptionController.text = data['description'];
          _selectedAddress = data['address'];

          _frontImageUrl = data['frontImageUrl'];

          if (data['otherImageUrls'] != null &&
              data['otherImageUrls'] is List) {
            _otherImageUrls = List<String>.from(data['otherImageUrls']);
          }
        });
      }
    } catch (e) {
      log("Error fetching book details: $e");
    }
  }

  Future<void> _selectImage(bool isFrontImage) async {
    try {
      final XFile? pickedFile =
          await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          if (isFrontImage) {
            _newFrontImage = pickedFile;
          } else {
            // Clear previous images and add the new one
            _newOtherImages.clear(); // Clear previous selections
            _newOtherImages.add(pickedFile); // Add the new selected image
          }
        });
      }
    } catch (e) {
      log('Error picking image: $e');
    }
  }

  // Future<void> _updateBook() async {
  //   setState(() {
  //     isLoading = true;
  //   });
  //   try {
  //     String? newFrontImageUrl;
  //     List<String> newOtherImageUrls = [];

  //     // Upload new front image if changed
  //     if (_newFrontImage != null) {
  //       newFrontImageUrl = await uploadImageToFirebase(_newFrontImage!);
  //     } else {
  //       newFrontImageUrl = _frontImageUrl;
  //     }

  //     for (var file in _newOtherImages) {
  //       String imageUrl = await uploadImageToFirebase(file);
  //       if (!_otherImageUrls.contains(imageUrl)) {
  //         newOtherImageUrls.add(imageUrl);
  //       }
  //     }

  //     // Add previous image URLs if not replaced
  //     newOtherImageUrls.addAll(_otherImageUrls);

  //     await FirebaseFirestore.instance
  //         .collection('Books')
  //         .doc(widget.bookId)
  //         .update({
  //       'bookName': _bookNameController.text,
  //       'sellingPrice': _sellingPriceController.text.toString(),
  //       'mrp': _mrpController.text.toString(),
  //       'description': _descriptionController.text,
  //       'address': _selectedAddress,
  //       "approved": false,
  //       'frontImageUrl': newFrontImageUrl,
  //       'otherImageUrls': newOtherImageUrls,
  //       'updated_at': DateTime.now(),
  //     });
  //     setState(() {
  //       isLoading = false;
  //     });

  //     Navigator.pop(context);
  //   } catch (e) {
  //     log("Error updating book: $e");
  //   } finally {
  //     setState(() {
  //       isLoading = false;
  //     });
  //   }
  // }

  // Future<String> uploadImageToFirebase(XFile file) async {
  //   Reference ref = FirebaseStorage.instance
  //       .ref()
  //       .child('book_images/${DateTime.now().millisecondsSinceEpoch}.jpg');
  //   await ref.putFile(File(file.path));
  //   return await ref.getDownloadURL();
  // }

  Future<void> _updateBook() async {
    setState(() {
      isLoading = true;
    });

    try {
      String updatedFrontImageUrl =
          _frontImageUrl!; // Default to existing image
      List<String> updatedOtherImageUrls = [];

      // Upload new front image if selected
      if (_newFrontImage != null) {
        updatedFrontImageUrl = await uploadImageToFirebase(_newFrontImage!);
      }

      // Upload new other images
      for (var file in _newOtherImages) {
        String imageUrl = await uploadImageToFirebase(file);
        updatedOtherImageUrls.add(imageUrl);
      }

      // Retain only the images that were not replaced
      updatedOtherImageUrls.addAll(
          _otherImageUrls.where((url) => !_removedOtherImages.contains(url)));

      await FirebaseFirestore.instance
          .collection('Books')
          .doc(widget.bookId)
          .update({
        'bookName': _bookNameController.text.trim(),
        'sellingPrice': _sellingPriceController.text.trim(),
        'mrp': _mrpController.text.trim(),
        'description': _descriptionController.text.trim(),
        'address': _selectedAddress,
        "approved": false,
        'frontImageUrl': updatedFrontImageUrl,
        'otherImageUrls': updatedOtherImageUrls,
        'updated_at': FieldValue.serverTimestamp(),
      });

      showToastMessage("Success", "Your book has been updated", Colors.green);
      Navigator.pop(context);
    } catch (e) {
      log("Error updating book: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<String> uploadImageToFirebase(XFile file) async {
    Reference ref = FirebaseStorage.instance
        .ref()
        .child('book_images/${DateTime.now().millisecondsSinceEpoch}.jpg');
    await ref.putFile(File(file.path));
    return await ref.getDownloadURL();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Book')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                children: [
                  const CustomHeadingWidget(
                      heading: "Book Name (Max 70 words)"),
                  customTextFieldSection(_bookNameController,
                      maxLines: 1, maxWords: 70),
                  const SizedBox(height: 20),
                  const CustomHeadingWidget(heading: "Selling Price"),
                  customTextFieldSection(_sellingPriceController,
                      maxLines: 1, maxWords: 5),
                  const SizedBox(height: 20),
                  const CustomHeadingWidget(heading: "MRP"),
                  customTextFieldSection(_mrpController,
                      maxLines: 1, maxWords: 5),
                  const SizedBox(height: 20),
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
                  const SizedBox(height: 20),
                  const CustomHeadingWidget(
                      heading: "Description (Max 150 words)"),
                  customTextFieldSection(_descriptionController,
                      maxLines: 4, maxWords: 150),
                  const SizedBox(height: 20),
                  const CustomHeadingWidget(
                      heading: "Upload Book Photos (Max 8 photos)"),
                  const SizedBox(height: 20),

                  // Front Image
                  GestureDetector(
                    onTap: () {
                      _selectImage(true); // Select front image
                    },
                    child: Column(
                      children: [
                        _newFrontImage != null
                            ? Image.file(File(_newFrontImage!.path),
                                height: 100, width: 100, fit: BoxFit.cover)
                            : (_frontImageUrl != null
                                ? Image.network(_frontImageUrl!,
                                    height: 100, width: 100, fit: BoxFit.cover)
                                : Image.asset("assets/upload.png",
                                    height: 100, width: 100)),
                        const SizedBox(height: 5),
                        const Text("Front Image")
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Other Images
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        // Show selected images first
                        ..._newOtherImages.map((image) => GestureDetector(
                              onTap: () {
                                _selectImage(false);
                              },
                              child: Image.file(File(image.path),
                                  height: 100, width: 100, fit: BoxFit.cover),
                            )),
                        // Show default network images only if no new images are selected
                        if (_newOtherImages.isEmpty)
                          ..._otherImageUrls.map((imageUrl) => GestureDetector(
                                onTap: () {
                                  _selectImage(false);
                                },
                                child: Image.network(imageUrl,
                                    height: 100, width: 100, fit: BoxFit.cover),
                              )),
                        // Show upload button if total images are less than 8
                        if (_newOtherImages.length + _otherImageUrls.length < 8)
                          GestureDetector(
                            onTap: () {
                              _selectImage(false);
                            },
                            child: Image.asset("assets/upload.png",
                                height: 100, width: 100),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  CustomButton(
                      text: "Publish",
                      onPress: () => {
                            showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                      title: const Text('Confirm'),
                                      content: const Text(
                                          'Are you sure you want to update the book?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                            _updateBook();
                                          },
                                          child: const Text('Confirm'),
                                        )
                                      ],
                                    ))
                          },
                      backgroundColor: Colors.blue)
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
