import 'package:flutter/material.dart';

class TextFieldWidget extends StatelessWidget {
  const TextFieldWidget({Key? key, required this.controller, required this.hintText, this.isObscure = false}) : super(key: key);

  final TextEditingController controller;
  final String hintText;
  final bool isObscure;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(7),
      child: TextFormField(
        style: const TextStyle(color: Colors.white),
        controller: controller,
        obscureText: isObscure,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white54.withOpacity(0.2),
          hintText: hintText,
          border: InputBorder.none,
          hintStyle: const TextStyle(
            fontSize: 17.0,
            color: Colors.white54,
          ),
        ),
      ),
    );
  }
}
