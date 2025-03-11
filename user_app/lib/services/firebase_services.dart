import 'package:user_app/services/firebase_collections.dart';

class DatabaseServices {
  String? uid;

  DatabaseServices({required this.uid});

  //save user data to firebase

  Future savingUserData(
    String emailAddress,
    String userName,
    String phoneNumber,
    String profilePicture,
    String whatsAppNumber,
    List<String> address,
  ) async {
    return usersCollection.doc(uid!).set({
      "uid": uid,
      "email": emailAddress,
      "userName": userName,
      "phoneNumber": phoneNumber,
      "profilePicture": profilePicture,
      "whatsAppNumber": "+91$whatsAppNumber",
      "address": address,
      "isNotificationOn": true,
      "created_at": DateTime.now(),
    });
  }
}
