import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:truckload/screens/empresas/tela_menuEmpresarial.dart';
import 'package:truckload/screens/empresas/tela_editarCarga.dart';
import 'package:truckload/screens/empresas/tela_deletarcargas.dart';
import 'package:truckload/services/api_service.dart';

class CargasPendentes extends StatefulWidget {
  final String empresaId;

  const CargasPendentes({super.key, required this.empresaId});

  @override
  State<CargasPendentes> createState() => _CargasPendentesState();
}

class _CargasPendentesState extends State<CargasPendentes> {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _cargas = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _carregarCargas();
  }

  Future<void> _carregarCargas() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Carregar cargas da empresa
      final cargas = await _apiService.getCargasEmpresa(widget.empresaId);

      if (mounted) {
        setState(() {
          _cargas = cargas;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Erro ao carregar cargas: $e';
          _isLoading = false;
        });
      }
    }
  }

  void _deletarCarga(String cargaId) async {
    try {
      await _apiService.deletarCargaEmpresa(cargaId);
      // Recarregar cargas após deletar
      _carregarCargas();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Carga deletada com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao deletar carga: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Separar cargas por status
    final cargasPendentes = _cargas
        .where((c) => c['status'] == 'disponivel' || c['status'] == 'pendente')
        .toList();

    final cargasEmTransito = _cargas
        .where((c) => c['status'] == 'em_transito')
        .toList();

    final cargasConcluidas = _cargas
        .where((c) => c['status'] == 'concluida')
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFE6F0FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black87),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    TelaMenuEmpresa(empresaId: widget.empresaId),
              ),
            );
          },
        ),
        title: const Text(
          "Gerenciar Cargas",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black87),
            onPressed: _carregarCargas,
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(12, 80, 12, 12),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? _buildErrorWidget()
            : _buildCargasList(
                cargasPendentes,
                cargasEmTransito,
                cargasConcluidas,
              ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(
            _error!,
            style: const TextStyle(fontSize: 16, color: Colors.red),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _carregarCargas,
            child: const Text('Tentar Novamente'),
          ),
        ],
      ),
    );
  }

  Widget _buildCargasList(
    List<Map<String, dynamic>> pendentes,
    List<Map<String, dynamic>> emTransito,
    List<Map<String, dynamic>> concluidas,
  ) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cargas Pendentes
          if (pendentes.isNotEmpty) ...[
            _buildSectionTitle(
              "Cargas Pendentes",
              Icons.schedule,
              Colors.orange,
            ),
            const SizedBox(height: 8),
            ...pendentes.map((c) => _buildCargaCard(c, 'pendente')),
            const SizedBox(height: 20),
          ],

          // Cargas em Trânsito
          if (emTransito.isNotEmpty) ...[
            _buildSectionTitle(
              "Cargas em Trânsito",
              Icons.local_shipping,
              Colors.blue,
            ),
            const SizedBox(height: 8),
            ...emTransito.map((c) => _buildCargaCard(c, 'em_transito')),
            const SizedBox(height: 20),
          ],

          // Cargas Concluídas
          if (concluidas.isNotEmpty) ...[
            _buildSectionTitle(
              "Cargas Concluídas",
              Icons.check_circle,
              Colors.green,
            ),
            const SizedBox(height: 8),
            ...concluidas.map((c) => _buildCargaCard(c, 'concluida')),
          ],

          // Mensagem se não há cargas
          if (_cargas.isEmpty) ...[
            const SizedBox(height: 50),
            Center(
              child: Column(
                children: [
                  Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhuma carga encontrada',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Adicione sua primeira carga para começar',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildCargaCard(Map<String, dynamic> carga, String status) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final data = DateTime.tryParse(carga['data'] ?? '') ?? DateTime.now();
    final peso = (carga['peso'] ?? 0.0).toDouble();
    final preco = (carga['preco'] ?? 0.0).toDouble();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFB0CCE5),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 6,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.local_shipping,
                  size: 28,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      carga['titulo'] ?? 'Carga',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text("Origem: ${carga['origem'] ?? 'Não informada'}"),
                    Text("Destino: ${carga['destino'] ?? 'Não informada'}"),
                    Text("Peso: ${peso.toStringAsFixed(1)} kg"),
                    Text("Preço: R\$ ${preco.toStringAsFixed(2)}"),
                    Text("Data: ${dateFormat.format(data)}"),
                    Text(
                      "Status: ${_getStatusText(status)}",
                      style: TextStyle(
                        color: _getStatusColor(status),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (carga['descricao'] != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        "Descrição: ${carga['descricao']}",
                        style: const TextStyle(fontStyle: FontStyle.italic),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),

              // Botões de ação
              if (status != 'concluida') ...[
                Column(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.white),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditarCarga(
                              carga: carga,
                              motoristaSelecionado: false,
                              empresaId: widget.empresaId,
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
                              onDelete: () => _deletarCarga(carga['id']),
                              empresaId: widget.empresaId,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'disponivel':
        return 'Disponível';
      case 'pendente':
        return 'Pendente';
      case 'em_transito':
        return 'Em Trânsito';
      case 'concluida':
        return 'Concluída';
      case 'cancelada':
        return 'Cancelada';
      default:
        return 'Desconhecido';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'disponivel':
        return Colors.orange;
      case 'pendente':
        return Colors.orange;
      case 'em_transito':
        return Colors.blue;
      case 'concluida':
        return Colors.green;
      case 'cancelada':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
