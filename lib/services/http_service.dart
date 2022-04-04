import 'dart:convert';

import 'package:http/http.dart';

class HttpService {
  static bool isTester = true;

  static String SERVER_DEVELOPMENT = "fcm.googleapis.com";
  static String SERVER_PRODUCTION = "fcm.googleapis.com";

  static String getServer() {
    if (isTester) return SERVER_DEVELOPMENT;
    return SERVER_PRODUCTION;
  }

  static Map<String, String> getHeaders() {
    String _key = 'key=AAAAskiLba4:APA91bHIXo8TpeyH3nLlDHu5n50U9bFGmsZ2wRaqzw-XFzSEK8AnhVnQyeameyS5QGntdshFHXrxEIgW2Ugu8R97JfOF0qUsXL2KfpdhM7GKEtxrtG5lIy-9qAgr2SAe_CFmTip-3gJc';
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': _key
      };
    return headers;
  }

  // ! requests
  static Future<String?> POST(String api, Map<String, dynamic> body) async {
    var uri = Uri.https(getServer(), api);
    var response = await post(uri, headers: getHeaders(), body: jsonEncode(body));

    if (response.statusCode == 201) {
      return response.body;
    }

    return null;
  }

  // ! APIs
  static String API_FCM_SEND = "/fcm/send";

  // ! body
  static Map<String, dynamic> body({required String name, required String someone, required String token}) => {
      "notification": {
        "title": "Instagram Clone",
        "body": "($someone) $name is followed you"
      },
      "registration_ids": [token],
      "click_action": "FLUTTER_NOTIFICATION_CLICK"
    };
}