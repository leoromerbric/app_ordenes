import 'package:flutter/material.dart';
import 'screens/bandeja_screen.dart';

void main() {
  runApp(const AppOrdenes());
}

class AppOrdenes extends StatelessWidget {
  const AppOrdenes({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Órdenes - Gestión de Producción',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const BandejaScreen(),
    );
  }
}