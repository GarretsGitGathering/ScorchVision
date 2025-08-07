import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rain_fire_detection_app/register.dart';
import 'RoutePage.dart';
import 'constants.dart'; // Make sure this has your color definitions

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;

  Future<void> signInUser() async {
    setState(() {
      isLoading = true;
    });

    var response = await http.post(
        Uri.parse("$apiUrl/signin"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': emailController.text,
          'password': passwordController.text
        })
    );

    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      if (body["idToken"] != null && body["user_id"] != null) {  // check to ensure the id_token and user_id exist
        id_token = body["idToken"]; // set values
        user_id = body["user_id"];

        saveString("id_token", id_token!);  // save values in SharedPrefs storage
        saveString("user_id", user_id!);

        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => RouteWidget())); // push to RouteWidget
      } else {
        PopupAlert("Malformed Response", "There was an issue logging you in, please try again shortly.", context);
      }
    } else {
      PopupAlert("Issue Signing In", "There was an issue signing you in. Please try again shortly.", context);
    }

    setState(() {
      isLoading = false;
    });
  }

  void navigateToRegister() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterPage()));  // push to the RegisterPage
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Text(
                  'Welcome Back!',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: highlightColor,
                  ),
                ),
                const SizedBox(height: 40),

                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: Icon(Icons.email, color: primaryColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: Icon(Icons.lock, color: primaryColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                ElevatedButton(
                  onPressed: isLoading ? null : signInUser,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                    'Sign In',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 20),

                TextButton(
                  onPressed: navigateToRegister,
                  child: Text(
                    "Don't have an account? Register",
                    style: TextStyle(
                      color: secondaryColor,
                      fontWeight: FontWeight.bold,
                    ),
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
