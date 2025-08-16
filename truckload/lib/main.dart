import 'package:flutter/material.dart';
import 'package:truckload/screens/caminhoneiros/tela_menu.dart';
import 'package:truckload/screens/tela_inicial.dart';

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
      home: const TelaInicial(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/cadastro': (context) => const CadastroScreen(),
        '/menuCaminhoneiro': (context) => const cam.TelaMenu(),
        '/menuEmpresa': (context) => const emp.TelaMenuEmpresarial(),
      },
    );
  }
}
