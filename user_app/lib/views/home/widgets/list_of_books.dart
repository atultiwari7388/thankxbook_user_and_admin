import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:user_app/functions/remove_book_from_wishlist.dart';
import 'package:user_app/services/firebase_collections.dart';
import 'package:user_app/utils/image_shimmer_effect.dart';
import 'package:user_app/utils/shimmer_card_effect.dart';
import 'package:user_app/utils/shimmer_grid_effect.dart';
import '../../../common/app_style.dart';
import '../../../constants/constants.dart';
import '../../../functions/add_to_wishlist.dart';
import 'book_details_screen.dart';

class ListOfBooksWidget extends StatefulWidget {
  final String searchText;

  const ListOfBooksWidget({
    required this.searchText,
    Key? key,
  }) : super(key: key);

  @override
  State<ListOfBooksWidget> createState() => _ListOfBooksWidgetState();
}

class _ListOfBooksWidgetState extends State<ListOfBooksWidget> {
  late Stream<List<String>> wishlistStream;

  @override
  void initState() {
    super.initState();
    wishlistStream = getWishlistStream();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('Books')
          .where("approved", isEqualTo: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const ShimmerGridEffectWidget();
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final books = snapshot.data!.docs;
        final currentUserUid = currentUId;

        final filteredBooks = books
            .where((book) =>
                book['userId'] != currentUserUid &&
                book['bookName']
                    .toLowerCase()
                    .contains(widget.searchText.toLowerCase()))
            .toList();

        if (filteredBooks.isEmpty) {
          return const Center(child: Text('No Books Available'));
        }
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 4.7 / 9,
          ),
          itemCount: filteredBooks.length,
          itemBuilder: (BuildContext context, int index) {
            final bookData = filteredBooks[index].data();
            final bookDocId = filteredBooks[index].id;
            return buildCardSection(context, bookData, bookDocId);
          },
        );
      },
    );
  }

  Widget buildCardSection(
      BuildContext context, Map<String, dynamic> bookData, String bookDocId) {
    return StreamBuilder<List<String>>(
      stream: wishlistStream,
      builder: (context, wishlistSnapshot) {
        if (wishlistSnapshot.connectionState == ConnectionState.waiting) {
          // return buildBookCard(context, bookData, bookDocId, false);
          return const ShimmerCardEffectWidget();
        } else if (wishlistSnapshot.hasError) {
          return buildBookCard(context, bookData, bookDocId, false);
        } else {
          final isBookInWishlist = wishlistSnapshot.data!.contains(bookDocId);

          return buildBookCard(context, bookData, bookDocId, isBookInWishlist);
        }
      },
    );
  }

  Widget buildBookCard(BuildContext context, Map<String, dynamic> bookData,
      String bookDocId, bool isBookInWishlist) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: InkWell(
        borderRadius: BorderRadius.circular(8.0),
        onTap: () {
          Get.to(() => BookDetailsScreen(bookId: bookDocId));
        },
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(8.r),
                    ),
                    child: Image.network(
                      bookData['frontImageUrl'],
                      fit: BoxFit.fill,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const ImageShimmerEffect();
                      },
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.error, size: 50),
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        bookData['bookName'],
                        style: appStyle(14, kDark, FontWeight.normal),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 20.w, right: 20.w),
                      decoration: BoxDecoration(
                        color: kPrimary,
                        borderRadius: BorderRadius.circular(15.r),
                      ),
                      child: Center(
                        child: Text(
                          "₹ ${bookData['sellingPrice']}",
                          style: appStyle(14, kWhite, FontWeight.normal),
                        ),
                      ),
                    ),
                    SizedBox(height: 5.h),
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.center,
                    //   children: [
                    //     Text('MRP ',
                    //         style: appStyle(14, kDark, FontWeight.normal)),
                    //     Text(
                    //       "₹ ${bookData['mrp']}",
                    //       style: appStyle(14, kDark, FontWeight.bold)
                    //           .copyWith(decoration: TextDecoration.lineThrough),
                    //     ),
                    //     SizedBox(width: 5.w),
                    //     Text(
                    //       '(${((1 - (int.parse(bookData['sellingPrice']) / int.parse(bookData['mrp']))) * 100).toInt()}% off)',
                    //       style: TextStyle(fontSize: 14.sp, color: kDark),
                    //     ),
                    //   ],
                    // ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('MRP ',
                            style: appStyle(14, kDark, FontWeight.normal)),
                        Text(
                          "₹ ${bookData['mrp'] ?? '0'}",
                          style: appStyle(14, kDark, FontWeight.bold)
                              .copyWith(decoration: TextDecoration.lineThrough),
                        ),
                        SizedBox(width: 5.w),
                        Text(
                          '(${calculateDiscount(bookData['mrp'], bookData['sellingPrice'])}% off)',
                          style: TextStyle(fontSize: 14.sp, color: kDark),
                        ),
                      ],
                    ),

                    SizedBox(height: 10.h),
                  ],
                ),
              ],
            ),
            Positioned(
              top: 8.h,
              right: 8.w,
              child: CircleAvatar(
                backgroundColor: kPrimary,
                child: IconButton(
                  icon: Icon(
                    Icons.favorite,
                    color: isBookInWishlist ? kRed : kWhite,
                  ),
                  onPressed: () {
                    // addToWishlist(context, bookDocId, currentUId);
                    if (isBookInWishlist) {
                      removeFromWishlist(context, bookDocId);
                    } else {
                      addToWishlist(context, bookDocId, currentUId);
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  int calculateDiscount(dynamic mrp, dynamic sellingPrice) {
    if (mrp == null || sellingPrice == null) return 0;

    int mrpValue = int.tryParse(mrp.toString()) ?? 1;
    int sellingValue = int.tryParse(sellingPrice.toString()) ?? 0;

    if (mrpValue <= 0) return 0;

    double discount = (1 - (sellingValue / mrpValue)) * 100;

    return discount.round();
  }

  Stream<List<String>> getWishlistStream() {
    return FirebaseFirestore.instance
        .collection('Wishlist')
        .where('userId', isEqualTo: currentUId)
        .snapshots()
        .map<List<String>>((snapshot) {
      final List<String> bookIds = [];
      for (var doc in snapshot.docs) {
        bookIds.add(doc['bookId']);
      }
      return bookIds;
    });
  }
}
