// constant values for the user_id, camera_id, and key
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

String apiUrl = "http://192.168.0.103:5000";//"https://rain-fire-detection-j5k0.onrender.com";

String? user_id;  // will be populated when user signs for first time
String? id_token;
String? camera_id;  // will be populated when user inputs on input page
String? key;  // will be populated on first pairing
// ? means unless assigned, the value of the variable is null

Color primaryColor = Color(0xFF6DE1D2);
Color secondaryColor = Color(0xFFFFD63A);
Color backgroundColor= Color(0xFFFFA955);
Color highlightColor = Color(0xFFF75A5A);

// helper function for creating popup alerts
void PopupAlert(String title, String content, BuildContext context) {
  showDialog( // pop whatever widget returned in the builder on top of the screen
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            child: Text("OK"),
            onPressed: () => Navigator.of(context).pop()
          )
        ],
      );
    }
  );
}

Future<void> saveString(String key, String value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString(key, value);
}

Future<dynamic> getString(String key) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? value = await prefs.getString(key);

  if (value == null){
    print("No value found at '$key'.");
    return null;
  }
  return value;
}

Future<void> clearPreferences() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.clear();
}