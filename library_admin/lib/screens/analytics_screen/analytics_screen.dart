import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:library_admin/utils/constants.dart';

import '../../common/admin_analysis_box.dart';
import '../../services/firebase_services.dart';

class SuperAdminAnalyticsScreen extends StatefulWidget {
  static const String id = "admin-analytics";

  const SuperAdminAnalyticsScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<SuperAdminAnalyticsScreen> createState() =>
      _SuperAdminAnalyticsScreenState();
}

class _SuperAdminAnalyticsScreenState extends State<SuperAdminAnalyticsScreen> {
  String formatDateWithTimeStamp(Timestamp timestamp) {
    final DateTime dateTime = timestamp.toDate();
    final DateFormat dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
    return dateFormat.format(dateTime);
  }


  Widget buildAnalysisBox({
    required Stream<QuerySnapshot> stream,
    required String firstText,
    required IconData icon,
    Color containerColor = kPrimary,
    required onTap,
  }) {
    return StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData) {
          List<DocumentSnapshot> documents = snapshot.data!.docs;
          int count = documents.length;

          return InkWell(
            onTap: onTap,
            child: SecondAdminAnalysisBoxesWidgets(
              containerColor: containerColor,
              firstText: firstText,
              secondText: count.toString(),
              firstIcon: icon,
            ),
          );
        } else {
          return Container(); // Placeholder widget for error or no data
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          GridView.count(
            crossAxisCount: 3,
            childAspectRatio: 3.5,
            mainAxisSpacing: 20.0,
            crossAxisSpacing: 20.0,
            shrinkWrap: true,
            padding: const EdgeInsets.all(2),
            children: [
              // Total Appointments
              buildAnalysisBox(
                onTap: () {},
                stream: FirebaseDatabaseServices().usersList,
                firstText: "Total Users",
                icon: FontAwesomeIcons.users,
                containerColor: kSecondary,
              ),
//================== Total Booking ===============================
              buildAnalysisBox(
                onTap: () {},
                stream: FirebaseDatabaseServices().bookList,
                firstText: "Total Books",
                icon: FontAwesomeIcons.baby,
                containerColor: Colors.red,
              )
            ],
          ),
          const SizedBox(height: 20),

        ],
      ),
    );
  }



}
