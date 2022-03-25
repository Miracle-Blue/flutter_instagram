import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_instagram/pages/auth_pages/sign_in_page.dart';

import 'prefs_service.dart';
import 'log_service.dart';
import 'utils.dart';

class AuthService {
  static const isTester = true;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<User?> signUpUser(BuildContext context, String name, String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);

      User? user = userCredential.user;
      await user!.updateDisplayName(name);
      Log.d(user.toString());

      return user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        Log.d('The password provided is too weak.');
        Utils.fireSnackBar("The password provided is too weak.", context);
      } else if (e.code == 'email-already-in-use') {
        Log.d("The account already exists for that email.");
        Utils.fireSnackBar("The account already exists for that email.", context);
      }
    } catch (e) {
      Log.d(e.toString());
      Utils.fireSnackBar("ERROR $e", context);
    }

    return null;
  }

  static Future<User?> signInUser(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      User? user = userCredential.user;
      Log.d(user.toString());

      return user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        Log.d('No user found for email.');
      } else if (e.code == 'wrong-password') {
        Log.d("Wrong password provided for that user.");
      }
    } catch (e) {
      Log.d(e.toString());
    }

    return null;
  }

  static void signOutUser(BuildContext context) async {
    await _auth.signOut();
    await Prefs.remove(StorageKeys.UID);
    Navigator.pushNamedAndRemoveUntil(context, SignInPage.id, (route) => route.isFirst);
  }

  static Future<void> deleteUser(BuildContext context, String email, String password) async {
    try {
      _auth.currentUser!.delete();
      Prefs.remove(StorageKeys.UID);
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const SignInPage()), (route) => false);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        Utils.fireSnackBar('The user must re-authenticate before this operation can be executed.', context);
      }
    }
  }
}