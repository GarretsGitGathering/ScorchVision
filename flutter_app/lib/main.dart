import 'dart:convert';

import 'package:background_fetch/background_fetch.dart';
import 'package:flutter/material.dart';
import 'package:rain_project/constants.dart';
import 'package:rain_project/notification_utils.dart';
import 'package:rain_project/splashscreen.dart';
import 'package:http/http.dart' as http;

// [Android-only] This "Headless Task" is run when the Android app is terminated with `enableHeadless: true`
@pragma('vm:entry-point')
void backgroundFetchHeadlessTask(HeadlessTask task) async {
  // initialize flutter tools
  WidgetsFlutterBinding.ensureInitialized();

  String taskId = task.taskId;
  bool isTimeout = task.timeout;
  if (isTimeout) {
    // This task has exceeded its allowed running-time.
    // You must stop what you're doing and immediately .finish(taskId)
    print("[BackgroundFetch] Headless task timed-out: $taskId");
    BackgroundFetch.finish(taskId);
    return;
  }
  print('[BackgroundFetch] Headless event received.');

  // load up items from storage (won't be loaded otherwise)
  String? camId = await getString("camera_id");
  String? k = await getString("key");
  String? uid = await getString("user_id");

  print("Checking camera for fire");

  var response = await http.post(
    Uri.parse("$apiUrl/check_fire"),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({"user_id": uid, "camera_id": camId, "key": k}),
  );

  if (response.statusCode == 200) {
    var body = jsonDecode(response.body);
    var isFire = body['isFire'];
    var isGas = body['isGas'];

    // initialize notifications
    await NotificationUtils().configuration();
    if (isFire) {
      await NotificationUtils().createLocalFireInstantNotification();
    }
    if (isGas) {
      await NotificationUtils().createLocalGasInstantNotification();
    }
  }

  BackgroundFetch.finish(taskId);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // initialize background fetch and notification configuration
  BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
  NotificationUtils().configuration;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  const MyApp({super.key});

  Future<void> initPlatformState() async {}

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FireAlert - Home Protection',
      theme: getAppTheme(),
      home: SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
