import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:truckload/screens/empresas/tela_menuEmpresarial.dart';
import 'package:truckload/services/api_service.dart';

class CargasRealizadas extends StatefulWidget {
  final String empresaId;

  const CargasRealizadas({super.key, required this.empresaId});

  @override
  State<CargasRealizadas> createState() => _CargasRealizadasState();
}

class _CargasRealizadasState extends State<CargasRealizadas> {
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

      // Carregar cargas concluídas da empresa
      final cargas = await _apiService.getCargasEmpresaPorStatus(
        widget.empresaId,
        'concluida',
      );

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

  void _marcarComoAvaliada(int index) {
    setState(() {
      _cargas[index]['avaliada'] = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Carga marcada como avaliada!'),
        backgroundColor: Colors.green,
      ),
    );
  }

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
          "Cargas Realizadas",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: _carregarCargas,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? _buildErrorWidget()
          : _buildCargasList(),
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

  Widget _buildCargasList() {
    if (_cargas.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Nenhuma carga concluída',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'As cargas concluídas aparecerão aqui',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _cargas.length,
      itemBuilder: (context, index) {
        final carga = _cargas[index];
        return _buildCargaCard(carga, index);
      },
    );
  }

  Widget _buildCargaCard(Map<String, dynamic> carga, int index) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final data = DateTime.tryParse(carga['data'] ?? '') ?? DateTime.now();
    final peso = (carga['peso'] ?? 0.0).toDouble();
    final preco = (carga['preco'] ?? 0.0).toDouble();
    final avaliada = carga['avaliada'] ?? false;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: const Color(0xFFB0CCE5),
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ícone da carga
            CircleAvatar(
              radius: 25,
              backgroundColor: Colors.white,
              child: Icon(
                Icons.local_shipping,
                color: Colors.grey[800],
                size: 30,
              ),
            ),
            const SizedBox(width: 12),

            // Informações da carga
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("CARGA", style: TextStyle(fontWeight: FontWeight.bold)),
                  Text("Origem: ${carga['origem'] ?? 'Não informada'}"),
                  Text("Destino: ${carga['destino'] ?? 'Não informada'}"),
                  Text("Peso: ${peso.toStringAsFixed(1)} kg"),
                  Text("Preço: R\$ ${preco.toStringAsFixed(2)}"),
                  Text("Data: ${dateFormat.format(data)}"),
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Ação do botão
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: avaliada ? Colors.green : Colors.grey,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(avaliada ? 'Avaliada' : 'Pendente'),
                ),
                const SizedBox(height: 6),
                ElevatedButton(
                  onPressed: () {
                    // Ação do segundo botão
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[300],
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Ver detalhes'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
