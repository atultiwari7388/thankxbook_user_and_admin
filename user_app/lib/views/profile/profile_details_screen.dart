import 'dart:developer';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:user_app/common/app_style.dart';
import 'package:user_app/common/custom_button.dart';
import 'package:user_app/constants/constants.dart';
import 'package:user_app/services/firebase_collections.dart';
import 'package:user_app/views/profile/edit_your_profile_screen.dart';
import '../../models/user_models.dart';
import '../../utils/toast_msg.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class ProfileDetailsScreen extends StatefulWidget {
  const ProfileDetailsScreen({Key? key}) : super(key: key);

  @override
  State<ProfileDetailsScreen> createState() => _ProfileDetailsScreenState();
}

class _ProfileDetailsScreenState extends State<ProfileDetailsScreen> {
  final FirebaseFirestore fire = FirebaseFirestore.instance;

  final imagePicker = ImagePicker();
  XFile? _image;
  bool _loading = false;

  bool get loading => _loading;

  setLoading(bool value) {
    _loading = value;
    setState(() {});
  }

  late String? profilePictureI;

  //pick image from gallery
  void pickImageFromGallery(BuildContext context) async {
    final pickedFile = await imagePicker.pickImage(
        source: ImageSource.gallery, imageQuality: 100);

    if (pickedFile != null) {
      _image = XFile(pickedFile.path);
      // ignore: use_build_context_synchronously
      uploadImage(context);
      setState(() {});
    }
  }

  //pick image from camera
  void pickImageFromCamera(BuildContext context) async {
    final pickedFile = await imagePicker.pickImage(
        source: ImageSource.camera, imageQuality: 100);

    if (pickedFile != null) {
      _image = XFile(pickedFile.path);
      // ignore: use_build_context_synchronously
      uploadImage(context);
      setState(() {});
    }
  }

  void pickProfileImage(context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SizedBox(
            height: 120.h,
            child: Column(
              children: [
                ListTile(
                  onTap: () {
                    pickImageFromCamera(context);
                    Navigator.pop(context);
                    setState(() {});
                  },
                  leading: const Icon(Icons.camera, color: Colors.blue),
                  title: const Text("Camera"),
                ),
                ListTile(
                  onTap: () {
                    pickImageFromGallery(context);
                    Navigator.pop(context);
                    setState(() {});
                  },
                  leading: const Icon(Icons.image, color: Colors.blue),
                  title: const Text("Gallery"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Modify the uploadImage function to save the image as JPEG
  void uploadImage(BuildContext context) async {
    setLoading(true);

    // Save the image as JPEG
    File jpegImage = File(_image!.path);
    List<int> imageBytes = await jpegImage.readAsBytes();
    String fileName =
        "profile_picture_${DateTime.now().millisecondsSinceEpoch}.jpg";
    String imagePath = '${(await getTemporaryDirectory()).path}/$fileName';
    await File(imagePath).writeAsBytes(imageBytes);

    // Store user image as a JPEG to Firebase Storage
    firebase_storage.Reference storageRef = firebase_storage
        .FirebaseStorage.instance
        .ref("/profile${auth.currentUser!.uid}/$fileName");
    firebase_storage.UploadTask uploadTask =
        storageRef.putFile(File(imagePath));

    // Upload image
    firebase_storage.TaskSnapshot taskSnapshot = await uploadTask;

    // Get uploaded image path
    final newUrl = await taskSnapshot.ref.getDownloadURL();

    // Upload image path to Firestore
    await fire.doc('Users/${auth.currentUser!.uid}').update({
      "profilePicture": newUrl.toString(),
    }).then((value) {
      log("Profile updated");
      setState(() {
        profilePictureI = newUrl.toString();
        _image = null;
      });
      setLoading(false);
      showToastMessage("Success", "Profile picture updated", Colors.green);
    }).catchError((error) {
      setLoading(false);
      showToastMessage("Error", "Profile picture update failed", Colors.red);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile Details Screen"),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Users')
            .doc(currentUId)
            .snapshots(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.data() == null) {
            return const Center(child: Text('No data found'));
          }

          Map<String, dynamic> data =
              snapshot.data!.data() as Map<String, dynamic>;
          UserProfile user = UserProfile(
            name: data['userName'],
            email: data['email'],
            imageUrl: data['profilePicture'],
            whatsAppNumber: data["whatsAppNumber"],
            currentAddress: data["address"],
          );

          profilePictureI = data["profilePicture"];

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () {
                        pickProfileImage(context);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(width: 3),
                          shape: BoxShape.circle,
                        ),
                        child: _image == null
                            ? profilePictureI == ""
                                ? ClipOval(
                                    child: CachedNetworkImage(
                                      height: 80.h,
                                      width: 80.w,
                                      imageUrl:
                                          "https://firebasestorage.googleapis.com/v0/b/pik-dop-taxi-service-app.appspot.com/o/parcel.png?alt=media&token=3d550118-0c01-4714-b9c2-cfb9bf06fbcd",
                                      placeholder: (context, url) =>
                                          const CircularProgressIndicator(),
                                      errorWidget: (context, url, error) =>
                                          const Icon(Icons.error),
                                    ),
                                  )
                                : ClipOval(
                                    child: CachedNetworkImage(
                                      fit: BoxFit.cover,
                                      height: 80.h,
                                      width: 80.w,
                                      imageUrl: profilePictureI!,
                                      placeholder: (context, url) =>
                                          const CircularProgressIndicator(),
                                      errorWidget: (context, url, error) =>
                                          const Icon(Icons.error),
                                    ),
                                  )
                            : ClipOval(
                                child: Image.file(
                                  File(_image!.path).absolute,
                                  height: 80.h,
                                  width: 80.w,
                                ),
                              ),
                      ),
                    ),
                    SizedBox(width: 15.w),
                  ],
                ),
                SizedBox(height: 20.h),
                Text(
                  user.name,
                  style: appStyle(16, kDark, FontWeight.normal),
                ),
                SizedBox(height: 5.h),
                Text(
                  user.email,
                  style: appStyle(14, kDark, FontWeight.normal),
                ),
                SizedBox(height: 20.h),
                CustomButton(
                  text: "Edit ",
                  onPress: () {
                    Get.to(
                      () => EditProfileScreen(
                        userId: currentUId,
                        currentEmail: user.email,
                        currentUsername: user.name,
                        currentAddress: user.currentAddress,
                        currentWhatsAppNumber: user.whatsAppNumber,
                      ),
                    );
                  },
                  backgroundColor: kPrimary,
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
