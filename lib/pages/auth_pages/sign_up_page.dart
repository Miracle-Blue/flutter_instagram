import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_instagram/pages/auth_pages/sign_in_page.dart';
import 'package:flutter_instagram/services/auth_service.dart';
import 'package:flutter_instagram/services/data_service.dart';
import 'package:flutter_instagram/services/log_service.dart';
import 'package:flutter_instagram/services/prefs_service.dart';
import 'package:flutter_instagram/services/utils.dart';
import 'package:flutter_instagram/views/background.dart';
import 'package:flutter_instagram/views/elevated_button.dart';
import 'package:flutter_instagram/views/main_texts.dart';
import 'package:flutter_instagram/views/text_field.dart';
import 'package:flutter_instagram/models/user_model.dart' as model;

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  static const id = "/sign_up_page";

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordControllerOne = TextEditingController();
  final TextEditingController passwordControllerTwo = TextEditingController();
  bool isLoading = false;

  Future<void> doSignUp(BuildContext context) async {
    String name = fullNameController.text.trim().toString();
    String email = emailController.text.trim().toString();
    String password = passwordControllerOne.text.trim().toString();

    if (password == passwordControllerTwo.text.trim().toString() &&
        name.isNotEmpty &&
        email.isNotEmpty &&
        password.isNotEmpty) {

      setState(() => isLoading = true);

      if (!Utils.emailValidate(email)) return;
      if (!Utils.passwordValidate(password)) return;

      var modelUser = model.User(password: password, email: email, fullName:  name);

      await AuthService.signUpUser(context, name, email, password)
          .then((user) => {
                getFirebaseUser(context,  modelUser, user),
              });
    }
  }

  void getFirebaseUser(BuildContext context, model.User modelUser, User? user) async {
    setState(() => isLoading = false);

    if (user != null) {
      await Prefs.store(StorageKeys.UID, user.uid);

      modelUser.uid = user.uid;

      await DataService.storeUser(modelUser).then((value) {
        Navigator.pushReplacementNamed(context, SignInPage.id);
      });
    } else {
      Utils.fireSnackBar("Check your information", context);
    }
  }

  void openSignInPage(BuildContext context) {
    Navigator.pushReplacementNamed(context, SignInPage.id);
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
                    controller: fullNameController,
                    hintText: "Full Name",
                  ),
                  const SizedBox(height: 10),
                  TextFieldWidget(
                    controller: emailController,
                    hintText: "Email",
                  ),
                  const SizedBox(height: 10),
                  TextFieldWidget(
                    controller: passwordControllerOne,
                    hintText: "Password",
                    isObscure: true,
                  ),
                  const SizedBox(height: 10),
                  TextFieldWidget(
                    controller: passwordControllerTwo,
                    hintText: "Confirm Password",
                    isObscure: true,
                  ),
                  const SizedBox(height: 10),
                  ElevatedButtonWidget(
                    onPressed: () => doSignUp(context),
                    text: "Sign Up",
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Already have an account?",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () => openSignInPage(context),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 2.0),
                    child: Text(
                      "Sign In",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
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
