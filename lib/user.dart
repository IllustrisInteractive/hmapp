import 'package:firebase_auth/firebase_auth.dart';

class UserSingleton {
  String name = "";
  String email = "";
  User? user = FirebaseAuth.instance.currentUser;
  String userType = "user";

  // Private constructor
  UserSingleton._privateConstructor();

  // Singleton instance
  static final UserSingleton _instance = UserSingleton._privateConstructor();

  // Getter to access the instance
  static UserSingleton get instance => _instance;
}
