import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rain_project/constants.dart';
import 'package:rain_project/register.dart';
import 'package:rain_project/routeWidget.dart';

import 'constants.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Text Editing Controllers to hold the username and password
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool _isLoading = false;

  // Post request function to log the user in
  Future<void> signIn() async {
    setState(() {
      _isLoading = true;
    });

    var response = await http.post(
      Uri.parse("$apiUrl/signin"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": emailController.text,
        "password": passwordController.text
      })
    );

    // check the status code to ensure a positive response
    if (response.statusCode == 200) {
      // decode the body and grab the user_id & token
      var body = jsonDecode(response.body);
      if (body['user_id'] != null && body['idToken'] != null) {
        user_id = body['user_id'];  // update the values
        id_token = body['idToken'];

        // save data locally
        storeString("user_id", user_id!); // null check (!) will throw an error if the String? its checking is null
        storeString("id_token", id_token!);

        // push to the home page
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => RouteWidget()));
      } else {
        PopupAlert("Malformed Response", "There was an issue logging you in. Please try again.", context);
      }
    } else {
      PopupAlert("Issue Signing In", "There was an issue signing in. Please ensure your email and password is correct and try again", context);
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(AppConstants.spacingL),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo and welcome section
                    _buildWelcomeSection(),
                    
                    SizedBox(height: AppConstants.spacingXL),
                    
                    // Login form
                    _buildLoginForm(),
                    
                    SizedBox(height: AppConstants.spacingL),
                    
                    // Sign in button
                    _buildSignInButton(),
                    
                    SizedBox(height: AppConstants.spacingL),
                    
                    // Register link
                    _buildRegisterLink(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Column(
      children: [
        // Logo with subtle background
        Container(
          padding: EdgeInsets.all(AppConstants.spacingL),
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppConstants.radiusXL),
          ),
          child: Image.asset(
            "assets/logo.png", 
            width: 120,
            height: 120,
          ),
        ),
        
        SizedBox(height: AppConstants.spacingL),
        
        Text(
          "Welcome Back!",
          style: AppTypography.h2.copyWith(
            color: primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        
        SizedBox(height: AppConstants.spacingS),
        
        Text(
          "Sign in to monitor your home's safety",
          style: AppTypography.bodyMedium.copyWith(
            color: textSecondaryColor,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Column(
      children: [
        // Email field
        TextField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: "Email Address",
            hintText: "Enter your email",
            prefixIcon: Icon(Icons.email_rounded, color: primaryColor),
          ),
        ),
        
        SizedBox(height: AppConstants.spacingM),
        
        // Password field
        TextField(
          controller: passwordController,
          obscureText: true,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _isLoading ? null : signIn(),
          decoration: InputDecoration(
            labelText: "Password",
            hintText: "Enter your password",
            prefixIcon: Icon(Icons.lock_rounded, color: primaryColor),
          ),
        ),
      ],
    );
  }

  Widget _buildSignInButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : signIn,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          padding: EdgeInsets.symmetric(vertical: AppConstants.spacingM),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusM),
          ),
          elevation: AppConstants.elevationS,
        ),
        child: _isLoading
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  SizedBox(width: AppConstants.spacingS),
                  Text(
                    "Signing In...",
                    style: AppTypography.buttonMedium,
                  ),
                ],
              )
            : Text(
                "Sign In",
                style: AppTypography.buttonLarge,
              ),
      ),
    );
  }

  Widget _buildRegisterLink() {
    return UIHelpers.modernCard(
      backgroundColor: primaryColor.withOpacity(0.05),
      child: Column(
        children: [
          Text(
            "Don't have an account?",
            style: AppTypography.bodyMedium.copyWith(
              color: textSecondaryColor,
            ),
          ),
          SizedBox(height: AppConstants.spacingS),
          TextButton(
            onPressed: () {
              Navigator.pushReplacement(
                context, 
                MaterialPageRoute(builder: (context) => RegisterPage()),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: primaryColor,
              padding: EdgeInsets.symmetric(
                horizontal: AppConstants.spacingL,
                vertical: AppConstants.spacingS,
              ),
            ),
            child: Text(
              "Create Account",
              style: AppTypography.buttonMedium.copyWith(
                color: primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}