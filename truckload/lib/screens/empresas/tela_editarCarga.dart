import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:truckload/screens/empresas/tela_menuEmpresarial.dart';
import 'package:truckload/services/api_service.dart';

class EditarCarga extends StatefulWidget {
  final bool motoristaSelecionado; // se já tem motorista
  final Map<String, dynamic> carga; // dados da carga
  final String empresaId;

  const EditarCarga({
    super.key,
    required this.motoristaSelecionado,
    required this.carga,
    required this.empresaId,
  });

  @override
  State<EditarCarga> createState() => _EditarCargaState();
}

class _EditarCargaState extends State<EditarCarga> {
  final ApiService _apiService = ApiService();
  late TextEditingController tipoController;
  late TextEditingController descricaoController;
  late TextEditingController origemController;
  late TextEditingController destinoController;
  late TextEditingController pesoController;
  late TextEditingController precoController;
  DateTime? dataSelecionada;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _inicializarControladores();
  }

  void _inicializarControladores() {
    tipoController = TextEditingController(
      text: widget.carga["tipoCarga"] ?? '',
    );
    descricaoController = TextEditingController(
      text: widget.carga["descricao"] ?? '',
    );
    origemController = TextEditingController(
      text: widget.carga["origem"] ?? '',
    );
    destinoController = TextEditingController(
      text: widget.carga["destino"] ?? '',
    );
    pesoController = TextEditingController(
      text: (widget.carga["peso"] ?? 0.0).toString(),
    );
    precoController = TextEditingController(
      text: (widget.carga["preco"] ?? 0.0).toString(),
    );

    // Converter data se existir
    if (widget.carga["data"] != null) {
      try {
        dataSelecionada = DateTime.parse(widget.carga["data"]);
      } catch (e) {
        dataSelecionada = DateTime.now();
      }
    } else {
      dataSelecionada = DateTime.now();
    }
  }

  @override
  void dispose() {
    tipoController.dispose();
    descricaoController.dispose();
    origemController.dispose();
    destinoController.dispose();
    pesoController.dispose();
    precoController.dispose();
    super.dispose();
  }

  Future<void> selecionarData(BuildContext context) async {
    final DateTime? selecionada = await showDatePicker(
      context: context,
      initialDate: dataSelecionada ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (selecionada != null) {
      setState(() {
        dataSelecionada = selecionada;
      });
    }
  }

  Future<void> _salvarAlteracoes() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Validar campos obrigatórios
      if (tipoController.text.isEmpty ||
          descricaoController.text.isEmpty ||
          origemController.text.isEmpty ||
          destinoController.text.isEmpty ||
          pesoController.text.isEmpty ||
          precoController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Por favor, preencha todos os campos obrigatórios"),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Converter peso e preço
      final peso = double.tryParse(pesoController.text) ?? 0.0;
      final preco = double.tryParse(precoController.text) ?? 0.0;

      // Preparar dados para atualização
      final dadosAtualizados = {
        'titulo':
            '${tipoController.text} - ${origemController.text} para ${destinoController.text}',
        'descricao': descricaoController.text,
        'tipoCarga': tipoController.text,
        'origem': origemController.text,
        'destino': destinoController.text,
        'peso': peso,
        'preco': preco,
        'data': dataSelecionada?.toIso8601String(),
      };

      // Atualizar carga via API
      await _apiService.atualizarCargaEmpresa(
        widget.carga['id'],
        dadosAtualizados,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        // Mostrar sucesso
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Carga atualizada com sucesso!"),
            backgroundColor: Colors.green,
          ),
        );

        // Voltar para o menu
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => TelaMenuEmpresa(empresaId: widget.empresaId),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erro ao atualizar carga: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool bloqueado = widget.motoristaSelecionado;

    return Scaffold(
      backgroundColor: const Color(0xFFD4E1FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFB0CCE5),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
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
        title: const Text("Editar Carga"),
        actions: [
          if (bloqueado)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Icon(Icons.lock, color: Colors.orange, size: 20),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status da carga
            if (bloqueado) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange[800]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Esta carga não pode ser editada pois já possui motorista selecionado",
                        style: TextStyle(
                          color: Colors.orange[800],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            campoTexto(
              "Tipo de Carga",
              Icons.local_shipping,
              tipoController,
              bloqueado,
            ),
            campoTexto(
              "Descrição",
              Icons.assignment,
              descricaoController,
              bloqueado,
            ),
            campoTexto(
              "Local de origem",
              Icons.location_on,
              origemController,
              bloqueado,
            ),
            campoTexto(
              "Local de destino",
              Icons.flag,
              destinoController,
              bloqueado,
            ),
            campoTexto(
              "Peso (kg)",
              Icons.monitor_weight,
              pesoController,
              bloqueado,
              tecladoNumero: true,
            ),
            campoTexto(
              "Preço (R\$)",
              Icons.attach_money,
              precoController,
              bloqueado,
              tecladoNumero: true,
            ),

            // Data (sempre editável)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: () => selecionarData(context),
                child: AbsorbPointer(
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: "Data",
                      prefixIcon: const Icon(Icons.calendar_today),
                      filled: true,
                      fillColor: Colors.blue[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    controller: TextEditingController(
                      text: dataSelecionada != null
                          ? DateFormat('dd/MM/yyyy').format(dataSelecionada!)
                          : "",
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Botão de salvar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: bloqueado || _isLoading ? null : _salvarAlteracoes,
                icon: _isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          color: Colors.black,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.save),
                label: Text(_isLoading ? "Salvando..." : "Salvar Alterações"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9CB9E3),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            // Informações da carga
            const SizedBox(height: 30),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Informações da Carga",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  Text("ID: ${widget.carga['id'] ?? 'N/A'}"),
                  Text(
                    "Status: ${_getStatusText(widget.carga['status'] ?? '')}",
                  ),
                  Text("Criada em: ${_formatDate(widget.carga['created_at'])}"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget campoTexto(
    String label,
    IconData icone,
    TextEditingController controller,
    bool bloqueado, {
    bool tecladoNumero = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        enabled: !bloqueado, // só habilita se não tiver motorista
        keyboardType: tecladoNumero ? TextInputType.number : TextInputType.text,
        inputFormatters: tecladoNumero
            ? [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))]
            : null,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icone),
          filled: true,
          fillColor: bloqueado ? Colors.grey[200] : Colors.blue[100],
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          hintText: bloqueado ? "Campo bloqueado" : null,
        ),
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

  String _formatDate(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd/MM/yyyy HH:mm').format(date);
    } catch (e) {
      return 'Data inválida';
    }
  }
}
