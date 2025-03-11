import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:library_admin/screens/auth/login_screen.dart';
import 'package:library_admin/screens/superAdminHome/super_admin_home_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    if (auth.currentUser != null) {
      return FutureBuilder<DocumentSnapshot>(
        future: firestore.collection("admin").doc(auth.currentUser!.uid).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData && snapshot.data!.exists) {
            return const SuperAdminHomeScreen();
          } else {
            return const AuthenticationScreen();
          }
        },
      );
    } else {
      return const AuthenticationScreen();
    }
  }
}
