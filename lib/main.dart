import 'package:flutter/material.dart';
import 'screens/dashboard_screen.dart';

void main() {
  runApp(const AccidentAlertApp());
}

class AccidentAlertApp extends StatelessWidget {
  const AccidentAlertApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Accident Alert',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.redAccent,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.redAccent,
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.system,
      home: const DashboardScreen(), // Go straight to Dashboard
    );
  }
}
