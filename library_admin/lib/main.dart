import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:library_admin/screens/splash/splash_screen.dart';
import 'package:library_admin/utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    //run for web
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyAqO8epkW-mY7LAyqi9Opl3-Sa_cz4bbRM",
        authDomain: "windayroot-library.firebaseapp.com",
        projectId: "windayroot-library",
        storageBucket: "windayroot-library.appspot.com",
        messagingSenderId: "381990827165",
        appId: "1:381990827165:web:7e956e22a504cd78ad1074",
        measurementId: "G-EKS9XSWTKL",
      ),
    );
  } else {
    //run for android
    await Firebase.initializeApp();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: appName,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
