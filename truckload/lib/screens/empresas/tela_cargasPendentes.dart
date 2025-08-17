import 'package:flutter/material.dart'; 
import 'package:intl/intl.dart';
import 'package:truckload/screens/empresas/tela_menuEmpresarial.dart';
import 'package:truckload/screens/empresas/tela_editarCarga.dart';
import 'package:truckload/screens/empresas/tela_deletarCargas.dart';

// modelo de Carga
class Carga {
  final String origem;
  final String destino;
  final double peso;
  final DateTime data;
  String? motorista;
  bool aprovada;

  Carga({
    required this.origem,
    required this.destino,
    required this.peso,
    required this.data,
    this.aprovada = false,
    this.motorista,
  });
}

class CargasPendentes extends StatefulWidget {
  const CargasPendentes({super.key});

  @override
  State<CargasPendentes> createState() => _CargasPendentesState();
}

class _CargasPendentesState extends State<CargasPendentes> {
  final List<Carga> cargas = [
    Carga(
      origem: 'São Paulo',
      destino: 'Rio de Janeiro',
      peso: 1200,
      data: DateTime.now(),
      aprovada: false,
    ),
    Carga(
      origem: 'Curitiba',
      destino: 'Porto Alegre',
      peso: 900,
      data: DateTime.now().subtract(const Duration(days: 2)),
      aprovada: true,
      motorista: "Carlos",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    List<Carga> pendentes = cargas.where((c) => !c.aprovada).toList();
    List<Carga> aprovadas = cargas.where((c) => c.aprovada).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFE6F0FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black87),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const TelaMenuEmpresa()),
            );
          },
        ),
        title: const Text(
          "Gerenciar Cargas",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      extendBodyBehindAppBar: true,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(12, 80, 12, 12),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pendentes
              if (pendentes.isNotEmpty) ...[
                const Text(
                  "Cargas Pendentes",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Column(
                  children: pendentes
                      .map((c) => cargaCard(context, c, pendente: true))
                      .toList(),
                ),
                const SizedBox(height: 20),
              ],

              // Aprovadas
              if (aprovadas.isNotEmpty) ...[
                const Text(
                  "Cargas Aprovadas",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Column(
                  children: aprovadas
                      .map((c) => cargaCard(context, c, pendente: false))
                      .toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget cargaCard(BuildContext context, Carga carga,
      {required bool pendente}) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFB0CCE5),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // linha superior
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.white,
                child: Icon(Icons.local_shipping,
                    size: 28, color: Colors.grey[800]),
              ),
              const SizedBox(width: 12),

              // dados da carga
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'CARGA',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text("Origem: ${carga.origem}"),
                    Text("Destino: ${carga.destino}"),
                    Text("Peso: ${carga.peso} kg"),
                    Text("Data: ${dateFormat.format(carga.data)}"),
                    Text(
                      "Motorista: ${carga.motorista ?? 'Esperando seleção'}",
                      style: const TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ),

              // Botões editar/deletar
              Column(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.white),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditarCarga(
                            carga: {
                              "origem": carga.origem,
                              "destino": carga.destino,
                              "peso": carga.peso,
                              "data": carga.data,
                              "motorista": carga.motorista,
                              "aprovada": carga.aprovada,
                            },
                            motoristaSelecionado: carga.motorista != null,
                          ),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TelaDeletarCarga(
                            onDelete: () {
                              setState(() {
                                cargas.remove(carga); // só remove depois que confirmar na tela
                              });
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}