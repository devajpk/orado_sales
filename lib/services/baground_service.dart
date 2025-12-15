import 'dart:developer';
import 'package:flutter/widgets.dart';
import 'package:flutter_background_service/flutter_background_service.dart';

Future<void> initializeBackgroundService() async {
  final service = FlutterBackgroundService();

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: backgroundServiceOnStart,
      autoStart: false,
      isForegroundMode: true,

      // 🔴 REQUIRED – otherwise crash
      notificationChannelId: 'foreground_service',
      initialNotificationTitle: 'Orado Service Running',
      initialNotificationContent: 'Location tracking active',
      foregroundServiceNotificationId: 888,
    ),
    iosConfiguration: IosConfiguration(
      autoStart: false,
      onForeground: backgroundServiceOnStart,
    ),
  );

  log('Background service configured successfully');
}

@pragma('vm:entry-point')
void backgroundServiceOnStart(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔴 MUST BE FIRST – NO ASYNC BEFORE THIS
  if (service is AndroidServiceInstance) {
    service.setForegroundNotificationInfo(
      title: 'Orado Service Running',
      content: 'Location tracking active',
    );
  }

  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  log('Foreground service started safely');
}
