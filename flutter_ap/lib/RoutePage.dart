import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'constants.dart';
import 'homepage.dart';
import 'pairpage.dart';
import 'settings.dart';

class RouteWidget extends StatefulWidget {
  const RouteWidget({super.key});

  @override
  State<RouteWidget> createState() => _RouteWidgetState();
}

class _RouteWidgetState extends State<RouteWidget> {
  int _selectedIndex = 0;
  static const TextStyle optionStyle =
  TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static List<Widget>? _widgetOptions;

  @override
  void initState() {
    super.initState();
    _widgetOptions = [Homepage(), PairPage(), SettingsPage()];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions!.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: primaryColor,
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
                icon: Icon(Icons.home, color: highlightColor),
                label: "Home"
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.pageview_sharp, color: highlightColor),
                label: "Pair"
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.settings, color: highlightColor),
                label: "Settings"
            )
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: secondaryColor,
          onTap: _onItemTapped,
      ),
    );
  }
}
