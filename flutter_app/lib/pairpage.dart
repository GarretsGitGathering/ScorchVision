import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rain_project/constants.dart';

class PairPage extends StatefulWidget {
  const PairPage({super.key});

  @override
  State<PairPage> createState() => _PairPageState();
}

class _PairPageState extends State<PairPage> {
  TextEditingController cameraIdController = TextEditingController();
  bool _isLoading = false;
  String status = "Enter the camera ID that came with the camera.";

  Future<void> pairCamera() async {
    setState(() {
      _isLoading = true;
      status = "Loading...";
    });

    var response = await http.post(
      Uri.parse("$apiUrl/check_fire"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "user_id": user_id,
        "camera_id": cameraIdController.text
      })
    );

    // check to see if the request went well
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);

      // check to see if key exists in the map
      if (body['key'] != null) {
        key = body['key'];                                  // update the global key
        camera_id = cameraIdController.text;                // update the global camera_id
        storeString("key", key!);                           // update the key in local storage
        storeString("camera_id", cameraIdController.text);  // update the camera_id in local storage

        status = "Camera paired successfully!";
      } else {
        status = "Error: Unable to pair camera.";
        PopupAlert(
            "We were unable to pair the camera!",
            "There was an issue paring the camera. Here is the reason phrase: ${response.reasonPhrase}.",
            context
        );
      }
    } else {
      status = "Error: Camera id is already paired with a key!";
      PopupAlert(
          "Unable to pair to camera!",
          "Unable to pair to camera. Have you or someone else already paired to this camera?",
          context
      );
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
        appBar: AppBar(
          title: Text("Pair Your Camera"),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(AppConstants.spacingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header section
              _buildHeaderSection(),
              
              SizedBox(height: AppConstants.spacingL),
              
              // Pairing steps
              _buildPairingSteps(),
              
              SizedBox(height: AppConstants.spacingL),
              
              // Input section
              _buildInputSection(),
              
              SizedBox(height: AppConstants.spacingL),
              
              // Pair button
              _buildPairButton(),
              
              SizedBox(height: AppConstants.spacingL),
              
              // Status section
              _buildStatusSection(),
              
              SizedBox(height: AppConstants.spacingL),
              
              // Help section
              _buildHelpSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return UIHelpers.modernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(AppConstants.spacingM),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                ),
                child: Icon(
                  Icons.camera_alt_rounded,
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
                      "Connect Your Camera",
                      style: AppTypography.h3,
                    ),
                    Text(
                      "Secure your home with fire detection",
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
            "Enter the unique camera ID found in your device packaging to establish a secure connection for fire and gas monitoring.",
            style: AppTypography.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildPairingSteps() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Pairing Steps",
          style: AppTypography.h3,
        ),
        SizedBox(height: AppConstants.spacingM),
        UIHelpers.modernCard(
          child: Column(
            children: [
              _buildStepItem(
                stepNumber: 1,
                title: "Locate Camera ID",
                description: "Find the ID on your camera's packaging or device label",
                icon: Icons.search_rounded,
              ),
              Divider(color: dividerColor),
              _buildStepItem(
                stepNumber: 2,
                title: "Enter Camera ID",
                description: "Type the ID exactly as shown (case-sensitive)",
                icon: Icons.keyboard_rounded,
              ),
              Divider(color: dividerColor),
              _buildStepItem(
                stepNumber: 3,
                title: "Pair Device",
                description: "Tap 'Pair Camera' to establish connection",
                icon: Icons.link_rounded,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStepItem({
    required int stepNumber,
    required String title,
    required String description,
    required IconData icon,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppConstants.spacingS),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(AppConstants.radiusRound),
            ),
            child: Center(
              child: Text(
                stepNumber.toString(),
                style: AppTypography.caption.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(width: AppConstants.spacingM),
          Icon(
            icon,
            color: primaryColor,
            size: AppConstants.iconM,
          ),
          SizedBox(width: AppConstants.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  description,
                  style: AppTypography.bodySmall.copyWith(
                    color: textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Camera Information",
          style: AppTypography.h3,
        ),
        SizedBox(height: AppConstants.spacingM),
        UIHelpers.modernCard(
          child: Column(
            children: [
              TextField(
                controller: cameraIdController,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  labelText: "Camera ID",
                  hintText: "Enter your camera ID (e.g., CAM-ABC123)",
                  prefixIcon: Icon(Icons.videocam_rounded, color: primaryColor),
                  suffixIcon: cameraIdController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear_rounded, color: textSecondaryColor),
                          onPressed: () {
                            setState(() {
                              cameraIdController.clear();
                            });
                          },
                        )
                      : null,
                ),
                onChanged: (value) {
                  setState(() {
                    // Trigger rebuild to show/hide clear button
                  });
                },
              ),
              SizedBox(height: AppConstants.spacingS),
              Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: AppConstants.iconS,
                    color: primaryColor,
                  ),
                  SizedBox(width: AppConstants.spacingXS),
                  Expanded(
                    child: Text(
                      "Camera ID is case-sensitive and typically 8-12 characters long",
                      style: AppTypography.caption.copyWith(
                        color: textSecondaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPairButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : () {
          if (cameraIdController.text.trim().isEmpty) {
            PopupAlert(
              "Missing Camera ID", 
              "Please enter a valid camera ID to continue.", 
              context,
              isError: true,
            );
            return;
          }
          pairCamera();
        },
        icon: _isLoading 
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Icon(Icons.link_rounded),
        label: Text(
          _isLoading ? "Pairing Camera..." : "Pair Camera",
          style: AppTypography.buttonLarge,
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          padding: EdgeInsets.symmetric(vertical: AppConstants.spacingM),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusM),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusSection() {
    Color statusColor = _getStatusColor();
    IconData statusIcon = _getStatusIcon();
    
    return UIHelpers.modernCard(
      backgroundColor: statusColor.withOpacity(0.1),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(AppConstants.spacingS),
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(AppConstants.radiusS),
            ),
            child: Icon(
              statusIcon,
              color: Colors.white,
              size: AppConstants.iconM,
            ),
          ),
          SizedBox(width: AppConstants.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Pairing Status",
                  style: AppTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
                Text(
                  status,
                  style: AppTypography.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Need Help?",
          style: AppTypography.h3,
        ),
        SizedBox(height: AppConstants.spacingM),
        UIHelpers.modernCard(
          child: Column(
            children: [
              ListTile(
                leading: Container(
                  padding: EdgeInsets.all(AppConstants.spacingS),
                  decoration: BoxDecoration(
                    color: successColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppConstants.radiusS),
                  ),
                  child: Icon(
                    Icons.help_outline_rounded,
                    color: successColor,
                    size: AppConstants.iconM,
                  ),
                ),
                title: Text(
                  "Can't find your Camera ID?",
                  style: AppTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  "Check the device label, packaging, or user manual",
                  style: AppTypography.bodySmall,
                ),
                contentPadding: EdgeInsets.zero,
              ),
              Divider(color: dividerColor),
              ListTile(
                leading: Container(
                  padding: EdgeInsets.all(AppConstants.spacingS),
                  decoration: BoxDecoration(
                    color: warningColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppConstants.radiusS),
                  ),
                  child: Icon(
                    Icons.warning_amber_rounded,
                    color: warningColor,
                    size: AppConstants.iconM,
                  ),
                ),
                title: Text(
                  "Already Paired?",
                  style: AppTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  "Each camera can only be paired with one account",
                  style: AppTypography.bodySmall,
                ),
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getStatusColor() {
    if (_isLoading) return warningColor;
    if (status.contains("successfully")) return successColor;
    if (status.contains("Error") || status.contains("Unable")) return accentColor;
    return primaryColor;
  }

  IconData _getStatusIcon() {
    if (_isLoading) return Icons.sync_rounded;
    if (status.contains("successfully")) return Icons.check_circle_rounded;
    if (status.contains("Error") || status.contains("Unable")) return Icons.error_rounded;
    return Icons.info_rounded;
  }
}