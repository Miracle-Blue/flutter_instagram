import 'package:flutter/material.dart';
import 'package:flutter_instagram/models/user_model.dart';

class StoryWidget extends StatefulWidget {
  final User user;

  const StoryWidget({Key? key, required this.user}) : super(key: key);

  @override
  _StoryWidgetState createState() => _StoryWidgetState();
}

class _StoryWidgetState extends State<StoryWidget> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        print("tapped");
      },
      child: Container(
        height: 100,
        width: 60,
        margin: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 60,
              width: 60,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(
                  width: 1,
                  color: Colors.grey
                ),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Container(
                height: 54,
                width: 54,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Image.network(widget.user.imgUrl),
              ),
            ),
            const SizedBox(height: 7),
            Text(
              widget.user.fullName,
              style: const TextStyle(fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
