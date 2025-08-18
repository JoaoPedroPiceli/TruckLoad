import 'package:flutter/material.dart';
import 'package:truckload/screens/caminhoneiros/tela_FiltroCarga.dart';
import 'package:truckload/screens/caminhoneiros/tela_MeuPerfil.dart';
import 'package:truckload/screens/caminhoneiros/tela_bancario.dart';
import 'package:truckload/screens/caminhoneiros/tela_historico.dart';

class TelaMenu extends StatelessWidget {
  final String userId; // <- precisa do id do usuário
  const TelaMenu({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6F0FA),
      body: Column(
        children: [
          const SizedBox(height: 60),
          const Text(
            'MENU',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
                  menuItem(context, Icons.person, 'Meu perfil', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            TelaMeuPerfil(userId: userId), // <- passa o id
                      ),
                    );
                  }),
                  divider(),
                  menuItem(context, Icons.search, 'Procurar carga', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TelaFiltroCarga(userId: userId),
                      ),
                    );
                  }),
                  divider(),
                  menuItem(
                    context,
                    Icons.calendar_today,
                    'Histórico de cargas',
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TelaHistorico(userId: userId),
                        ),
                      );
                    },
                  ),
                  divider(),
                  menuItem(context, Icons.attach_money, 'Sistema bancário', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TelaBancario(userId: userId),
                      ),
                    );
                  }),
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
