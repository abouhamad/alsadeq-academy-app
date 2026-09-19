import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../constants/api_endpoints.dart';
import '../network/api_client.dart';

/// Registers this device's FCM token against
/// `GET set-fcm-token?id={userId}&token={token}` (SmApiController@setFcmToken,
/// routes/api.php) and shows an in-app banner + sound for messages that
/// arrive while the app is in the foreground (Android/iOS both suppress the
/// system notification tray in that case - `flutter_local_notifications` is
/// what actually shows something and plays a sound then). Background/killed
/// delivery is handled entirely by the OS from the FCM payload's
/// `notification` block, no app code required.
class FcmService {
  FcmService(this._client);

  final ApiClient _client;
  final _messaging = FirebaseMessaging.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();

  static const _androidChannel = AndroidNotificationChannel(
    'messages',
    'Messages',
    description: 'New message alerts',
    importance: Importance.high,
  );

  Future<void> initialize() async {
    await _localNotifications.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
    );
    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_androidChannel);

    FirebaseMessaging.onMessage.listen(_showForegroundNotification);
  }

  Future<void> _showForegroundNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    await _localNotifications.show(
      message.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannel.id,
          _androidChannel.name,
          channelDescription: _androidChannel.description,
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
        ),
        iOS: const DarwinNotificationDetails(presentSound: true),
      ),
    );
  }

  Future<void> registerToken(int userId) async {
    try {
      await _messaging.requestPermission();
      final token = await _messaging.getToken();
      if (token == null) return;
      await _client.get<dynamic>(ApiEndpoints.setFcmToken, query: {'id': userId, 'token': token});

      _messaging.onTokenRefresh.listen((newToken) {
        _client.get<dynamic>(ApiEndpoints.setFcmToken, query: {'id': userId, 'token': newToken});
      });
    } catch (e) {
      // Non-fatal: push notifications are a bonus feature, never block login.
      debugPrint('FCM token registration failed: $e');
    }
  }

  /// Call from a top-level `FirebaseMessaging.onMessageOpenedApp` /
  /// `getInitialMessage` listener in main.dart. `navigate` receives the
  /// target route and, for a message push, the thread's `extra` map
  /// expected by the `/messages/thread` route.
  void onNotificationTap(RemoteMessage message, void Function(String route, {Object? extra}) navigate) {
    final clickAction = message.data['click_action'];
    if (clickAction != 'FLUTTER_NOTIFICATION_CLICK') return;
    final type = message.data['type'];
    switch (type) {
      case 'homework':
        navigate('/homework');
        break;
      case 'notice':
        navigate('/notices');
        break;
      case 'message':
        final senderId = int.tryParse(message.data['sender_id']?.toString() ?? '');
        final senderName = message.data['sender_name']?.toString();
        if (senderId != null && senderName != null) {
          navigate('/messages/thread', extra: {'userId': senderId, 'name': senderName});
        } else {
          navigate('/messages');
        }
        break;
      default:
        navigate('/dashboard');
    }
  }
}
