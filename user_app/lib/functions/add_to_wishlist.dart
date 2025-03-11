import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../constants/constants.dart';
import '../utils/toast_msg.dart';

Future<void> addToWishlist(
    BuildContext context, String bookDocId, String currentUserUid) async {
  // Add logic to add the book to the wishlist collection in Firestore
  final DocumentReference wishDocRef =
      FirebaseFirestore.instance.collection('Wishlist').doc();

  final wldId = wishDocRef.id;
  final wishListData = {
    'userId': currentUserUid,
    'bookId': bookDocId,
    'wishId': wldId,
    "timestamp": DateTime.now(),
  };

  await wishDocRef.set(wishListData).then((value) {
    showToastMessage("Wishlist", "Book added to wishlist", kSuccess);
  }).onError((error, stackTrace) {
    showToastMessage("Wishlist", "Something went wrong", kRed);
  });
}
