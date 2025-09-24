import 'package:flutter/material.dart';
import 'constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'splashscreen.dart';

class ProfileSettings extends StatefulWidget {
  const ProfileSettings({super.key});

  @override
  State<ProfileSettings> createState() => _ProfileSettingsState();
}

class _ProfileSettingsState extends State<ProfileSettings> {

  // handle logout request
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

   Widget _buildSecuritySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Security & Privacy",
          style: AppTypography.h3,
        ),
        SizedBox(height: AppConstants.spacingM),
        UIHelpers.modernCard(
          child: Column(
            children: [
              _buildSettingsTile(
                icon: Icons.logout_rounded,
                title: "Sign Out",
                subtitle: "Sign out of your account",
                onTap: () => _showLogoutDialog(context),
                iconColor: primaryColor,
              ),
              Divider(color: dividerColor),
              _buildSettingsTile(
                icon: Icons.delete_forever_rounded,
                title: "Delete Account",
                subtitle: "Permanently delete your account and data",
                onTap: () => handleDeleteAccount(context),
                iconColor: accentColor,
                isDestructive: true,
              ),
            ],
          ),
        ),
        SizedBox(height: AppConstants.spacingS),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppConstants.spacingM),
          child: Text(
            "⚠️ Account deletion is permanent and cannot be undone. All your data will be permanently removed.",
            style: AppTypography.caption.copyWith(
              color: accentColor,
            ),
          ),
        ),
      ],
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
            _buildSecuritySection()
          ],
        ),
      ),
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

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusL),
          ),
          title: Row(
            children: [
              Icon(
                Icons.logout_rounded,
                color: primaryColor,
                size: AppConstants.iconM,
              ),
              SizedBox(width: AppConstants.spacingS),
              Text(
                "Sign Out",
                style: AppTypography.h4.copyWith(color: primaryColor),
              ),
            ],
          ),
          content: Text(
            "Are you sure you want to sign out of your account?",
            style: AppTypography.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
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
                handleLogout(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
              ),
              child: Text(
                "Sign Out",
                style: AppTypography.buttonMedium,
              ),
            ),
          ],
        );
      },
    );
  }
}
