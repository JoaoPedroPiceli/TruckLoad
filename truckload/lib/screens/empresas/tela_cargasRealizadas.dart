import 'package:flutter/material.dart';
import 'package:truckload/screens/empresas/tela_menuEmpresarial.dart';

// modelo da Carga
class Carga {
  final String motorista;
  final String origem;
  final String destino;
  final String peso;
  final String data;
  bool avaliada;

  Carga({
    required this.motorista,
    required this.origem,
    required this.destino,
    required this.peso,
    required this.data,
    this.avaliada = false,
  });
}

class CargasRealizadas extends StatefulWidget {
  const CargasRealizadas({super.key});

  @override
  State<CargasRealizadas> createState() => _CargasRealizadasState();
}

class _CargasRealizadasState extends State<CargasRealizadas> {
  // Lista dinâmica de cargas
  final List<Carga> cargas = [
    Carga(motorista: "João Silva", origem: "São Paulo", destino: "Rio de Janeiro", peso: "1500kg", data: "12/08/2025"),
    Carga(motorista: "Maria Souza", origem: "Belo Horizonte", destino: "Curitiba", peso: "800kg", data: "10/08/2025", avaliada: true),
    Carga(motorista: "Carlos Lima", origem: "Fortaleza", destino: "Recife", peso: "2000kg", data: "05/08/2025", avaliada: true),
    Carga(motorista: "Ana Paula", origem: "Brasília", destino: "Goiânia", peso: "500kg", data: "01/08/2025"),
  ];

  @override
  Widget build(BuildContext context) {
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
        title: const Text(
          "Cargas Realizadas:",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: false,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: cargas.length,
        itemBuilder: (context, index) {
          final carga = cargas[index];
          return cargaCard(carga, index);
        },
      ),
    );
  }

  Widget cargaCard(Carga carga, int index) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color:  const Color(0xFFB0CCE5),
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ícone do motorista
            const CircleAvatar(
              radius: 25,
              backgroundColor: Colors.grey,
              child: Icon(Icons.person, color: Colors.white, size: 30),
            ),
            const SizedBox(width: 12),

            // Informações da carga
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("CARGA", style: TextStyle(fontWeight: FontWeight.bold)),
                  Text("Motorista: ${carga.motorista}"),
                  Text("Origem: ${carga.origem}"),
                  Text("Destino: ${carga.destino}"),
                  Text("Peso: ${carga.peso}"),
                  Text("Data: ${carga.data}"),
                ],
              ),
            ),

            
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: carga.avaliada ? Colors.grey[300] : Colors.blue[300],
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: carga.avaliada
                      ? null
                      : () {
                          setState(() {
                            cargas[index].avaliada = true; // altera estado da carga
                          });
                        },
                  child: Text(carga.avaliada ? "CARGA AVALIADA" : "AVALIAR CARGA"),
                ),
                const SizedBox(height: 6),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {},
                  child: const Text("Pagamento efetuado"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}