import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:user_app/functions/remove_book_from_wishlist.dart';
import 'package:user_app/services/firebase_collections.dart';
import '../../common/app_style.dart';
import '../../constants/constants.dart';
import '../home/widgets/book_details_screen.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({Key? key}) : super(key: key);

  @override
  _WishlistScreenState createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  late ScrollController _scrollController;
  late int _limit;
  late bool _hasMore;

  @override
  void initState() {
    super.initState();
    _limit = 10;
    _hasMore = true;
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      setState(() {
        _limit += 10; // Increase the limit to load more items
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('Wishlist')
            .where("userId", isEqualTo: currentUId)
            .limit(_limit)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            log("Waiting for connection");
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData) {
            log("Book not found");
            return const Center(child: Text('Book Not Found'));
          }
          final wishlistData = snapshot.data!.docs;
          if (wishlistData.length < _limit) {
            _hasMore = false;
          }
          log("Wishlist data: $wishlistData");
          return wishlistData.isEmpty
              ? Center(
                  child: Text("Wishlist is empty",
                      style: appStyle(16, kDark, FontWeight.normal)))
              : buildBodyComponent(wishlistData);
        },
      ),
    );
  }

  Widget buildBodyComponent(dynamic wishlistData) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      margin: EdgeInsets.only(bottom: 60.h),
      child: ListView.builder(
        controller: _scrollController,
        itemCount: wishlistData.length,
        itemBuilder: (context, index) {
          final String bookId = wishlistData[index]['bookId'];
          final String wishlistId = wishlistData[index].id;
          log("Book Id $bookId");
          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('Books')
                .doc(bookId)
                .get(),
            builder: (context, bookSnapshot) {
              if (bookSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: SizedBox());
              }
              if (!bookSnapshot.hasData || !bookSnapshot.data!.exists) {
                return const SizedBox();
              }

              final bookDetails = bookSnapshot.data!;

              // ✅ Check if the book is approved
              if (bookDetails['approved'] != true) {
                return const SizedBox(); // Hide books that are not approved
              }

              if (index == wishlistData.length - 1 && _hasMore) {
                return Column(
                  children: [
                    buildCardSection(context, bookId, bookDetails, wishlistId),
                    const Center(child: CircularProgressIndicator()),
                  ],
                );
              } else {
                return buildCardSection(
                    context, bookId, bookDetails, wishlistId);
              }
            },
          );
        },
      ),
    );
  }

  Widget buildCardSection(BuildContext context, String bookId,
      dynamic bookDetails, String wishlistId) {
    return GestureDetector(
      onTap: () {
        Get.to(() => BookDetailsScreen(bookId: bookId));
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 5.h),
        padding: EdgeInsets.all(5.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 115.w,
              height: 100.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: CachedNetworkImage(
                imageUrl: bookDetails['frontImageUrl'],
                fit: BoxFit.cover,
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
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bookDetails["bookName"],
                    style: appStyle(16, kDark, FontWeight.w500),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    "₹${bookDetails["mrp"]}",
                    style: appStyle(13, kPrimary, FontWeight.w500),
                  ),
                  // SizedBox(height: 8.h),
                  // Text(
                  //   bookDetails["description"],
                  //   maxLines: 3,
                  //   overflow: TextOverflow.ellipsis,
                  //   style: appStyle(12, kDarkGray, FontWeight.normal),
                  // ),
                ],
              ),
            ),
            CircleAvatar(
              backgroundColor: kWhite,
              child: IconButton(
                icon: const Icon(Icons.favorite, color: kRed),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text("Remove From Wishlist"),
                        content: const Text(
                            "Are you sure you want to remove this book from wishlist?"),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Get.back();
                            },
                            child: Text("Cancel",
                                style: appStyle(17, kRed, FontWeight.normal)),
                          ),
                          TextButton(
                            onPressed: () {
                              removeBookFromWishlist(wishlistId);
                              Navigator.pop(context);
                            },
                            child: Text("Remove",
                                style: appStyle(
                                    17, Colors.green, FontWeight.normal)),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// import 'dart:developer';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get.dart';
// import 'package:user_app/functions/remove_book_from_wishlist.dart';
// import 'package:user_app/services/firebase_collections.dart';
// import '../../common/app_style.dart';
// import '../../constants/constants.dart';
// import '../home/widgets/book_details_screen.dart';
//
// class WishlistScreen extends StatelessWidget {
//   const WishlistScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[200],
//       body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
//         stream: FirebaseFirestore.instance
//             .collection('Wishlist')
//             .where("userId", isEqualTo: currentUId)
//             .snapshots(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             log("Waiting for connection");
//             return const Center(child: CircularProgressIndicator());
//           }
//           if (!snapshot.hasData) {
//             log("Book not found");
//             return const Center(child: Text('Book Not Found'));
//           }
//           final wishlistData = snapshot.data!.docs;
//           log("Wishlist data: $wishlistData");
//           return wishlistData.isEmpty
//               ? Center(
//                   child: Text("Wishlist is empty",
//                       style: appStyle(16, kDark, FontWeight.normal)))
//               : buildBodyComponent(wishlistData);
//         },
//       ),
//     );
//   }
//
//   Widget buildBodyComponent(dynamic wishlistData) {
//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 16.w),
//       margin: EdgeInsets.only(bottom: 60.h),
//       child: ListView.builder(
//         itemCount: wishlistData.length,
//         itemBuilder: (context, index) {
//           final String bookId = wishlistData[index]['bookId'];
//           final String wishlistId = wishlistData[index].id;
//           log("Book Id $bookId");
//           return FutureBuilder<DocumentSnapshot>(
//             future: FirebaseFirestore.instance
//                 .collection('Books')
//                 .doc(bookId)
//                 .get(),
//             builder: (context, bookSnapshot) {
//               if (bookSnapshot.connectionState == ConnectionState.waiting) {
//                 return const Center(child: SizedBox());
//               }
//               if (!bookSnapshot.hasData || !bookSnapshot.data!.exists) {
//                 return const SizedBox();
//               }
//               final bookDetails = bookSnapshot.data!;
//
//               return buildCardSection(context, bookId, bookDetails, wishlistId);
//             },
//           );
//         },
//       ),
//     );
//   }
//
//   Widget buildCardSection(BuildContext context, String bookId,
//       dynamic bookDetails, String wishlistId) {
//     return GestureDetector(
//       onTap: () {
//         Get.to(() => BookDetailsScreen(bookId: bookId));
//       },
//       child: Container(
//         margin: EdgeInsets.symmetric(vertical: 16.h),
//         padding: EdgeInsets.all(16.w),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(16.0),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.grey.withOpacity(0.2),
//               spreadRadius: 1,
//               blurRadius: 2,
//               offset: const Offset(0, 1),
//             ),
//           ],
//         ),
//         child: Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Container(
//               width: 100.w,
//               height: 160.h,
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(12.0),
//                 image: DecorationImage(
//                   image: NetworkImage(bookDetails["frontImageUrl"]),
//                   fit: BoxFit.cover,
//                 ),
//               ),
//             ),
//             SizedBox(width: 16.w),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     bookDetails["bookName"],
//                     style: appStyle(16, kDark, FontWeight.bold),
//                   ),
//                   SizedBox(height: 8.h),
//                   Text(
//                     "₹${bookDetails["mrp"]}",
//                     style: appStyle(16, kPrimary, FontWeight.bold),
//                   ),
//                   SizedBox(height: 8.h),
//                   Text(
//                     bookDetails["description"],
//                     maxLines: 3,
//                     overflow: TextOverflow.ellipsis,
//                     style: appStyle(12, kDarkGray, FontWeight.normal),
//                   ),
//                 ],
//               ),
//             ),
//             CircleAvatar(
//               backgroundColor: kWhite,
//               child: IconButton(
//                 icon: const Icon(Icons.favorite, color: kRed),
//                 onPressed: () {
//                   showDialog(
//                     context: context,
//                     builder: (context) {
//                       return AlertDialog(
//                         title: const Text("Remove From Wishlist"),
//                         content: const Text(
//                             "Are you sure you want to remove this book from wishlist?"),
//                         actions: [
//                           TextButton(
//                             onPressed: () {
//                               Get.back();
//                             },
//                             child: Text("Cancel",
//                                 style: appStyle(17, kRed, FontWeight.normal)),
//                           ),
//                           TextButton(
//                             onPressed: () {
//                               removeBookFromWishlist(wishlistId);
//                               Navigator.pop(context);
//                             },
//                             child: Text("Remove",
//                                 style: appStyle(
//                                     17, Colors.green, FontWeight.normal)),
//                           ),
//                         ],
//                       );
//                     },
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
