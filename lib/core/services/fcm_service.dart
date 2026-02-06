import 'package:firebase_messaging/firebase_messaging.dart';

class FCMService {
  static final _fcm = FirebaseMessaging.instance;

  static Future<String?> getToken() async {
    // Xin quyền
    await _fcm.requestPermission();

    // Lấy token
    String? token = await _fcm.getToken(
      vapidKey: "BPAQH-UaL1Jb2_1BsaaRDMTQrxQu3sMHXxFI0p7WR18P9JaexK7o2TSps9lGknCzPUjL-pVvjq165Y2gSpPgf1A",
    );

    print("FCM TOKEN: $token");

    return token;
  }
}
