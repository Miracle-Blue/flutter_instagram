import 'package:flutter/material.dart';

import 'themes.dart' show fontHeader;

class MainTexts extends StatelessWidget {
  const MainTexts({Key? key, this.mainText, this.mainTextSize, this.color = Colors.white}) : super(key: key);

  final String? mainText;
  final double? mainTextSize;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Text(
      mainText!,
      style: TextStyle(
        color: color,
        fontSize: mainTextSize,
        fontFamily: fontHeader,
      ),
    );
  }
}
