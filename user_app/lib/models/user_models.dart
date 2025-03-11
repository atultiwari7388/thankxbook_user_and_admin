class UserProfile {
  final String name;
  final String email;
  final String imageUrl;
  final String whatsAppNumber;
  final List<dynamic> currentAddress;


  UserProfile({
    required this.name,
    required this.email,
    required this.imageUrl,
    required this.whatsAppNumber,
    required this.currentAddress,
  });
}