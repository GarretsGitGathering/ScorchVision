import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'constants.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  bool _isLoading = true;
  bool _isFire = false;

  @override
  void initState() {
    super.initState();
    if (camera_id != null || key != null) {
      checkFire();
    }
  }

  Future<void> checkFire() async {
    var response = await post(
      Uri.parse("$apiUrl/check_fire"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "user_id": user_id,
        "camera_id": camera_id,
        "key": key,
      }),
    );

    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      var isFire = body['status'];

      if (isFire == null) {
        PopupAlert(
          "Fire Status Missing.",
          "The response came in missing important data. Please try again or reconnect camera if this happens again.",
          context,
        );
        return;
      }

      if (isFire) {
        _isFire = true;
        PopupAlert(
          "Fire Detected",
          "A fire has been detected on your camera. It is best for you to check to ensure your house's safety.",
          context,
        );
      }
    } else {
      PopupAlert(
        "Error Response: ${response.statusCode}",
        "Please ensure your camera was properly paired. Please re-pair if this happens again.",
        context,
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text(
          "FireAlert Dashboard",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Description
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
                child: Text(
                  "This app helps protect your home by monitoring for fire using your connected camera. If fire is detected, you'll be notified immediately.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Fire status display
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: _isFire ? highlightColor : primaryColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Icon(
                      _isFire ? Icons.warning_amber_rounded : Icons.check_circle_outline,
                      size: 60,
                      color: secondaryColor,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _isLoading
                          ? "Checking fire status..."
                          : (_isFire ? "FIRE DETECTED!" : "No Fire Detected"),
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Screenshot placeholder
              Container(
                width: 300,
                height: 200,
                decoration: BoxDecoration(
                  color: secondaryColor,
                  border: Border.all(color: secondaryColor, width: 3),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Center(
                  child: Text(
                    "Camera Screenshot\n(Coming Soon)",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: highlightColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Refresh button
              ElevatedButton(
                onPressed: () {
                  checkFire(); // Trigger the fire check again
                },
                child: Text(
                  _isLoading ? "Checking..." : "Refresh Status",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isLoading ? Colors.grey : primaryColor,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
