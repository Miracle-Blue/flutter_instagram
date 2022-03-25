import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'pages/home_page.dart';

import 'pages/auth_pages/sign_in_page.dart';
import 'pages/auth_pages/sign_up_page.dart';
import 'pages/auth_pages/splash_page.dart';

import '/pages/body_pages/profile_page.dart';
import 'pages/body_pages/feed_page.dart';
import 'pages/body_pages/like_page.dart';
import 'pages/body_pages/search_page.dart';
import 'pages/body_pages/upload_page.dart';

import 'views/themes.dart' show themeLight;


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Instagram',
      debugShowCheckedModeBanner: false,
      theme: themeLight,
      home: const SplashPage(),
      routes: {
        SplashPage.id: (context) => const SplashPage(),
        SignInPage.id: (context) => const SignInPage(),
        SignUpPage.id: (context) => const SignUpPage(),
        HomePage.id: (context) => const HomePage(),
        FeedPage.id: (context) => const FeedPage(),
        LikePage.id: (context) => const LikePage(),
        SearchPage.id: (context) => const SearchPage(),
        UploadPage.id: (context) => const UploadPage(),
        ProfilePage.id: (context) => const ProfilePage(),
      },
    );
  }
}