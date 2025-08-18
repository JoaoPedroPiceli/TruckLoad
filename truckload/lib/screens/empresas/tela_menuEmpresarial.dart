import 'package:flutter/material.dart';
import 'package:truckload/screens/empresas/tela_adicionarcarga.dart';
import 'package:truckload/screens/empresas/tela_cargasRealizadas.dart';
import 'package:truckload/screens/empresas/tela_cargasPendentes.dart';
import 'package:truckload/screens/empresas/tela_perfilEmpresarial.dart';

class TelaMenuEmpresa extends StatelessWidget {
  final String empresaId;

  const TelaMenuEmpresa({super.key, required this.empresaId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6F0FA),
      body: Column(
        children: [
          const SizedBox(height: 60),
          const Text(
            'MENU',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 30),
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: const Color(0xFFB0CCE5),
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
                          builder: (context) =>
                              TelaPerfilEmpresa(empresaId: empresaId),
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
                          builder: (context) =>
                              AdicionarCarga(empresaId: empresaId),
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
                          builder: (context) =>
                              CargasRealizadas(empresaId: empresaId),
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
                          builder: (context) =>
                              CargasPendentes(empresaId: empresaId),
                        ),
                      );
                    },
                  ),
                  divider(),
                  const Spacer(),
                  Image.asset('assets/logo.png', height: 60),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget menuItem(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
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
