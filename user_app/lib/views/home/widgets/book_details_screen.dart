import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:user_app/common/app_style.dart';
import 'package:user_app/common/reusable_row_widget.dart';
import 'package:user_app/constants/constants.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:user_app/functions/add_to_wishlist.dart';
import 'package:user_app/functions/remove_book_from_wishlist.dart';
import 'package:user_app/helper/essentials.dart';
import 'package:user_app/services/firebase_collections.dart';
import 'package:user_app/utils/formate_date.dart';
import 'package:user_app/utils/image_shimmer_effect.dart';
import 'package:user_app/utils/shimmer_card_effect.dart';
import 'package:user_app/utils/shimmer_grid_effect.dart';
import 'package:user_app/utils/shimmer_line_effect.dart';

class BookDetailsScreen extends StatefulWidget {
  const BookDetailsScreen({Key? key, required this.bookId}) : super(key: key);
  final String bookId;

  @override
  State<BookDetailsScreen> createState() => _BookDetailsScreenState();
}

class _BookDetailsScreenState extends State<BookDetailsScreen> {
  late Stream<List<String>> wishlistStream;
  bool isWishlisted = false;

  @override
  void initState() {
    super.initState();
    wishlistStream = getWishlistStream();
  }

  Stream<List<String>> getWishlistStream() {
    return FirebaseFirestore.instance
        .collection('Wishlist')
        .where('userId', isEqualTo: currentUId)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => doc['bookId'] as String).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('Books')
              .doc(widget.bookId)
              .get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container();
            }
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }
            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Text('Book Not Found');
            }
            return Text(
              snapshot.data!['bookName'],
              style: appStyle(17, kWhite, FontWeight.normal),
            );
          },
        ),
        centerTitle: false,
        backgroundColor: kPrimary,
        leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios, color: kWhite)),
        elevation: 0,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Books')
            .doc(widget.bookId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const ShimmerGridEffectWidget();
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Book Not Found'));
          }
          final bookData = snapshot.data!;
          return buildBodyComponentSection(bookData);
        },
      ),
    );
  }

  Widget buildBodyComponentSection(dynamic bookData) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 10.h),
          bookData['otherImageUrls'] != null &&
                  bookData['otherImageUrls'].isNotEmpty
              ? CarouselSlider(
                  items: bookData['otherImageUrls'].map<Widget>((imageUrl) {
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.fill,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const ImageShimmerEffect();
                          },
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                            Icons.error,
                            size: 50,
                          ), // Show error icon if loading fails
                        ),
                      ),
                    );
                  }).toList(),
                  options: CarouselOptions(
                    height: 240.h,
                    enlargeCenterPage: true,
                    autoPlay: true,
                    aspectRatio: 16 / 9,
                    autoPlayCurve: Curves.fastOutSlowIn,
                    enableInfiniteScroll: true,
                    autoPlayAnimationDuration:
                        const Duration(milliseconds: 800),
                    viewportFraction: .8,
                  ),
                )
              : Container(
                  height: 240.h,
                  alignment: Alignment.center,
                  child: const Text(
                    "No images available",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
          SizedBox(height: 20.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: 240,
                  child: Text(
                    bookData["bookName"].toString(),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: appStyle(16, kDark, FontWeight.bold),
                  ),
                ),
                Text(formatDate(bookData['createdAt']),
                    style: appStyle(12, kGray, FontWeight.normal)),
              ],
            ),
          ),
          SizedBox(height: 4.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.h),
            child: Row(
              children: [
                Text('Selling Price: ',
                    style: appStyle(14, kPrimary, FontWeight.w500)),
                Text(
                  "₹ ${bookData['sellingPrice']}",
                  style: appStyle(14, kPrimary, FontWeight.w500),
                ),
              ],
            ),
          ),
          SizedBox(height: 4.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.h),
            child: Row(
              children: [
                Text('MRP: ', style: appStyle(14, kDark, FontWeight.normal)),
                Text(
                  "₹ ${bookData['mrp']}",
                  style: appStyle(14, kRed, FontWeight.bold)
                      .copyWith(decoration: TextDecoration.lineThrough),
                ),
                SizedBox(width: 5.w),
                Text(
                  '(${((1 - (int.parse(bookData['sellingPrice']) / int.parse(bookData['mrp']))) * 100).toInt()}% off)',
                  style: TextStyle(fontSize: 14.sp, color: kRed),
                ),
              ],
            ),
          ),
          SizedBox(height: 10.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.h),
            child: Text(
              bookData["description"].toString(),
              style: appStyle(13, kDarkGray, FontWeight.normal),
            ),
          ),
          SizedBox(height: 20.h),
          const Divider(height: 1, color: Colors.grey),
          SizedBox(height: 20.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.h),
            child: Text(
              "Contact Details",
              style: appStyle(18, kDark, FontWeight.bold),
            ),
          ),
          SizedBox(height: 10.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.h),
            child: FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('Users')
                  .doc(bookData['userId'])
                  .get(),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return const ShimmerLineEffect();
                }
                if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                  return const Center(child: Text('User Not Found'));
                }
                final userData = userSnapshot.data!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomReusableRowWidget(
                      iconName: Icons.person,
                      title: userData['userName'],
                      color: kPrimary,
                    ),
                    SizedBox(height: 10.h),
                    CustomReusableRowWidget(
                      iconName: Icons.location_pin,
                      title: userData['address'][0].toString(),
                      color: Colors.green,
                    ),
                    SizedBox(height: 10.h),
                    CustomReusableRowWidget(
                      iconName: Icons.call,
                      title: userData['phoneNumber'].toString(),
                      color: kRed,
                    ),
                    SizedBox(height: 20.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          buildReusableAssetImages("assets/whasapp.png",
                              () => openWhatsApp(userData['whatsAppNumber'])),
                          GestureDetector(
                            onTap: () {
                              // addToWishlist(context, bookDocId, currentUId);
                              if (isWishlisted) {
                                removeFromWishlist(context, widget.bookId);
                              } else {
                                addToWishlist(
                                    context, widget.bookId, currentUId);
                              }
                            },
                            child: StreamBuilder<List<String>>(
                              stream: wishlistStream,
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  isWishlisted =
                                      snapshot.data!.contains(widget.bookId);
                                }
                                return isWishlisted
                                    ? const Icon(Icons.favorite,
                                        color: Colors.red, size: 44)
                                    : const Icon(Icons.favorite,
                                        color: Colors.grey, size: 44);
                              },
                            ),
                          ),
                          buildReusableAssetImages("assets/call_2.png",
                              () => makePhoneCall(userData['phoneNumber'])),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  Widget buildReusableAssetImages(String assetImage, Function()? onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Image.asset(assetImage, height: 40.h, width: 40.w),
      );
}
