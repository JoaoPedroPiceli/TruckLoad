import 'package:flutter/material.dart';
import 'package:truckload/screens/caminhoneiros/tela_menu.dart';
import 'package:truckload/screens/caminhoneiros/tela_editardados.dart';

class TelaMeuPerfil extends StatelessWidget {
  final List<double> avaliacoes = [4.0, 5.0, 3.5, 4.5];
  final double taxaCancelamento = 0.15;
  final String contato = '(11) 99999-9999';
  final String descricao = 'Experiência em cargas frigoríficas e secas.';
  final String nome = 'João Pedro Piceli';

  TelaMeuPerfil({super.key});

  double get mediaAvaliacao {
    if (avaliacoes.isEmpty) return 0.0;
    return avaliacoes.reduce((a, b) => a + b) / avaliacoes.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6F0FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE6F0FA),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const TelaMenu()),
            );
          },
        ),
      ),
      body: SingleChildScrollView( // 👈 evita overflow
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundColor: Colors.grey,
              child: Icon(Icons.person, size: 40, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(
              nome,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            campoInfo(
              icon: Icons.star,
              label: 'Avaliação:',
              value:
                  '${mediaAvaliacao.toStringAsFixed(1)} / 5 ⭐ (${avaliacoes.length} cargas)',
            ),
            campoInfo(
              icon: Icons.cancel,
              label: 'Taxa de cancelamentos:',
              value: '${(taxaCancelamento * 100).toStringAsFixed(1)}%',
            ),
            campoInfo(
              icon: Icons.phone,
              label: 'Contato:',
              value: contato,
            ),
            campoInfo(
              icon: Icons.description,
              label: 'Descrição:',
              value: descricao,
            ),
            const SizedBox(height: 30), // 👈 substitui Spacer()
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AlterarDados(),
                  ),
                );
              },
              icon: const Icon(Icons.edit, color: Colors.black),
              label: const Text(
                'Alterar dados',
                style: TextStyle(color: Colors.black),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Image.asset('assets/logo.png', height: 50),
          ],
        ),
      ),
    );
  }

  Widget campoInfo({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFB0CCE5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon),
          const SizedBox(width: 10),
          Expanded(
            child: Text.rich(
              TextSpan(
                text: '$label ',
                style: const TextStyle(fontWeight: FontWeight.bold),
                children: [
                  TextSpan(
                    text: value,
                    style: const TextStyle(fontWeight: FontWeight.normal),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
