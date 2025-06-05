import 'package:flutter/material.dart';
import 'package:truckload/screens/cadastro_screen.dart';

class TelaInicial extends StatelessWidget {
  const TelaInicial({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6F0FA), // Azul claro
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo com borda
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blueAccent, width: 2),
                ),
                padding: const EdgeInsets.all(16.0),
                child: Image.asset(
                  'assets/logo.png', // Ajuste esse caminho conforme sua logo
                  height: 120,
                ),
              ),
              const SizedBox(height: 24),

              // Texto de boas-vindas
              const Text(
                'Seja bem vindo!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 40),

              // Botão Login
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Navegar para tela de login futuramente
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black87,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('LOG IN'),
                ),
              ),
              const SizedBox(height: 16),

              // Botão Criar Conta
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CadastroScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black87,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('CRIAR CONTA'),
                ),
              ),
              const SizedBox(height: 8),

              // Texto informativo
              const Text(
                'NÃO TEM UMA CONTA?',
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
