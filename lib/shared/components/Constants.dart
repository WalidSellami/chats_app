
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';

String getOs() {
  return Platform.operatingSystem;
}

dynamic uId;

bool? isSaved;

String profile = 'https://t4.ftcdn.net/jpg/00/64/67/63/360_F_64676383_LdbmhiNM6Ypzb3FM4PPuFP9rHe7ri8Ju.webp';

String cover  = 'https://img.freepik.com/free-photo/abstract-textured-backgound_1258-30555.jpg';



Future<String?> getDeviceToken() async {

  return await FirebaseMessaging.instance.getToken();

}