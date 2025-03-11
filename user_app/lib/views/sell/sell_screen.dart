import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:user_app/common/app_style.dart';
import 'package:user_app/common/custom_button.dart';
import 'package:user_app/constants/constants.dart';
import 'package:user_app/services/firebase_collections.dart';
import 'package:user_app/utils/shimmer_card_effect.dart';
import 'package:user_app/utils/shimmer_grid_effect.dart';
import 'package:user_app/utils/toast_msg.dart';
import 'package:user_app/views/sell/widgets/edit_your_book.dart';
import 'package:user_app/views/sell/widgets/sell_your_book.dart';

class SellScreen extends StatefulWidget {
  const SellScreen({Key? key}) : super(key: key);

  @override
  State<SellScreen> createState() => _SellScreenState();
}

class _SellScreenState extends State<SellScreen> {
  late CollectionReference<Map<String, dynamic>> booksCollection;

  @override
  void initState() {
    super.initState();
    booksCollection = FirebaseFirestore.instance.collection('Books');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 10.h),
          //==top section===
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(),
              CustomButton(
                text: "Add Book",
                onPress: () => Get.to(() => const SellYourBookWidget()),
                backgroundColor: kPrimary,
                width: 150,
                height: 40,
              )
            ],
          ),
          SizedBox(height: 10.h),
          //==ListView with cards==
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: booksCollection
                .where('userId', isEqualTo: currentUId)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const ShimmerCardEffectWidget();
              }

              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }

              return Expanded(
                child: ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var bookData = snapshot.data!.docs[index].data();

                    return Card(
                      margin:
                          EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                      child: Row(
                        children: [
                          Container(
                            width: 115.w,
                            height: 100.h,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: CachedNetworkImage(
                              imageUrl: bookData['frontImageUrl'],
                              fit: BoxFit.contain,
                              placeholder: (context, url) => Shimmer.fromColors(
                                baseColor: Colors.grey.shade300,
                                highlightColor: Colors.grey.shade100,
                                child: Container(
                                  width: 115.w,
                                  height: 100.h,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade300,
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.error, color: Colors.red),
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  bookData['bookName'],
                                  style: appStyle(17, kDark, FontWeight.normal),
                                ),
                                SizedBox(height: 10.h),
                                Row(
                                  children: [
                                    Text('MRP ',
                                        style: appStyle(
                                            14, kDark, FontWeight.normal)),
                                    Text(
                                      "₹${bookData['mrp']}",
                                      // Use book price from Firestore
                                      style:
                                          appStyle(14, kDark, FontWeight.bold)
                                              .copyWith(
                                                  decoration: TextDecoration
                                                      .lineThrough),
                                    ),
                                    SizedBox(width: 5.w),
                                    Text(
                                      '(50% off)',
                                      style: TextStyle(
                                          fontSize: 14.sp, color: kDark),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 5.h),
                                Row(
                                  children: [
                                    Text("Status: ",
                                        style: appStyle(
                                            14, kRed, FontWeight.w500)),
                                    Text(
                                      bookData['approved'] == true
                                          ? "Approved"
                                          : "Pending",
                                      style: appStyle(
                                          14, kPrimary, FontWeight.w500),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 5.h),
                                Text(
                                  bookData['description'],
                                  // Use book description from Firestore
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: appStyle(13, kDark, FontWeight.normal),
                                ),
                                SizedBox(height: 10.h),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    IconButton(
                                        onPressed: () {},
                                        icon: const Icon(Icons.block_outlined,
                                            color: kPrimary)),
                                    IconButton(
                                        onPressed: () {
                                          Get.to(() => EditYourBookScreen(
                                              bookId: bookData['bookDocId']));
                                        },
                                        icon: const Icon(Icons.edit,
                                            color: Colors.green)),
                                    IconButton(
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                title: const Text(
                                                    "Remove Your Book"),
                                                content: const Text(
                                                    "Are you sure you want to remove this book"),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () {
                                                      Get.back();
                                                    },
                                                    child: Text("Cancel",
                                                        style: appStyle(
                                                            17,
                                                            kRed,
                                                            FontWeight.normal)),
                                                  ),
                                                  TextButton(
                                                    onPressed: () {
                                                      deleteBook(bookData[
                                                          "bookDocId"]);
                                                      Navigator.pop(context);
                                                    },
                                                    child: Text("Remove",
                                                        style: appStyle(
                                                            17,
                                                            Colors.green,
                                                            FontWeight.normal)),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        },
                                        icon: const Icon(Icons.delete,
                                            color: kRed))
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          ),
          SizedBox(height: 60.h),
        ],
      ),
    );
  }

  void deleteBook(String docId) async {
    try {
      await booksCollection.doc(docId).delete();
      log("Book deleted successfully for docId: $docId");
      showToastMessage("Book Deleted", "Book Deleted Successfully", kRed);
    } catch (e) {
      log('Error deleting book: $e');
      showToastMessage("Error", "Something went wrong", kRed);
    }
  }
}
