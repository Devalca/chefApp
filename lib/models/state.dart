import 'package:firebase_auth/firebase_auth.dart';
import 'package:myChef/models/settings.dart';
import 'package:myChef/models/user.dart';

class StateModel {
  bool isLoading;
  FirebaseUser firebaseUserAuth;
  User user;
  Settings settings;

  StateModel({
    this.isLoading = false,
    this.firebaseUserAuth,
    this.user,
    this.settings,
  });
}