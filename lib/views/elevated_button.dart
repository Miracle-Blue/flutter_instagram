import 'package:flutter/material.dart';

class ElevatedButtonWidget extends StatelessWidget {
  const ElevatedButtonWidget({Key? key, required this.onPressed, required this.text}) : super(key: key);

  final void Function()? onPressed;
  final String text;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      clipBehavior: Clip.antiAlias,
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
          shadowColor: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(7),
          ),
          minimumSize: Size(MediaQuery.of(context).size.width, 50),
          primary: Colors.transparent,
          side: BorderSide(
          color: Colors.white54.withOpacity(0.2),
          width: 2,
        ),
        alignment: Alignment.center,
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 17),
      ),
    );
  }
}
