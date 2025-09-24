import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'constants.dart';

class homepage extends StatefulWidget {
  const homepage({super.key});

  @override
  State<homepage> createState() => _homepageState();
}

class _homepageState extends State<homepage> {
  bool _isLoading = true;
  bool _isFire = false;
  String? _imageUrl;

  @override
  void initState() {
    super.initState();
    if (camera_id != null && key != null) {
      checkFire();
    }
  }

  Future<void> checkFire() async {
    var response = await http.post(
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
      var isFire = body['isFire'];
      var isGas = body['isGas'];
      var imageUrl = body['image_url'];

      if (isFire == null || isGas == null) {
        PopupAlert(
          "Fire or Gas Status Missing.",
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

      if (isGas) {
        PopupAlert(
          "Gas Detected",
          "Gas readings have been detected. It is best for you to check to ensure your house's safety.",
          context,
        );
      }

      // explicitly set the state for the image to appear
      setState((){
         _imageUrl = imageUrl; 
      });
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
        title: Text("FireAlert Dashboard"),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded),
            onPressed: _isLoading ? null : checkFire,
            tooltip: 'Refresh Status',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: checkFire,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(AppConstants.spacingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome section
              _buildWelcomeSection(),
              
              SizedBox(height: AppConstants.spacingL),
              
              // Status cards
              _buildStatusCards(),
              
              SizedBox(height: AppConstants.spacingL),
              
              // Camera preview section
              _buildCameraSection(),
              
              SizedBox(height: AppConstants.spacingL),
              
              // Quick actions
              _buildQuickActions(),
              
              SizedBox(height: AppConstants.spacingXL),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return UIHelpers.modernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(AppConstants.spacingS),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppConstants.radiusS),
                ),
                child: Icon(
                  Icons.home_rounded,
                  color: primaryColor,
                  size: AppConstants.iconL,
                ),
              ),
              SizedBox(width: AppConstants.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Home Protection",
                      style: AppTypography.h3,
                    ),
                    Text(
                      "Monitoring your safety 24/7",
                      style: AppTypography.bodyMedium.copyWith(
                        color: textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AppConstants.spacingM),
          Text(
            "Your connected camera is actively monitoring for fire and gas. You'll receive instant notifications if any threats are detected.",
            style: AppTypography.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Current Status",
          style: AppTypography.h3,
        ),
        SizedBox(height: AppConstants.spacingM),
        Row(
          children: [
            Expanded(child: _buildFireStatusCard()),
            SizedBox(width: AppConstants.spacingM),
            Expanded(child: _buildConnectionStatusCard()),
          ],
        ),
      ],
    );
  }

  Widget _buildFireStatusCard() {
    Color cardColor = _isLoading 
        ? warningColor 
        : (_isFire ? accentColor : successColor);
    
    IconData iconData = _isLoading 
        ? Icons.sync_rounded 
        : (_isFire ? Icons.local_fire_department_rounded : Icons.shield_rounded);
    
    String statusText = _isLoading 
        ? "Checking..." 
        : (_isFire ? "Fire Detected!" : "All Clear");
    
    String subtitle = _isLoading 
        ? "Analyzing camera feed" 
        : (_isFire ? "Emergency detected" : "No threats found");

    return UIHelpers.modernCard(
      backgroundColor: cardColor.withOpacity(0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(AppConstants.spacingS),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(AppConstants.radiusS),
                ),
                child: _isLoading 
                    ? SizedBox(
                        width: AppConstants.iconM,
                        height: AppConstants.iconM,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Icon(
                        iconData,
                        color: Colors.white,
                        size: AppConstants.iconM,
                      ),
              ),
              SizedBox(width: AppConstants.spacingS),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      statusText,
                      style: AppTypography.h4.copyWith(
                        color: cardColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: AppTypography.caption,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionStatusCard() {
    bool isConnected = camera_id != null && key != null;
    Color cardColor = isConnected ? successColor : textSecondaryColor;
    
    return UIHelpers.modernCard(
      backgroundColor: cardColor.withOpacity(0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(AppConstants.spacingS),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(AppConstants.radiusS),
                ),
                child: Icon(
                  isConnected ? Icons.videocam_rounded : Icons.videocam_off_rounded,
                  color: Colors.white,
                  size: AppConstants.iconM,
                ),
              ),
              SizedBox(width: AppConstants.spacingS),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isConnected ? "Connected" : "Not Connected",
                      style: AppTypography.h4.copyWith(
                        color: cardColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      isConnected ? "Camera online" : "Pair your camera",
                      style: AppTypography.caption,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCameraSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Camera Feed",
          style: AppTypography.h3,
        ),
        SizedBox(height: AppConstants.spacingM),
        UIHelpers.modernCard(
          child: Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              color: darkColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(AppConstants.radiusS),
              border: Border.all(
                color: dividerColor,
                style: BorderStyle.solid,
              ),
            ),
            child: _imageUrl == null ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.video_camera_back_rounded,
                  size: AppConstants.iconXL,
                  color: textSecondaryColor,
                ),
                SizedBox(height: AppConstants.spacingS),
                Text(
                  "Live Camera Feed",
                  style: AppTypography.h4.copyWith(
                    color: textSecondaryColor,
                  ),
                ),
                SizedBox(height: AppConstants.spacingXS),
                Text(
                  "Coming Soon",
                  style: AppTypography.caption,
                ),
              ],
            ) 
            : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.network(_imageUrl!)
              ]
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Quick Actions",
          style: AppTypography.h3,
        ),
        SizedBox(height: AppConstants.spacingM),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : checkFire,
                icon: Icon(Icons.refresh_rounded),
                label: Text("Check Status"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: EdgeInsets.symmetric(vertical: AppConstants.spacingM),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
