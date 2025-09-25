import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:truckload/services/api_service.dart';
import 'package:truckload/models/carga.dart';

class TelaHistorico extends StatefulWidget {
  final String userId;

  const TelaHistorico({super.key, required this.userId});

  @override
  State<TelaHistorico> createState() => _TelaHistoricoState();
}

class _TelaHistoricoState extends State<TelaHistorico> {
  bool _loading = true;
  String? _error;
  List<Carga> _cargas = [];
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _carregarCargas();
  }

  Future<void> _carregarCargas() async {
    if (!mounted) return;
    
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final cargasData = await _apiService.getCargasCaminhoneiro(widget.userId);
      final cargas = cargasData.map((json) => Carga.fromJson(json)).toList();

      if (mounted) {
        setState(() {
          _cargas = cargas;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: const Color(0xFFD4E1FF),
        appBar: AppBar(
          title: const Text('Minhas Cargas'),
          backgroundColor: const Color(0xFFB0CCE5),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: const Color(0xFFD4E1FF),
        appBar: AppBar(
          title: const Text('Minhas Cargas'),
          backgroundColor: const Color(0xFFB0CCE5),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Erro: $_error'),
              ElevatedButton(
                onPressed: _carregarCargas,
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }

    // Agrupar por status, independente da data
    final aceitas = _cargas.where((c) => c.status == 'aceita').toList();
    final concluidas = _cargas.where((c) => c.status == 'concluida').toList();

    return Scaffold(
      backgroundColor: const Color(0xFFD4E1FF),
      appBar: AppBar(
        title: const Text('Minhas Cargas'),
        backgroundColor: const Color(0xFFB0CCE5),
      ),
      body: _cargas.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox_outlined, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhuma carga encontrada',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Você ainda não possui cargas registradas.',
                    style: TextStyle(fontSize: 16, color: Colors.grey[500]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Voltar ao Menu'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(12),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Cargas Aceitas
                    if (aceitas.isNotEmpty) ...[
                      Text(
                        'Cargas aceitas',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.blue[700],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Column(
                        children: aceitas
                            .map(
                              (carga) =>
                                  cargaCard(context, carga, futuro: false),
                            )
                            .toList(),
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
                      children: concluidas
                          .map(
                            (carga) => cargaCard(context, carga, futuro: false),
                          )
                          .toList(),
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
                Text('Empresa: ${carga.empresaNome ?? 'Não informada'}'),
                Text('Origem: ${carga.origem}'),
                Text('Destino: ${carga.destino}'),
                Text('Peso: ${carga.peso} kg'),
                Text('Data: ${dateFormat.format(carga.data)}'),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Botão de ação
          // Se status for 'aceita', permitir cancelar e concluir
          (carga.status == 'aceita')
              ? Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () async {
                            try {
                              final api = ApiService();
                              await api.atualizarCarga(carga.id, {
                                'status': 'cancelada_pelo_motorista',
                              });
                              if (!mounted) return;
                              
                              // Mostrar mensagem de sucesso
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Carga cancelada!'),
                                  backgroundColor: Colors.orange,
                                ),
                              );
                              
                              // Recarregar dados imediatamente
                              await _carregarCargas();
                            } catch (e) {
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Falha ao cancelar: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.black,
                            side: const BorderSide(color: Colors.black54),
                          ),
                          child: const Text('CANCELAR'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            try {
                              final api = ApiService();
                              await api.atualizarCarga(carga.id, {
                                'status': 'concluida',
                              });
                              if (!mounted) return;
                              
                              // Mostrar mensagem de sucesso
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Carga concluída!'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              
                              // Recarregar dados imediatamente
                              await _carregarCargas();
                            } catch (e) {
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Falha ao concluir: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                          ),
                          child: const Text('CONCLUIR'),
                        ),
                      ),
                    ],
                  ),
                )
              : carga.avaliada
              ? Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
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
                      SnackBar(
                        content: Text(
                          'Avaliar carga de ${carga.empresaNome ?? 'empresa'}',
                        ),
                      ),
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
