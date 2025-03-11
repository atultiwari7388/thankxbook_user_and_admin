import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Required for Timestamp

String formatDate(Timestamp timestamp) {
  try {
    // Convert Firestore Timestamp to DateTime
    DateTime date = timestamp.toDate();

    // Format the DateTime to "7 March 2025"
    return DateFormat("d MMMM yyyy").format(date);
  } catch (e) {
    return "Invalid Date"; // Handle errors
  }
}
