import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'RoutePage.dart';
import 'constants.dart';
import 'login.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    checkLoggedIn();
  }

  Future<void> checkLoggedIn() async {
    // wait for 2 seconds so the logo is visible
    await Future.delayed(const Duration(seconds: 2));

    dynamic tmp_token = await getString("id_token");
    dynamic tmp_uid = await getString("user_id");
    
    if (tmp_uid != null && tmp_token != null) {
      // set the user_id and id_token
      id_token = tmp_token;
      user_id = tmp_uid;

      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => RouteWidget()));  // push to the RouteWidget
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));  // push to the LoginPage
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: Image.asset("assets/logo.png", width: 200,)
          )
        ],
      )
    );
  }
}
