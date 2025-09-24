import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rain_project/constants.dart';
import 'package:rain_project/login.dart';
import 'package:rain_project/routeWidget.dart';

import 'homepage.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  bool _isLoading = false;

  // send register post request and handle response
  Future<void> register() async {
    if (passwordController.text != confirmPasswordController.text) {
      PopupAlert("Passwords Do Not Match", "Please ensure your passwords match. We don't want you losing it!", context);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    var response = await http.post(
        Uri.parse("$apiUrl/signup"),
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
        PopupAlert("Malformed Response", "There was an issue registering. Please try again.", context);
      }
    } else {
      PopupAlert("Issue Signing In", "There was an issue registering. Please make sure your email is complete and your password is at least 6 characters long.", context);
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
                    
                    // Registration form
                    _buildRegistrationForm(),
                    
                    SizedBox(height: AppConstants.spacingL),
                    
                    // Sign up button
                    _buildSignUpButton(),
                    
                    SizedBox(height: AppConstants.spacingL),
                    
                    // Login link
                    _buildLoginLink(),
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
          "Join FireAlert!",
          style: AppTypography.h2.copyWith(
            color: primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        
        SizedBox(height: AppConstants.spacingS),
        
        Text(
          "Create your account to start protecting your home",
          style: AppTypography.bodyMedium.copyWith(
            color: textSecondaryColor,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildRegistrationForm() {
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
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: "Password",
            hintText: "Create a strong password",
            prefixIcon: Icon(Icons.lock_rounded, color: primaryColor),
          ),
        ),
        
        SizedBox(height: AppConstants.spacingM),
        
        // Confirm password field
        TextField(
          controller: confirmPasswordController,
          obscureText: true,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _isLoading ? null : register(),
          decoration: InputDecoration(
            labelText: "Confirm Password",
            hintText: "Re-enter your password",
            prefixIcon: Icon(Icons.lock_outline_rounded, color: primaryColor),
          ),
        ),
        
        SizedBox(height: AppConstants.spacingS),
        
        // Password requirements info
        _buildPasswordRequirements(),
      ],
    );
  }

  Widget _buildPasswordRequirements() {
    return UIHelpers.modernCard(
      backgroundColor: successColor.withOpacity(0.05),
      padding: EdgeInsets.all(AppConstants.spacingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: AppConstants.iconS,
                color: successColor,
              ),
              SizedBox(width: AppConstants.spacingXS),
              Text(
                "Password Requirements",
                style: AppTypography.caption.copyWith(
                  fontWeight: FontWeight.w600,
                  color: successColor,
                ),
              ),
            ],
          ),
          SizedBox(height: AppConstants.spacingXS),
          Text(
            "• At least 6 characters long\n• Must match confirmation password",
            style: AppTypography.caption.copyWith(
              color: textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignUpButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : register,
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
                    "Creating Account...",
                    style: AppTypography.buttonMedium,
                  ),
                ],
              )
            : Text(
                "Create Account",
                style: AppTypography.buttonLarge,
              ),
      ),
    );
  }

  Widget _buildLoginLink() {
    return UIHelpers.modernCard(
      backgroundColor: primaryColor.withOpacity(0.05),
      child: Column(
        children: [
          Text(
            "Already have an account?",
            style: AppTypography.bodyMedium.copyWith(
              color: textSecondaryColor,
            ),
          ),
          SizedBox(height: AppConstants.spacingS),
          TextButton(
            onPressed: () {
              Navigator.pushReplacement(
                context, 
                MaterialPageRoute(builder: (context) => LoginPage()),
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
              "Sign In Instead",
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