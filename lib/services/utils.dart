import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_instagram/models/post_model.dart';
import 'package:flutter_instagram/services/prefs_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;

class Utils {
  static Future<void> share(
      {required Post post}) async {

    print(post.toJson()["img_post"]);

    final http.Response responseData = await http.get(Uri.parse(post.imgPost!));
    var uint8list = responseData.bodyBytes;
    var buffer = uint8list.buffer;
    ByteData byteData = ByteData.view(buffer);
    var tempDir = await getTemporaryDirectory();
    File file = await File('${tempDir.path}/img').writeAsBytes(
        buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

    await Share.shareFiles([file.path], text: post.caption);
  }

  static bool emailValidate(String email) {
    return RegExp(
            r'^[a-zA-Z0-9.a-zA-Z0-9.!#$%&*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+')
        .hasMatch(email);
  }

  static bool passwordValidate(String password) {
    return RegExp(
            r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$')
        .hasMatch(password);
  }

  static fireSnackBar(String msg, BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.grey.shade400.withOpacity(0.9),
        content: Text(
          msg,
          style: const TextStyle(color: Colors.white, fontSize: 16),
          textAlign: TextAlign.center,
        ),
        duration: const Duration(milliseconds: 2500),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        margin: const EdgeInsets.symmetric(vertical: 15, horizontal: 50),
        elevation: 10,
        behavior: SnackBarBehavior.floating,
        shape: const StadiumBorder(),
      ),
    );
  }

  static String getMonthDayYear(String date) {
    final DateTime now = DateTime.parse(date);
    final String formatted = DateFormat.yMMMMd().format(now);
    return formatted;
  }

  static String currentDate() {
    DateTime now = DateTime.now();

    String convertedDateTime =
        "${now.year.toString()}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} ${now.hour.toString()}:${now.minute.toString()}";
    return convertedDateTime;
  }

  static Future<bool> dialogCommon(
      BuildContext context, String title, String message, bool isSingle) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        if (Platform.isIOS) {
          return CupertinoAlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              if (!isSingle)
                TextButton(
                  child: const Text("Cancel"),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
              TextButton(
                child: const Text("Confirm"),
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
              )
            ],
          );
        } else {
          return AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              if (!isSingle)
                TextButton(
                  child: const Text("Cancel"),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
              TextButton(
                child: const Text("Confirm"),
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
              )
            ],
          );
        }
      },
    );
  }

  static Future<Map<String, String>> deviceParams() async {
    Map<String, String> params = {};
    var deviceInfo = DeviceInfoPlugin();
    String token = (await Prefs.load(StorageKeys.TOKEN))!;
    if (Platform.isIOS) {
      var iosDeviceInfo = await deviceInfo.iosInfo;
      params.addAll({
        'device_id': iosDeviceInfo.identifierForVendor!,
        'device_type': "I",
        'device_token': token
      });
    } else {
      var androidDeviceInfo = await deviceInfo.androidInfo;
      params.addAll({
        'device_id': androidDeviceInfo.androidId!,
        'device_type': "A",
        'device_token': token
      });
    }

    return params;
  }

  static Future<void> showLocalNotification(RemoteMessage message, BuildContext context) async {
  String title = message.notification!.title!;
  String body = message.notification!.body!;

  var android = const AndroidNotificationDetails("channelId", "channelName",
      channelDescription: "channelDescription");
  var iOS = const IOSNotificationDetails();
  var platform = NotificationDetails(android: android, iOS: iOS);

  int id = Random().nextInt((pow(2, 31) - 1).toInt());
  await FlutterLocalNotificationsPlugin().show(id, title, body, platform);
  }
}
