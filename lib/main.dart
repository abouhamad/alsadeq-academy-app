import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/config/app_config.dart';
import 'core/providers.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';

/// Required by firebase_messaging for background/terminated delivery. The
/// actual notification display for that case is handled by the OS itself
/// from the FCM payload's `notification` block - this just has to exist and
/// re-initialize Firebase in the spawned background isolate.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Requires `flutterfire configure` (or manually adding
  // google-services.json / GoogleService-Info.plist) before this succeeds.
  // Push notifications are a secondary feature, so a missing config here
  // must not prevent the app from starting.
  var firebaseReady = false;
  try {
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    firebaseReady = true;
  } catch (e) {
    debugPrint('Firebase not configured yet, push notifications disabled: $e');
  }

  // Built explicitly (rather than via ProviderScope in the widget tree) so
  // the FCM tap handlers below can navigate through the same router
  // instance the app itself uses, without needing a BuildContext.
  final container = ProviderContainer();
  final router = container.read(routerProvider);

  if (firebaseReady) {
    final fcmService = container.read(fcmServiceProvider);
    await fcmService.initialize();

    void handleTap(RemoteMessage message) {
      fcmService.onNotificationTap(message, (route, {extra}) => router.push(route, extra: extra));
    }

    FirebaseMessaging.onMessageOpenedApp.listen(handleTap);
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) handleTap(initialMessage);
  }

  runApp(UncontrolledProviderScope(container: container, child: const AlSadeqAcademyApp()));
}

class AlSadeqAcademyApp extends ConsumerWidget {
  const AlSadeqAcademyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: router,
    );
  }
}
