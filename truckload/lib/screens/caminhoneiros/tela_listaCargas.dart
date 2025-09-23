import 'package:flutter/material.dart';
import 'package:truckload/screens/caminhoneiros/tela_menu.dart';
import 'package:truckload/screens/caminhoneiros/tela_FiltroCarga.dart';
import 'package:truckload/screens/caminhoneiros/tela_detalhe_carga.dart';
import 'package:truckload/services/api_service.dart';

class TelaListaCargas extends StatefulWidget {
  final String userId;
  final List<Map<String, dynamic>> cargas;
  final Map<String, dynamic> filtrosAplicados;

  const TelaListaCargas({
    super.key,
    required this.userId,
    required this.cargas,
    required this.filtrosAplicados,
  });

  @override
  State<TelaListaCargas> createState() => _TelaListaCargasState();
}

class _TelaListaCargasState extends State<TelaListaCargas> {
  List<Map<String, dynamic>> _cargasFiltradas = [];
  String _ordenacao = 'preco'; // preco, peso, data
  bool _ordenacaoCrescente = true;

  @override
  void initState() {
    super.initState();
    _cargasFiltradas = List.from(widget.cargas);
    _ordenarCargas();
  }

  void _ordenarCargas() {
    _cargasFiltradas.sort((a, b) {
      dynamic valorA;
      dynamic valorB;

      switch (_ordenacao) {
        case 'preco':
          valorA = a['preco'] ?? 0.0;
          valorB = b['preco'] ?? 0.0;
          break;
        case 'peso':
          valorA = a['peso'] ?? 0.0;
          valorB = b['peso'] ?? 0.0;
          break;
        case 'data':
          valorA = a['data'] ?? '';
          valorB = b['data'] ?? '';
          break;
        default:
          valorA = a['preco'] ?? 0.0;
          valorB = b['preco'] ?? 0.0;
      }

      if (_ordenacaoCrescente) {
        return valorA.compareTo(valorB);
      } else {
        return valorB.compareTo(valorA);
      }
    });
  }

  void _alterarOrdenacao(String novaOrdenacao) {
    if (_ordenacao == novaOrdenacao) {
      _ordenacaoCrescente = !_ordenacaoCrescente;
    } else {
      _ordenacao = novaOrdenacao;
      _ordenacaoCrescente = true;
    }
    setState(() {
      _ordenarCargas();
    });
  }

  void _aplicarNovosFiltros() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => TelaFiltroCarga(userId: widget.userId),
      ),
    );
  }

  void _voltarAoMenu() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => TelaMenu(userId: widget.userId)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6F0FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE6F0FA),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: _voltarAoMenu,
        ),
        title: Text(
          'Cargas Disponíveis (${_cargasFiltradas.length})',
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.blue),
            onPressed: _aplicarNovosFiltros,
            tooltip: 'Aplicar novos filtros',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filtros aplicados
          if (widget.filtrosAplicados.isNotEmpty)
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '🔍 Filtros Aplicados:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...widget.filtrosAplicados.entries.map(
                    (entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        '• ${entry.key}: ${entry.value}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Controles de ordenação
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                const Text(
                  'Ordenar por:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Row(
                    children: [
                      _botaoOrdenacao('Preço', 'preco'),
                      const SizedBox(width: 8),
                      _botaoOrdenacao('Peso', 'peso'),
                      const SizedBox(width: 8),
                      _botaoOrdenacao('Data', 'data'),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    _ordenacaoCrescente
                        ? Icons.arrow_upward
                        : Icons.arrow_downward,
                    color: Colors.blue,
                  ),
                  onPressed: () {
                    setState(() {
                      _ordenacaoCrescente = !_ordenacaoCrescente;
                      _ordenarCargas();
                    });
                  },
                  tooltip: _ordenacaoCrescente ? 'Crescente' : 'Decrescente',
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Lista de cargas
          Expanded(
            child: _cargasFiltradas.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        const Text(
                          'Nenhuma carga encontrada',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Tente ajustar os filtros ou buscar em outras regiões',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _aplicarNovosFiltros,
                          icon: const Icon(Icons.filter_list),
                          label: const Text('Ajustar Filtros'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          onPressed: _voltarAoMenu,
                          icon: const Icon(Icons.home),
                          label: const Text('Voltar ao Menu'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.blue,
                            side: const BorderSide(color: Colors.blue),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _cargasFiltradas.length,
                    itemBuilder: (context, index) {
                      final carga = _cargasFiltradas[index];
                      return _cargaCard(carga, index);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _botaoOrdenacao(String label, String valor) {
    final isSelected = _ordenacao == valor;
    return GestureDetector(
      onTap: () => _alterarOrdenacao(valor),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.grey.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _cargaCard(Map<String, dynamic> carga, int index) {
    final titulo = carga['titulo'] ?? 'Carga sem título';
    final descricao = carga['descricao'] ?? 'Sem descrição';
    final origem = carga['origem'] ?? 'Origem não informada';
    final destino = carga['destino'] ?? 'Destino não informada';
    final peso = carga['peso']?.toString() ?? '0';
    final preco = carga['preco']?.toString() ?? '0';
    final tipoCarga = carga['tipoCarga'] ?? 'Tipo não informado';
    final empresa = carga['empresaNome'] ?? 'Empresa não informada';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabeçalho da carga
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        titulo,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tipo: $tipoCarga',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'DISPONÍVEL',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Corpo da carga
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Descrição
                Text(
                  descricao,
                  style: const TextStyle(fontSize: 14),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),

                // Rota
                Row(
                  children: [
                    Icon(Icons.location_on, color: Colors.red[400], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'De: $origem',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          Text(
                            'Para: $destino',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Detalhes da carga
                Row(
                  children: [
                    Expanded(
                      child: _detalheCarga(
                        Icons.scale,
                        'Peso',
                        '${peso} kg',
                        Colors.orange,
                      ),
                    ),
                    Expanded(
                      child: _detalheCarga(
                        Icons.attach_money,
                        'Preço',
                        'R\$ ${preco}',
                        Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Empresa
                Row(
                  children: [
                    Icon(Icons.business, color: Colors.blue[400], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Empresa: $empresa',
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Botões de ação
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (_) =>
                            const Center(child: CircularProgressIndicator()),
                      );

                      Map<String, dynamic> cargaDetalhada = carga;
                      try {
                        final id = (carga['id'] ?? carga['_id'])?.toString();
                        if (id != null && id.isNotEmpty) {
                          final api = ApiService();
                          final detalhada = await api.getCargaEmpresa(id);
                          if (detalhada.isNotEmpty) {
                            cargaDetalhada = detalhada;
                          }
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Falha ao carregar detalhes: $e'),
                            ),
                          );
                        }
                      } finally {
                        if (mounted) Navigator.of(context).pop();
                      }

                      if (!mounted) return;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TelaDetalheCarga(
                            carga: cargaDetalhada,
                            userId: widget.userId,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.visibility),
                    label: const Text('Ver Detalhes'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue,
                      side: const BorderSide(color: Colors.blue),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Implementar aceitação da carga
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Funcionalidade em desenvolvimento'),
                          backgroundColor: Colors.green,
                        ),
                      );
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
          ),
        ],
      ),
    );
  }

  Widget _detalheCarga(IconData icon, String label, String valor, Color cor) {
    return Row(
      children: [
        Icon(icon, color: cor, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              Text(
                valor,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: cor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
