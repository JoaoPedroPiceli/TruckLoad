import 'package:flutter/material.dart';
import 'screens/tela_inicial.dart'; // Corrigido para o nome correto

void main() {
  runApp(const TruckLoadApp());
}

class TruckLoadApp extends StatelessWidget {
  const TruckLoadApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TruckLoad',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      // Tela inicial do app
      home: const TelaInicial(),
    );
  }
}
