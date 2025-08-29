import 'package:flutter/material.dart';
import 'package:safe_driver/home_screen.dart';
import 'package:safe_driver/login.dart';
import 'package:safe_driver/monitoring.dart';
import 'package:safe_driver/ranking.dart';
import 'package:safe_driver/signUpScreen.dart'; // Importa a nova tela

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SafeDriver',
      theme: ThemeData(
        // Define um tema base para o app
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        // Define a fonte padrão para combinar com o design
        fontFamily: 'sans-serif',
      ),
      // A tela principal do nosso app agora é a LoginScreen
      home: const RankingScreen(),
      debugShowCheckedModeBanner: false, // Remove o banner de "Debug"
    );
  }
}