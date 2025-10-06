import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rain_project/constants.dart';

class DeviceSettings extends StatefulWidget {
  const DeviceSettings({super.key});

  @override
  State<DeviceSettings> createState() => _DeviceSettingsState();
}

class _DeviceSettingsState extends State<DeviceSettings> {

  // method to shut down hardware 
  Future<void> shutOffHardware() async {
    try {
    var response = await http.post(
      Uri.parse("$apiUrl/shutdown"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "key": await getString("key")
      })
    );

    if (response.statusCode == 200) {
      PopupAlert(
        "Device Powered Off!", 
        "Your device has been powered off!", 
        context
      );
    } else {
      PopupAlert(
        "Unable to Power Off Device",
        "Your device was unable to be powered off. Please try again later.", 
        context
      );
    }
    } catch (error) {
      PopupAlert(
        "Unable to Send Request", 
        "We were unable to send the request. please make sure you have an internet connection.", 
        context
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}


