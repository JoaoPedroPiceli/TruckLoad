import 'package:flutter/material.dart';

class TelaMenuEmpresa extends StatelessWidget {
  const TelaMenuEmpresa({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6F0FA),
      body: Column(
        children: [
          const SizedBox(height: 60),
          const Text(
            'MENU EMPRESA',
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
                  menuItem(Icons.add_circle_outline, 'Adicionar cargas'),
                  divider(),
                  menuItem(Icons.check_circle_outline, 'Cargas Realizadas'),
                  divider(),
                  menuItem(Icons.business_center, 'Perfil empresarial'),
                  divider(),
                  menuItem(Icons.pending_actions_outlined, 'Cargas Pendentes'),
                  divider(),
                  menuItem(
                    Icons.account_balance_wallet_outlined,
                    'Sistema bancário',
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

  Widget menuItem(IconData icon, String label) {
    return Padding(
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
    );
  }

  Widget divider() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Divider(color: Colors.black54),
    );
  }
}
