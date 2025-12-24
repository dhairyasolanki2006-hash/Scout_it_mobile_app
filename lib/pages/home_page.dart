// HomePage.dart
import 'package:flutter/material.dart';
import 'scout_page.dart'; // <-- Add this import
import 'scanner_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            color: Color(0xFF002E6A),
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTextButton(0, 'SCOUT'),
                _buildTextButton(1, 'SCANNER'),
                _buildTextButton(2, 'ADMIN'),
              ],
            ),
          ),
          SizedBox(height: 20), // Space between menu and body
          Expanded(
            child: _getPageContent(_selectedPageIndex),
          ),
        ],
      ),
    );
  }

  Widget _getPageContent(int index) {
    switch (index) {
      case 0:
        return ScoutPage(); // <--- New
      case 1:
        return ScannerPage();
      case 2:
        return Center(child: Text('Admin Page'));
      default:
        return SizedBox();
    }
  }

  Widget _buildTextButton(int index, String title) {
    return TextButton(
      style: TextButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        foregroundColor: _selectedPageIndex == index ? Colors.orange : Colors.white,
        textStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
      onPressed: () {
        setState(() {
          _selectedPageIndex = index;
        });
      },
      child: Text(title),
    );
  }
}
