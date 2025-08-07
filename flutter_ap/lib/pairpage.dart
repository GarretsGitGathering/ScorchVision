import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'constants.dart';

class PairPage extends StatefulWidget {
  const PairPage({super.key});

  @override
  State<PairPage> createState() => _PairPageState();
}

class _PairPageState extends State<PairPage> {
  final TextEditingController cameraIdController = TextEditingController();
  bool _isLoading = false;
  String status = "Enter the camera ID that came with your device.";

  Future<void> pairCamera(String cameraId) async {
    setState(() {
      _isLoading = true;
      status = "Pairing camera...";
    });

    final response = await http.post(
      Uri.parse("$apiUrl/check_fire"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "user_id": user_id,
        "camera_id": cameraId,
      }),
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      if (body["status"] != null && body["key"] != null) {
        status = "Camera successfully paired!";
        key = body["key"];
        camera_id = cameraId;

        saveString('key', key!);  // save key into storage
        print("Successfully paired camera with key: $key");
        PopupAlert(
          "Camera Paired Successfully!",
          "Your camera has been paired successfully! You can now check its status on your home screen.",
          context,
        );
      } else {
        status = "Error: Missing data in response.";
        PopupAlert(
          "Issue Pairing Camera",
          "There was an issue pairing your camera: ${response.reasonPhrase}",
          context,
        );
      }
    } else {
      status = "Pairing failed. Please try again.";
      PopupAlert(
        "Camera Pairing Failed",
        "Camera pairing failed due to: ${response.reasonPhrase}",
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
          "Pair Your Camera",
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
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
                Text(
                  "Enter the camera ID provided in your packaging to pair the device.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 30),
                TextField(
                  controller: cameraIdController,
                  decoration: InputDecoration(
                    labelText: "Camera ID",
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: Icon(Icons.videocam, color: primaryColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                    final id = cameraIdController.text.trim();
                    if (id.isNotEmpty) {
                      pairCamera(id);
                    } else {
                      PopupAlert("Missing Camera ID", "Please enter a valid camera ID.", context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: highlightColor,
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                    "Pair Camera",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),

                const SizedBox(height: 40),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
