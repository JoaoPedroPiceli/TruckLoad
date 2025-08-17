import 'package:flutter/material.dart';
import 'package:truckload/screens/caminhoneiros/tela_menu.dart';
import 'package:truckload/screens/tela_inicial.dart';
import 'package:truckload/screens/empresas/tela_menuEmpresarial.dart';
import 'package:truckload/screens/tela_login.dart';
import 'package:truckload/screens/cadastro_screen.dart';

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
      home: const TelaMenuEmpresa(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/cadastro': (context) => const CadastroScreen(),
        '/menuCaminhoneiro': (context) => const TelaMenu(),
        '/menuEmpresa': (context) => const TelaMenuEmpresa(),
      },
    );
  }
}
