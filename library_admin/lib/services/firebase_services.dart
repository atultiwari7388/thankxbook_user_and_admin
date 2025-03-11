import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../screens/auth/login_screen.dart';
import '../utils/toast_msg.dart';



final FirebaseAuth auth = FirebaseAuth.instance;
final FirebaseFirestore firebaseFireStore = FirebaseFirestore.instance;

class FirebaseDatabaseServices {

  final FirebaseAuth _auth = FirebaseAuth.instance;

  //for users Collection
  final Stream<QuerySnapshot> usersList =
      FirebaseFirestore.instance.collection('Users').snapshots();

  //for users collection ==> Role
  final Stream<QuerySnapshot> bookList =
      FirebaseFirestore.instance.collection('Books').snapshots();

  //for user collection
  final CollectionReference allUsersList =
      FirebaseFirestore.instance.collection("Users");

  //for booking collection
  final CollectionReference allBookingList =
      FirebaseFirestore.instance.collection("Books");

//======================= Get user name using their id =============================

  Future<String> getUserName(String userId) async {
    try {
      DocumentSnapshot userDoc = await allUsersList.doc(userId).get();

      if (userDoc.exists) {
        return (userDoc.data() as Map<String, dynamic>)['userName'] ??
            'Unknown Name';
      } else {
        return 'User Not Found';
      }
    } catch (error) {
      log("Error fetching user name: $error");
      return 'Error';
    }
  }


  //============================= Sign Out =========================================

//====================== signOut from app =====================
  void signOut(BuildContext context) async {
    try {
      if (kIsWeb) {
        _auth.signOut().then((value) {
          showToastMessage("Logout", "Logout Successfully", Colors.red);
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const AuthenticationScreen()),
                  (route) => false);
        });
      } else {
        await _auth.signOut().then((value) {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const AuthenticationScreen()),
                  (route) => false);
        });
      }
    } catch (e) {
      showToastMessage("Error", e.toString(), Colors.red);
    }
  }




}
