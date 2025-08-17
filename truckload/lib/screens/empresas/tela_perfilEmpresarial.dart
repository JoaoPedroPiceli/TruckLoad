import 'package:flutter/material.dart';
import 'package:truckload/screens/empresas/tela_menuEmpresarial.dart';
import 'package:truckload/screens/empresas/tela_cargasRealizadas.dart';

class TelaPerfilEmpresa extends StatelessWidget {
  final String nomeEmpresa = "Nome da Empresa";
  final String cnpj = "00.000.000/0000-00";
  final String localizacao = "São Paulo - SP";
  final String contato = "(11) 99999-9999";
  final String email = "empresa@email.com";
  final String regras = "Regras e diretrizes da empresa";

  TelaPerfilEmpresa({super.key});

  // Função para calcular a nota da empresa com base nas cargas
  double calcularNota(List<Carga> cargas) {
    if (cargas.isEmpty) return 0.0;

    int avaliadas = cargas.where((c) => c.avaliada).length;
    return (avaliadas / cargas.length) * 5.0;
  }

  @override
  Widget build(BuildContext context) {
    // mudar aqui pro banco de dados)
    final List<Carga> cargas = [
      Carga(motorista: "João Silva", origem: "São Paulo", destino: "RJ", peso: "1500kg", data: "12/08/2025", avaliada: true),
      Carga(motorista: "Maria Souza", origem: "BH", destino: "Curitiba", peso: "800kg", data: "10/08/2025"),
      Carga(motorista: "Carlos Lima", origem: "Fortaleza", destino: "Recife", peso: "2000kg", data: "05/08/2025", avaliada: true),
    ];

    double nota = calcularNota(cargas);

    return Scaffold(
      backgroundColor: const Color(0xFFE6F0FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const TelaMenuEmpresa()),
            );
          },
        ),
        title: Text(
          nomeEmpresa,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundColor: Colors.grey,
              child: Icon(Icons.business, color: Colors.white, size: 40),
            ),
            const SizedBox(height: 15),

            buildInfoItem(
              Icons.star,
              "Avaliação:",
              "${nota.toStringAsFixed(1)} / 5.0 (de ${cargas.length} cargas)",
              iconColor: Colors.amber,
            ),
            buildInfoItem(Icons.badge, "CNPJ:", cnpj),
            buildInfoItem(Icons.location_on, "Localização:", localizacao),
            buildInfoItem(Icons.phone, "Contato:", contato),
            buildInfoItem(Icons.email, "Email:", email),
            buildInfoItem(Icons.rule, "Regras e diretrizes:", regras),

            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[300],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              onPressed: () {},
              icon: const Icon(Icons.edit, color: Colors.black),
              label: const Text("Alterar dados", style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildInfoItem(IconData icon, String label, String value, {Color iconColor = Colors.black}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFB0CCE5),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              children: [
                Icon(icon, color: iconColor),
                const SizedBox(width: 8),
                Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}