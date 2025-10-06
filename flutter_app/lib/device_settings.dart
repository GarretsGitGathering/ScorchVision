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
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          "Device Settings",
          style: AppTypography.h3.copyWith(color: Colors.white),
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: AppConstants.elevationS,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppConstants.spacingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header section
              _buildHeaderSection(),
              
              SizedBox(height: AppConstants.spacingXL),
              
              // Device control section
              _buildDeviceControlSection(),
              
              SizedBox(height: AppConstants.spacingXL),
              
              // Device information section
              _buildDeviceInfoSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return UIHelpers.modernCard(
      backgroundColor: primaryColor.withOpacity(0.05),
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
                  Icons.settings_rounded,
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
                      "Device Management",
                      style: AppTypography.h3.copyWith(
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: AppConstants.spacingXS),
                    Text(
                      "Control and monitor your fire detection device",
                      style: AppTypography.bodyMedium.copyWith(
                        color: textSecondaryColor,
                      ),
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

  Widget _buildDeviceControlSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Device Controls",
          style: AppTypography.h4.copyWith(
            color: textPrimaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: AppConstants.spacingM),
        
        // Power control card
        UIHelpers.modernCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(AppConstants.spacingS),
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppConstants.radiusS),
                    ),
                    child: Icon(
                      Icons.power_settings_new_rounded,
                      color: accentColor,
                      size: AppConstants.iconM,
                    ),
                  ),
                  SizedBox(width: AppConstants.spacingM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Power Control",
                          style: AppTypography.h4.copyWith(
                            color: textPrimaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: AppConstants.spacingXS),
                        Text(
                          "Safely power off your device remotely",
                          style: AppTypography.bodyMedium.copyWith(
                            color: textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: AppConstants.spacingL),
              
              // Warning message
              Container(
                padding: EdgeInsets.all(AppConstants.spacingM),
                decoration: BoxDecoration(
                  color: warningColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppConstants.radiusS),
                  border: Border.all(
                    color: warningColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_rounded,
                      color: warningColor,
                      size: AppConstants.iconM,
                    ),
                    SizedBox(width: AppConstants.spacingM),
                    Expanded(
                      child: Text(
                        "This will completely shut down your device. You'll need to manually power it back on.",
                        style: AppTypography.bodySmall.copyWith(
                          color: textPrimaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: AppConstants.spacingL),
              
              // Power off button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _showShutdownConfirmation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: AppConstants.spacingM),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppConstants.radiusM),
                    ),
                    elevation: AppConstants.elevationS,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.power_off_rounded,
                        size: AppConstants.iconM,
                      ),
                      SizedBox(width: AppConstants.spacingS),
                      Text(
                        "Shutdown Device",
                        style: AppTypography.buttonLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDeviceInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Device Information",
          style: AppTypography.h4.copyWith(
            color: textPrimaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: AppConstants.spacingM),
        
        UIHelpers.modernCard(
          child: Column(
            children: [
              _buildInfoRow(
                icon: Icons.device_thermostat_rounded,
                label: "Device Status",
                value: "Online",
                isActive: true,
              ),
              Divider(color: dividerColor, height: AppConstants.spacingL),
              _buildInfoRow(
                icon: Icons.security_rounded,
                label: "Security",
                value: "Protected",
                isActive: true,
              ),
              Divider(color: dividerColor, height: AppConstants.spacingL),
              _buildInfoRow(
                icon: Icons.signal_cellular_alt_rounded,
                label: "Connection",
                value: "Stable",
                isActive: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required bool isActive,
  }) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(AppConstants.spacingS),
          decoration: BoxDecoration(
            color: isActive ? successColor.withOpacity(0.1) : textSecondaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppConstants.radiusS),
          ),
          child: Icon(
            icon,
            color: isActive ? successColor : textSecondaryColor,
            size: AppConstants.iconM,
          ),
        ),
        SizedBox(width: AppConstants.spacingM),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTypography.label.copyWith(
                  color: textSecondaryColor,
                ),
              ),
              SizedBox(height: AppConstants.spacingXS),
              Text(
                value,
                style: AppTypography.bodyMedium.copyWith(
                  color: textPrimaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        UIHelpers.statusChip(
          label: isActive ? "Active" : "Inactive",
          isActive: isActive,
        ),
      ],
    );
  }

  void _showShutdownConfirmation() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusL),
          ),
          title: Row(
            children: [
              Icon(
                Icons.warning_rounded,
                color: accentColor,
                size: AppConstants.iconL,
              ),
              SizedBox(width: AppConstants.spacingM),
              Expanded(
                child: Text(
                  "Confirm Shutdown",
                  style: AppTypography.h4.copyWith(
                    color: accentColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Are you sure you want to shutdown your device?",
                style: AppTypography.bodyMedium.copyWith(
                  color: textPrimaryColor,
                ),
              ),
              SizedBox(height: AppConstants.spacingM),
              Container(
                padding: EdgeInsets.all(AppConstants.spacingM),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppConstants.radiusS),
                  border: Border.all(
                    color: accentColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_rounded,
                      color: accentColor,
                      size: AppConstants.iconM,
                    ),
                    SizedBox(width: AppConstants.spacingM),
                    Expanded(
                      child: Text(
                        "This action cannot be undone remotely. You'll need to manually power the device back on.",
                        style: AppTypography.bodySmall.copyWith(
                          color: textPrimaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: textSecondaryColor,
                padding: EdgeInsets.symmetric(
                  horizontal: AppConstants.spacingL,
                  vertical: AppConstants.spacingM,
                ),
              ),
              child: Text(
                "Cancel",
                style: AppTypography.buttonMedium.copyWith(
                  color: textSecondaryColor,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                shutOffHardware();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: AppConstants.spacingL,
                  vertical: AppConstants.spacingM,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                ),
                elevation: AppConstants.elevationS,
              ),
              child: Text(
                "Shutdown",
                style: AppTypography.buttonMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}


