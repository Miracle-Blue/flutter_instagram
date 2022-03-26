import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_instagram/pages/auth_pages/sign_in_page.dart';
import 'package:flutter_instagram/pages/home_page.dart';
import 'package:flutter_instagram/services/log_service.dart';
import 'package:flutter_instagram/services/prefs_service.dart';
import 'package:flutter_instagram/views/background.dart';
import 'package:flutter_instagram/views/main_texts.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  static const id = "/splash_page";

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  @override
  void initState() {
    super.initState();
    openNextPage(context);
    _initNotification();
  }
  
  // Stream<User> getData() {
  //   return Stream.periodic(const Duration(seconds: 1))
  //       .asyncMap((event) => getFirebaseUser());
  // }
  //
  // Future<User> getFirebaseUser() {
  //
  // }

  void _initNotification() {
    _firebaseMessaging.requestPermission(sound: true, badge: true, alert: true);
    _firebaseMessaging.getToken().then((token) async {
      assert(token != null);
      Log.d(token.toString());
      await Prefs.store(StorageKeys.TOKEN, token!);
    });
  }

  void openNextPage(BuildContext context) async {
    await Future.delayed(const Duration(seconds: 3)).then((value) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => startPage()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Background(
        children: [
          Expanded(
            child: Center(
              child: MainTexts(
                mainText: "Instagram",
                mainTextSize: 45,
              ),
            ),
          ),
          Text(
            "All rights reserved",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget startPage() {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.userChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          Prefs.store(StorageKeys.UID, snapshot.data!.uid);
          return const HomePage();
        } else {
          Prefs.remove(StorageKeys.UID);
          return const SignInPage();
        }
      },
    );
  }
}
