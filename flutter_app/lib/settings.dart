import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rain_project/constants.dart';
import 'package:rain_project/device_settings.dart';
import 'package:rain_project/profile_settings.dart';
import 'package:rain_project/splashscreen.dart';
import 'package:http/http.dart' as http;

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  Future<void> handleLogout(BuildContext context) async {
    // clear preferences to remove user data
    await clearPrefs();

    // overwrite session variables
    user_id = null;
    id_token = null;
    camera_id = null;
    key = null;

    // push to the splashscreen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => SplashScreen()),
    );
  }

  /// handle account deletion request
  Future<void> handleDeleteAccount(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Are You Sure?"),
          content: Text(
            "Are you sure you want to delete your account? You will never be able to recover your data or account.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                // delete account
                http.post(
                  Uri.parse("$apiUrl/delete_account"),
                  headers: {"Content-Type": "application/json"},
                  body: jsonEncode({
                    "user_id": user_id,
                    "camera_id": camera_id,
                    "key": key
                  })
                );

                // delete stored data and push to login page
                handleLogout(context);
              },
              child: Text("Confirm"),
            ),
            TextButton(
              onPressed: () {
                // close popup
                Navigator.of(context).pop();
              },
              child: Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text("Settings"),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppConstants.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Account section
            _buildAccountSection(),
            
            SizedBox(height: AppConstants.spacingL),
            
            // Device section
            _buildDeviceSection(),
            
            SizedBox(height: AppConstants.spacingL),
            
            // About section
            _buildAboutSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Account",
          style: AppTypography.h3,
        ),
        SizedBox(height: AppConstants.spacingM),
        UIHelpers.modernCard(
          child: Column(
            children: [
              _buildAccountInfo(),
              Divider(color: dividerColor),
              _buildSettingsTile(
                icon: Icons.person_rounded,
                title: "Profile Settings",
                subtitle: "Manage your account information",
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => ProfileSettings()));
                },
              ),
              _buildSettingsTile(
                icon: Icons.notifications_rounded,
                title: "Notifications",
                subtitle: "Configure alert preferences",
                onTap: () {
                  // TODO: Navigate to notification settings
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAccountInfo() {
    return Padding(
      padding: EdgeInsets.all(AppConstants.spacingM),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(AppConstants.spacingM),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppConstants.radiusRound),
            ),
            child: Icon(
              Icons.account_circle_rounded,
              size: AppConstants.iconXL,
              color: primaryColor,
            ),
          ),
          SizedBox(width: AppConstants.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Your Account",
                  style: AppTypography.h4,
                ),
                Text(
                  user_id != null ? "User ID: $user_id" : "Not signed in",
                  style: AppTypography.caption.copyWith(
                    color: textSecondaryColor,
                  ),
                ),
                SizedBox(height: AppConstants.spacingXS),
                UIHelpers.statusChip(
                  label: "Active",
                  isActive: true,
                  icon: Icons.check_circle_rounded,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceSection() {
    bool isConnected = camera_id != null && key != null;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Connected Devices",
          style: AppTypography.h3,
        ),
        SizedBox(height: AppConstants.spacingM),
        UIHelpers.modernCard(
          child: Column(
            children: [
              _buildDeviceInfo(isConnected),
              if (isConnected) Column(
                children: [
                  Divider(color: dividerColor),
                  _buildSettingsTile(
                    icon: Icons.settings_remote_rounded,
                    title: "Device Settings",
                    subtitle: "Configure camera preferences",
                    onTap: () {
                      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => DeviceSettings()));
                    },
                  ),
                ],
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDeviceInfo(bool isConnected) {
    return Padding(
      padding: EdgeInsets.all(AppConstants.spacingM),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(AppConstants.spacingM),
            decoration: BoxDecoration(
              color: isConnected 
                  ? successColor.withOpacity(0.1) 
                  : textSecondaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppConstants.radiusRound),
            ),
            child: Icon(
              isConnected ? Icons.videocam_rounded : Icons.videocam_off_rounded,
              size: AppConstants.iconL,
              color: isConnected ? successColor : textSecondaryColor,
            ),
          ),
          SizedBox(width: AppConstants.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Fire Detection Camera",
                  style: AppTypography.h4,
                ),
                Text(
                  isConnected 
                      ? "Camera ID: ${camera_id!}..." 
                      : "No camera paired",
                  style: AppTypography.caption.copyWith(
                    color: textSecondaryColor,
                  ),
                ),
                SizedBox(height: AppConstants.spacingXS),
                UIHelpers.statusChip(
                  label: isConnected ? "Connected" : "Not Connected",
                  isActive: isConnected,
                  icon: isConnected ? Icons.check_circle_rounded : Icons.error_outline_rounded,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "About",
          style: AppTypography.h3,
        ),
        SizedBox(height: AppConstants.spacingM),
        UIHelpers.modernCard(
          child: Column(
            children: [
              _buildSettingsTile(
                icon: Icons.info_outline_rounded,
                title: "App Version",
                subtitle: "FireAlert v1.0.0",
                onTap: null,
              ),
              _buildSettingsTile(
                icon: Icons.help_outline_rounded,
                title: "Help & Support",
                subtitle: "Get help with using the app",
                onTap: () {
                  // TODO: Navigate to help
                },
              ),
              _buildSettingsTile(
                icon: Icons.privacy_tip_outlined,
                title: "Privacy Policy",
                subtitle: "Learn about our privacy practices",
                onTap: () {
                  // TODO: Navigate to privacy policy
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
    Color? iconColor,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(AppConstants.spacingS),
        decoration: BoxDecoration(
          color: (iconColor ?? primaryColor).withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppConstants.radiusS),
        ),
        child: Icon(
          icon,
          size: AppConstants.iconM,
          color: iconColor ?? primaryColor,
        ),
      ),
      title: Text(
        title,
        style: AppTypography.bodyLarge.copyWith(
          color: isDestructive ? accentColor : textPrimaryColor,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppTypography.bodySmall,
      ),
      trailing: onTap != null 
          ? Icon(
              Icons.chevron_right_rounded,
              color: textSecondaryColor,
            )
          : null,
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(
        horizontal: AppConstants.spacingM,
        vertical: AppConstants.spacingXS,
      ),
    );
  }
}
