import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ContactDetailsScreen extends StatelessWidget {
  const ContactDetailsScreen({super.key});

  final String phoneNumber = "9971071144";
  final String email = "support@windayroot.com";

  void _launchPhoneCall() async {
    final Uri url = Uri.parse("tel:$phoneNumber");
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      print("Could not launch phone dialer.");
    }
  }

  void _launchWhatsApp() async {
    final Uri url = Uri.parse("https://wa.me/$phoneNumber");
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      print("Could not launch WhatsApp.");
    }
  }

  void _launchEmail() async {
    final Uri url = Uri.parse("mailto:$email?subject=Support%20Request");
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      print("Could not launch email.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Customer Support"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _buildContactTile(
              icon: Icons.phone,
              title: "Call Now",
              subtitle: phoneNumber,
              color: Colors.green,
              onTap: _launchPhoneCall,
            ),
            const SizedBox(height: 20),
            _buildContactTile(
              icon: FontAwesomeIcons.whatsapp,
              title: "WhatsApp",
              subtitle: phoneNumber,
              color: Colors.teal,
              onTap: _launchWhatsApp,
            ),
            const SizedBox(height: 20),
            _buildContactTile(
              icon: Icons.email,
              title: "Email",
              subtitle: email,
              color: Colors.red,
              onTap: _launchEmail,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.5), width: 1),
        ),
        padding: const EdgeInsets.all(15),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color,
              child: Icon(icon, color: Colors.white),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
