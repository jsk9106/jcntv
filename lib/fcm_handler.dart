import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FcmHandler {
  static Future<void> setting() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    await messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    // foreground 에서 푸시 알림 설정을 위한 중요도 설정 (안드로이드)
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'jcntv_notification',
      'jcntv_notification',
      description: 'jcntv 알림입니다.',
      importance: Importance.high,
    );

    // foreground 에서의 푸시 알림 표시를 위한 local notification 설정
    // if(Platform.isAndroid) {
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
      await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        if (kDebugMode) print('Got a message whilst in the foreground!');
        if (kDebugMode) print('Message data: ${message.data}');

        if (message.notification != null) {
          if (kDebugMode) print('Message also contained a notification: ${message.notification}');
          flutterLocalNotificationsPlugin.show(
            message.hashCode,
            message.notification?.title,
            message.notification?.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                channelDescription: channel.description,
                // icon: '@drawable/noti_icon',
                icon: 'mipmap/ic_launcher',
              ),
              iOS: const DarwinNotificationDetails(
                subtitle: 'the subtitle',
                sound: 'slow_spring_board.aiff',
              ),
            ),
          );
        }
      });
    // }

    if(kDebugMode) print('fcmToken: ${await messaging.getToken()}');
  }
}
