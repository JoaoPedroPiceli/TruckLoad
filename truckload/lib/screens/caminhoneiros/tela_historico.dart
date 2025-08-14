import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Carga {
  final String empresa;
  final String origem;
  final String destino;
  final double peso;
  final DateTime data;
  bool avaliada;

  Carga({
    required this.empresa,
    required this.origem,
    required this.destino,
    required this.peso,
    required this.data,
    this.avaliada = false,
  });
}

class TelaHistorico extends StatelessWidget {
  TelaHistorico({super.key});

  final List<Carga> cargas = [
    Carga(
      empresa: 'Empresa A',
      origem: 'São Paulo',
      destino: 'Rio de Janeiro',
      peso: 1200,
      data: DateTime.now().subtract(const Duration(days: 10)),
      avaliada: false,
    ),
    Carga(
      empresa: 'Empresa B',
      origem: 'Curitiba',
      destino: 'Porto Alegre',
      peso: 900,
      data: DateTime.now().add(const Duration(days: 5)),
    ),
    Carga(
      empresa: 'Empresa C',
      origem: 'Belo Horizonte',
      destino: 'Vitória',
      peso: 700,
      data: DateTime.now().subtract(const Duration(days: 3)),
      avaliada: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    DateTime hoje = DateTime.now();

    List<Carga> futuras = cargas.where((c) => c.data.isAfter(hoje)).toList();
    List<Carga> realizadas = cargas.where((c) => !c.data.isAfter(hoje)).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFD4E1FF),
      appBar: AppBar(
        title: const Text('Minhas Cargas'),
        backgroundColor: const Color(0xFFB0CCE5),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Futuros Fretes
              if (futuras.isNotEmpty) ...[
                Text(
                  'Futuros Fretes',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.blue[700],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Column(
                  children: futuras.map((carga) => cargaCard(context, carga, futuro: true)).toList(),
                ),
                const SizedBox(height: 20),
              ],

              // Cargas realizadas
              Text(
                'Cargas realizadas',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.blue[700],
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Column(
                children: realizadas.map((carga) => cargaCard(context, carga, futuro: false)).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget cargaCard(BuildContext context, Carga carga, {required bool futuro}) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF9CB9E3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Ícone da empresa
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white,
            child: Icon(Icons.person, size: 30, color: Colors.grey[800]),
          ),

          const SizedBox(width: 12),

          // Dados da carga
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CARGA',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                Text('Empresa: ${carga.empresa}'),
                Text('Origem: ${carga.origem}'),
                Text('Destino: ${carga.destino}'),
                Text('Peso: ${carga.peso} kg'),
                Text('Data: ${dateFormat.format(carga.data)}'),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Botão de ação
          futuro
              ? ElevatedButton(
                  onPressed: () {
                    // Cancelar carga futura
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Carga cancelada')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                  ),
                  child: const Text('CANCELAR'),
                )
              : carga.avaliada
                  ? Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white,
                      ),
                      child: const Text(
                        'CARGA AVALIADA',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                    )
                  : ElevatedButton(
                      onPressed: () {
                        // Avaliar carga
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Avaliar carga de ${carga.empresa}')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                      ),
                      child: const Text('AVALIAR CARGA'),
                    ),
        ],
      ),
    );
  }
}