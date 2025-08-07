import 'package:flutter/material.dart';
import 'RoutePage.dart';
import 'constants.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  Future<void> handleLogout(BuildContext context) async {
    await clearPreferences();

    // Reset any global session values if needed
    user_id = null;
    camera_id = null;
    key = null;

    // Navigate to splash page and clear history
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => RouteWidget()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text(
          "Settings",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: ElevatedButton.icon(
            onPressed: () => handleLogout(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: highlightColor,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            icon: const Icon(Icons.logout, color: Colors.white),
            label: const Text(
              "Logout",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
