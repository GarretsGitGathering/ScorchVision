import 'dart:convert';

import 'package:background_fetch/background_fetch.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rain_project/constants.dart';
import 'package:rain_project/notification_utils.dart';
import 'package:rain_project/routeWidget.dart';

import 'login.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  int? _status;

  @override
  void initState() {
    super.initState(); // calling the original version of initState
    checkLoggedIn();
    initBackgroundProcess();
  }

  // initialize platform state for background fetching
  Future<void> initBackgroundProcess() async {
    int status = await BackgroundFetch.configure(
      BackgroundFetchConfig(
        minimumFetchInterval: 15,
        stopOnTerminate: false,
        enableHeadless: true,
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresStorageNotLow: false,
        requiresDeviceIdle: false,
        requiredNetworkType: NetworkType.NONE,
      ),
      (String taskId) async {
        print('[BackgroundFetch] Event received: $taskId');

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
      },
      (String taskId) async {
        print('[BackgroundFetch] TASK TIMEOUT: $taskId');
        BackgroundFetch.finish(taskId);
      },
    );

    print('[BackgroundFetch] configure success: $status');
    if (!mounted) return;
    setState(() {
      _status = status;
    });
  }

  // find if user has logged in before by checking storage
  Future<void> checkLoggedIn() async {
    // wait for a second to ensure the logo is visible
    await Future.delayed(const Duration(seconds: 1));

    // grab values from storage
    user_id = await getString("user_id");
    id_token = await getString("id_token");
    camera_id = await getString("camera_id");
    key = await getString("key");

    // checks to find if temp values are null
    if (user_id != null && id_token != null) {
      // push to the RouteWidget
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => RouteWidget()),
      );
    } else {
      // push to login if values are found to be null
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Container(
        decoration: UIHelpers.gradientBackground(
          colors: [
            primaryColor.withOpacity(0.05),
            secondaryColor.withOpacity(0.03),
            backgroundColor,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo with animated container
              AnimatedContainer(
                duration: AppConstants.animationMedium,
                padding: EdgeInsets.all(AppConstants.spacingXL),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(AppConstants.radiusXL),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.1),
                      blurRadius: AppConstants.elevationL,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Image.asset(
                  "assets/logo.png", 
                  width: 150,
                  height: 150,
                ),
              ),
              
              SizedBox(height: AppConstants.spacingXL),
              
              // App name and tagline
              Text(
                "FireAlert",
                style: AppTypography.h1.copyWith(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              SizedBox(height: AppConstants.spacingS),
              
              Text(
                "Protecting Your Home 24/7",
                style: AppTypography.bodyMedium.copyWith(
                  color: textSecondaryColor,
                ),
              ),
              
              SizedBox(height: AppConstants.spacingXL),
              
              // Loading indicator
              UIHelpers.loadingIndicator(
                color: primaryColor,
                size: 32.0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
