import 'package:flutter/material.dart';
import 'package:truckload/screens/empresarial/tela_adicionarCarga.dart';
import 'package:truckload/screens/empresarial/tela_cargasRealizadas.dart';
import 'package:truckload/screens/empresarial/tela_cargaPendente.dart';
import 'package:truckload/screens/empresarial/tela_sistemaBancarioEmpresarial.dart';
import 'package:truckload/screens/empresarial/tela_perfilEmpresarial.dart';

class TelaMenuEmpresa extends StatelessWidget {
  const TelaMenuEmpresa({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6F0FA), // Fundo azul claro
      body: Column(
        children: [
          const SizedBox(height: 60),
          const Text(
            'MENU EMPRESA',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 30),
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: const Color(0xFFB0CCE5), // Caixa azul
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  menuItem(
                    context,
                    Icons.business_center,
                    'Perfil empresarial',
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TelaPerfilEmpresarial(),
                        ),
                      );
                    },
                  ),
                  divider(),
                  menuItem(
                    context,
                    Icons.add_circle_outline,
                    'Adicionar cargas',
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TelaAdicionarCarga(),
                        ),
                      );
                    },
                  ),
                  divider(),
                  menuItem(
                    context,
                    Icons.check_circle_outline,
                    'Cargas Realizadas',
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TelaCargaRealizada(),
                        ),
                      );
                    },
                  ),
                  divider(),
                  menuItem(
                    context,
                    Icons.pending_actions_outlined,
                    'Cargas Pendentes',
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TelaCargaPendente(),
                        ),
                      );
                    },
                  ),
                  divider(),
                  menuItem(
                    context,
                    Icons.account_balance_wallet_outlined,
                    'Sistema bancário',
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const TelaSistemaBancarioEmpresarial(),
                        ),
                      );
                    },
                  ),
                  divider(),
                  const Spacer(),
                  Image.asset('assets/logo.png', height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget menuItem(
      BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        child: Row(
          children: [
            Icon(icon, size: 28, color: Colors.black87),
            const SizedBox(width: 16),
            Text(
              label,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget divider() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Divider(color: Colors.black54),
    );
  }
}