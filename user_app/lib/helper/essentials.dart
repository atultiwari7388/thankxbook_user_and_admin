import 'package:url_launcher/url_launcher.dart';
import '../constants/constants.dart';
import '../utils/toast_msg.dart';

Future<void> makePhoneCall(String phoneNumber) async {
  final phoneUrl = "tel:$phoneNumber";
  // ignore: deprecated_member_use
  if (await canLaunch(phoneUrl)) {
    // ignore: deprecated_member_use
    await launch(phoneUrl);
  } else {
    showToastMessage("Error", "Unable to make a call", kRed);
  }
}

Future<void> openWhatsApp(String whatsappNumber) async {
  // Ensure the number is in the correct format
  final formattedNumber = whatsappNumber.replaceAll(
      RegExp(r'[^0-9]'), ''); // Remove any non-numeric characters
  final whatsappUrl = "whatsapp://send?phone=$formattedNumber";

  if (await canLaunch(whatsappUrl)) {
    await launch(whatsappUrl);
  } else {
    showToastMessage("Error", "Unable to open WhatsApp", kRed);
  }
}
