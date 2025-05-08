import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
    InitializationSettings(android: androidSettings);

    await _notificationsPlugin.initialize(initializationSettings);
  }

  Future<void> showNotification(String city) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'favorite_channel',
      'Favorite Cities',
      channelDescription: 'Notifications for adding cities to favorites',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );

    const NotificationDetails notificationDetails =
    NotificationDetails(android: androidDetails);

    print('Mostrando notificacion de $city');

    await _notificationsPlugin.show(
      0,
      'Agregado a favoritos',
      '$city ahora es una de tus ciudades favoritas!',
      notificationDetails,
    );
  }
}