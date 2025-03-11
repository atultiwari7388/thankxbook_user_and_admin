import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:user_app/constants/constants.dart';
import 'package:user_app/utils/toast_msg.dart';

import '../services/firebase_collections.dart';

void removeBookFromWishlist(String bookId) {
  FirebaseFirestore.instance
      .collection('Wishlist')
      .doc(bookId)
      .delete()
      .then((value) {
    log('Book removed from wishlist $bookId');
    showToastMessage("Removed", "Book removed from wishlist", kRed);
  }).catchError((error) {
    log('Failed to remove book: $error');
    showToastMessage("Error", "Failed to remove book", kRed);
  });
}

void removeFromWishlist(BuildContext context, String bookDocId) {
  FirebaseFirestore.instance
      .collection('Wishlist')
      .where('userId', isEqualTo: currentUId)
      .where('bookId', isEqualTo: bookDocId)
      .get()
      .then((querySnapshot) {
    for (var doc in querySnapshot.docs) {
      doc.reference.delete();
      log('Book removed from wishlist $bookDocId');
    }
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Book removed from wishlist'),
    ));
  }).catchError((error) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Failed to remove book from wishlist: $error'),
    ));
  });
}
