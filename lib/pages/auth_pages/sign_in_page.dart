import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_instagram/pages/home_page.dart';
import 'package:flutter_instagram/services/auth_service.dart';
import 'package:flutter_instagram/services/prefs_service.dart';
import 'package:flutter_instagram/services/utils.dart';
import 'package:flutter_instagram/views/background.dart';
import 'package:flutter_instagram/views/elevated_button.dart';
import 'package:flutter_instagram/views/main_texts.dart';
import 'package:flutter_instagram/views/text_field.dart';
import 'sign_up_page.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({Key? key}) : super(key: key);

  static const id = "/sign_in_page";

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  void doSignIn(BuildContext context) async {
    String email = emailController.text.trim().toString();
    String password = passwordController.text.trim().toString();

    setState(() => isLoading = true);

    if (email.isNotEmpty && password.isNotEmpty) {
      AuthService.signInUser(email, password).then((firebaseUser) {
        getFirebaseUser(context, firebaseUser);
      });
    }
  }

  Future<void> getFirebaseUser(BuildContext context, User? user) async {
    setState(() => isLoading = false);

    if (user != null) {
      await Prefs.store(StorageKeys.UID, user.uid);
      Navigator.pushReplacementNamed(context, HomePage.id);
    } else {
      Utils.fireSnackBar("Check your email or password", context);
    }
  }

  void openSignUpPage(BuildContext context) {
    Navigator.pushReplacementNamed(context, SignUpPage.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Background(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const MainTexts(
                    mainText: "Instagram",
                    mainTextSize: 45,
                  ),
                  const SizedBox(height: 20),
                  TextFieldWidget(
                      controller: emailController, hintText: "Email",),
                  const SizedBox(height: 10),
                  TextFieldWidget(
                    controller: passwordController,
                    hintText: "Password",
                    isObscure: true,
                  ),
                  const SizedBox(height: 10),
                  ElevatedButtonWidget(onPressed: () => doSignIn(context), text: "Sign In"),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Don`t have an account?",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () => openSignUpPage(context),
                  child: const Text(
                    "Sign Up",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            isLoading
                ? const Center(child: CircularProgressIndicator.adaptive())
                : const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}
