import 'package:flutter/material.dart';
import 'package:truckload/screens/empresas/tela_menuEmpresarial.dart';

class EditarCarga extends StatefulWidget {
  final bool motoristaSelecionado; // se já tem motorista
  final Map<String, dynamic> carga; // dados da carga

  const EditarCarga({
    super.key,
    required this.motoristaSelecionado,
    required this.carga,
  });

  @override
  State<EditarCarga> createState() => _EditarCargaState();
}

class _EditarCargaState extends State<EditarCarga> {
  late TextEditingController tipoController;
  late TextEditingController descricaoController;
  late TextEditingController origemController;
  late TextEditingController destinoController;
  late TextEditingController pesoController;
  late TextEditingController precoController;
  DateTime? dataSelecionada;

  @override
  void initState() {
    super.initState();
    tipoController = TextEditingController(text: widget.carga["tipo"]);
    descricaoController = TextEditingController(text: widget.carga["descricao"]);
    origemController = TextEditingController(text: widget.carga["origem"]);
    destinoController = TextEditingController(text: widget.carga["destino"]);
    pesoController = TextEditingController(text: widget.carga["peso"].toString());
    precoController = TextEditingController(text: widget.carga["preco"].toString());
    dataSelecionada = widget.carga["data"];
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

  @override
  Widget build(BuildContext context) {
    bool bloqueado = widget.motoristaSelecionado;

    return Scaffold(
      backgroundColor: const Color(0xFFD4E1FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFB0CCE5),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const TelaMenuEmpresa()), // outra tela
            );
          },
        ),
        title: const Text("Editar Carga"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            campoTexto("Tipo de Carga", Icons.local_shipping, tipoController, bloqueado),
            campoTexto("Descrição", Icons.assignment, descricaoController, bloqueado),
            campoTexto("Local de origem", Icons.location_on, origemController, bloqueado),
            campoTexto("Local de destino", Icons.flag, destinoController, bloqueado),
            campoTexto("Peso", Icons.monitor_weight, pesoController, bloqueado, tecladoNumero: true),
            campoTexto("Preço", Icons.attach_money, precoController, bloqueado, tecladoNumero: true),

            // Data (sempre editável)
            GestureDetector(
              onTap: () => selecionarData(context),
              child: AbsorbPointer(
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: "Data",
                    prefixIcon: const Icon(Icons.calendar_today),
                    filled: true,
                    fillColor: Colors.blue[100],
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  controller: TextEditingController(
                    text: dataSelecionada != null
                        ? "${dataSelecionada!.day}/${dataSelecionada!.month}/${dataSelecionada!.year}"
                        : "",
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Dados alterados!")),
                );
              },
              icon: const Icon(Icons.edit),
              label: const Text("Alterar dados"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9CB9E3),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget campoTexto(String label, IconData icone, TextEditingController controller, bool bloqueado, {bool tecladoNumero = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        enabled: !bloqueado, // só habilita se não tiver motorista
        keyboardType: tecladoNumero ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icone),
          filled: true,
          fillColor: Colors.blue[100],
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}