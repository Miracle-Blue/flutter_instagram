import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_instagram/services/prefs_service.dart';
import 'package:intl/intl.dart';

class Utils {
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
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            !isSingle
                ? MaterialButton(
                    child: const Text("Cancel"),
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                  )
                : const SizedBox.shrink(),
            MaterialButton(
              child: const Text("Confirm"),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            )
          ],
        );
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

  // static Future<void> showLocalNotification(Map<String, dynamic> message) async {
  //   String title = message['title'];
  //   String body = message['body'];
  //
  //   if(Platform.isAndroid){
  //     title = message['notification']['title'];
  //     body = message['notification']['body'];
  //   }
  //
  //   var android = NotificationSettings('channelId', 'channelName', 'channelDescription');
  //   var iOS = IOSNotificationDetails();
  //   var platform = NotificationDetails(android: android, iOS: iOS);
  //
  //   int id = Random().nextInt(pow(2, 31) - 1);
  //   await FlutterLocalNotificationsPlugin().show(id, title, body, platform);
  // }
}
