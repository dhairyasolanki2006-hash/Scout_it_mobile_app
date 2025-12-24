// Import the Flutter Material library (for UI stuff like buttons, pages, etc.)
import 'package:flutter/material.dart';

// Import the LoginPage we will create (from the 'pages' folder)
import 'pages/login_page.dart';

// The main function: This is where the app starts running
void main() {
  runApp(MyApp());  // Runs the MyApp widget
}

// MyApp widget: This is the root of the app
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scouting App',  // Title of the app
      theme: ThemeData(
        primarySwatch: Colors.blue,  // Set the theme color to blue
      ),
      home: LoginPage(),  // The first screen the user sees is the Login Page
      debugShowCheckedModeBanner: false,  // Remove the debug banner in the corner
    );
  }
}
