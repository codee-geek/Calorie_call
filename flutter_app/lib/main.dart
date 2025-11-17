import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/api_service.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Provider<ApiService>(
      create: (_) => ApiService(baseUrl: 'http://localhost:8000'),
      child: MaterialApp(
        title: 'HealthyFy Me',
        theme: ThemeData(
          primarySwatch: Colors.green,
          useMaterial3: true,
        ),
        home: const LoginScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

