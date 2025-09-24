import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rain_project/constants.dart';
import 'package:rain_project/homepage.dart';
import 'package:rain_project/pairpage.dart';
import 'package:rain_project/settings.dart';

class RouteWidget extends StatefulWidget {
  const RouteWidget({super.key});

  @override
  State<RouteWidget> createState() => _RouteWidgetState();
}

class _RouteWidgetState extends State<RouteWidget> {

  List<Widget> _pageOptions = [homepage(), PairPage(), SettingsPage()]; // eventually will hold camera and settings pages
  int _selectedPageIndex = 0; // represents which pages should be loaded from _pageOptions

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedPageIndex,
        children: _pageOptions,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: AppConstants.elevationM,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: _buildNavIcon(Icons.home_rounded, 0),
              activeIcon: _buildNavIcon(Icons.home_rounded, 0, isActive: true),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: _buildNavIcon(Icons.link_rounded, 1),
              activeIcon: _buildNavIcon(Icons.link_rounded, 1, isActive: true),
              label: "Pair Device",
            ),
            BottomNavigationBarItem(
              icon: _buildNavIcon(Icons.settings_rounded, 2),
              activeIcon: _buildNavIcon(Icons.settings_rounded, 2, isActive: true),
              label: "Settings",
            ),
          ],
          currentIndex: _selectedPageIndex,
          selectedItemColor: primaryColor,
          unselectedItemColor: textSecondaryColor,
          selectedLabelStyle: AppTypography.caption.copyWith(
            fontWeight: FontWeight.w600,
            color: primaryColor,
          ),
          unselectedLabelStyle: AppTypography.caption,
          type: BottomNavigationBarType.fixed,
          backgroundColor: surfaceColor,
          elevation: 0,
          onTap: (index) {
            setState(() {
              _selectedPageIndex = index;
            });
          },
        ),
      ),
    );
  }

  Widget _buildNavIcon(IconData icon, int index, {bool isActive = false}) {
    return AnimatedContainer(
      duration: AppConstants.animationFast,
      padding: EdgeInsets.symmetric(
        horizontal: AppConstants.spacingM,
        vertical: AppConstants.spacingXS,
      ),
      decoration: BoxDecoration(
        color: isActive ? primaryColor.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(AppConstants.radiusS),
      ),
      child: Icon(
        icon,
        size: AppConstants.iconM,
        color: isActive ? primaryColor : textSecondaryColor,
      ),
    );
  }
}
