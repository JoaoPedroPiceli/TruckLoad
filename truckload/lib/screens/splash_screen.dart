import 'package:flutter/material.dart';
import 'package:truckload/screens/tela_inicial.dart';
import 'package:truckload/screens/caminhoneiros/tela_menu.dart';
import 'package:truckload/screens/empresas/tela_menuEmpresarial.dart';
import 'package:truckload/services/session_manager.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    // Aguardar um pouco para mostrar o splash
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Verificar se há sessão ativa
    final hasSession = await SessionManager.hasActiveSession();

    if (!mounted) return;

    if (hasSession) {
      // Obter dados da sessão
      final user = await SessionManager.getCurrentUser();

      if (!mounted) return;

      if (user != null) {
        // Navegar para o menu apropriado
        if (user['tipo'] == 'caminhoneiro') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => TelaMenu(userId: user['userId']),
            ),
          );
        } else if (user['tipo'] == 'empresa') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  TelaMenuEmpresa(empresaId: user['empresaId']),
            ),
          );
        } else {
          // Tipo desconhecido, ir para tela inicial
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const TelaInicial()),
          );
        }
      } else {
        // Sessão inválida, ir para tela inicial
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const TelaInicial()),
        );
      }
    } else {
      // Sem sessão, ir para tela inicial
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const TelaInicial()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6F0FA),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo com borda
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blueAccent, width: 2),
              ),
              padding: const EdgeInsets.all(16.0),
              child: Image.asset('assets/logo.png', height: 120),
            ),
            const SizedBox(height: 24),
            const Text(
              'TruckLoad',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
            ),
            const SizedBox(height: 16),
            const Text(
              'Carregando...',
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
