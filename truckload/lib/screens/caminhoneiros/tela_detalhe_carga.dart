import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:truckload/services/api_service.dart';
import 'package:truckload/screens/caminhoneiros/tela_historico.dart';

class TelaDetalheCarga extends StatelessWidget {
  final Map<String, dynamic> carga;
  final String userId;

  const TelaDetalheCarga({
    super.key,
    required this.carga,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    final titulo = carga['titulo'] ?? 'Carga sem título';
    final descricao = carga['descricao'] ?? 'Sem descrição';
    final origem = carga['origem'] ?? 'Origem não informada';
    final destino = carga['destino'] ?? 'Destino não informada';
    final peso = carga['peso']?.toString() ?? '0';
    final preco = carga['preco']?.toString() ?? '0';
    final tipoCarga = carga['tipoCarga'] ?? 'Tipo não informado';
    final empresa = carga['empresaNome'] ?? 'Empresa não informada';
    final data = _formatDate(carga['data']);
    final regras = _extractRegras(carga);

    return Scaffold(
      backgroundColor: const Color(0xFFE6F0FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE6F0FA),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: const Text(
          'Detalhes da Carga',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Empresa: $empresa',
                  style: TextStyle(color: Colors.grey[700]),
                ),
                const SizedBox(height: 16),
                _secao('Descrição', descricao),
                const SizedBox(height: 12),
                _linhaIcone(
                  Icons.local_shipping,
                  'Tipo de Carga',
                  tipoCarga,
                  Colors.blue,
                ),
                const SizedBox(height: 8),
                _linhaIcone(Icons.scale, 'Peso', '${peso} kg', Colors.orange),
                const SizedBox(height: 8),
                _linhaIcone(
                  Icons.attach_money,
                  'Preço',
                  'R\$ ${preco}',
                  Colors.green,
                ),
                const SizedBox(height: 8),
                _linhaIcone(Icons.calendar_today, 'Data', data, Colors.indigo),
                const SizedBox(height: 16),
                _rota(origem, destino),
                const SizedBox(height: 16),
                if (regras.isNotEmpty)
                  _secao('Regras impostas pela empresa', ''),
                if (regras.isNotEmpty)
                  ...regras.map((r) => _bullet(r)).toList(),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Voltar'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          try {
                            final api = ApiService();
                            final cargaEmpresaId = (carga['id'] ?? carga['_id'])
                                ?.toString();

                            if (cargaEmpresaId != null &&
                                cargaEmpresaId.isNotEmpty) {
                              await api.aceitarCargaEmpresa(
<<<<<<< HEAD
                                cargaEmpresaId,
                                userId,
=======
                                cargaEmpresaId: cargaEmpresaId,
                                caminhoneiroId: userId,
>>>>>>> b6a42f1baca63803288e53c189d87d2950f01a15
                              );
                            } else {
                              final empresaId =
                                  (carga['empresaId'] ??
                                          carga['empresa_id'] ??
                                          '')
                                      .toString();
                              final tituloCarga =
                                  (carga['titulo'] ?? 'Carga aceita')
                                      .toString();
                              await api.criarCarga({
                                'caminhoneiroId': userId,
                                if (empresaId.isNotEmpty)
                                  'empresaId': empresaId,
                                'status': 'aceita',
                                'titulo': tituloCarga,
                              });
                            }

                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Carga aceita com sucesso!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => TelaHistorico(userId: userId),
                              ),
                            );
                          } catch (e) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Falha ao aceitar carga: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.check_circle),
                        label: const Text('Aceitar Carga'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(dynamic value) {
    DateTime? dt;
    if (value == null) return '-';
    try {
      if (value is int) {
        // Detecta segundos vs milissegundos
        if (value.toString().length >= 13) {
          dt = DateTime.fromMillisecondsSinceEpoch(value, isUtc: false);
        } else {
          dt = DateTime.fromMillisecondsSinceEpoch(value * 1000, isUtc: false);
        }
      } else if (value is String) {
        // Tenta ISO8601
        dt = DateTime.tryParse(value);
        if (dt == null) {
          // Tenta só a parte da data
          final onlyDate = RegExp(r"^\d{4}-\d{2}-\d{2}").stringMatch(value);
          if (onlyDate != null) dt = DateTime.tryParse(onlyDate);
        }
      } else if (value is DateTime) {
        dt = value;
      }
    } catch (_) {}

    if (dt == null) return value.toString();
    return DateFormat('dd/MM/yyyy HH:mm').format(dt);
  }

  List<String> _formatRegras(dynamic value) {
    if (value == null) return [];
    if (value is String) {
      final trimmed = value.trim();
      if (trimmed.isEmpty) return [];
      final parts = trimmed
          .split(RegExp(r"[\n\r]|\s*[-•\u2022]\s*|\s*\d+[\).]\s*"))
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
      return parts.isEmpty ? [trimmed] : parts;
    }
    if (value is List) {
      return value
          .whereType<String>()
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }
    if (value is Map) {
      return value.values
          .whereType<String>()
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }
    return [];
  }

  /// Tenta várias chaves comuns para pegar as regras vindas da API
  List<String> _extractRegras(Map<String, dynamic> carga) {
    final possibleKeys = <String>[
      'regras',
      'regrasEmpresa',
      'regras_da_empresa',
      'diretrizes',
      'condicoes',
      'condições',
      'termos',
      'políticas',
      'politicas',
    ];

    final collected = <String>[];
    for (final key in possibleKeys) {
      if (carga.containsKey(key)) {
        collected.addAll(_formatRegras(carga[key]));
      }
    }

    // Caso venha aninhado em "empresa" ou similares
    for (final nestKey in ['empresa', 'company']) {
      final nested = carga[nestKey];
      if (nested is Map<String, dynamic>) {
        for (final key in possibleKeys) {
          if (nested.containsKey(key)) {
            collected.addAll(_formatRegras(nested[key]));
          }
        }
      }
    }

    // Remover duplicados mantendo ordem
    final seen = <String>{};
    final unique = <String>[];
    for (final r in collected) {
      if (!seen.contains(r)) {
        seen.add(r);
        unique.add(r);
      }
    }
    return unique;
  }

  Widget _bullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 16)),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  Widget _secao(String titulo, String conteudo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(conteudo),
      ],
    );
  }

  Widget _linhaIcone(IconData icon, String label, String valor, Color cor) {
    return Row(
      children: [
        Icon(icon, color: cor),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        Text(
          valor,
          style: TextStyle(color: cor, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _rota(String origem, String destino) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.map, color: Colors.blue),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [Text('Origem: $origem'), Text('Destino: $destino')],
            ),
          ),
        ],
      ),
    );
  }
}
