import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class AdicionarCarga extends StatefulWidget {
  const AdicionarCarga({super.key});

  @override
  State<AdicionarCarga> createState() => _AdicionarCargaState();
}

class _AdicionarCargaState extends State<AdicionarCarga> {
  String tipoSelecionado = '';
  List<String> todasCidades = [];

  final TextEditingController origemController = TextEditingController();
  final TextEditingController destinoController = TextEditingController();
  final TextEditingController pesoController = TextEditingController();
  final TextEditingController precoController = TextEditingController();
  final TextEditingController descricaoController = TextEditingController();
  final TextEditingController regrasController = TextEditingController();

  // Controle de erro de campos
  bool erroTipo = false;
  bool erroDescricao = false;
  bool erroOrigem = false;
  bool erroDestino = false;
  bool erroPeso = false;
  bool erroPreco = false;
  bool erroRegras = false;

  @override
  void initState() {
    super.initState();
    carregarCidades();
  }

  Future<void> carregarCidades() async {
    try {
      final url = Uri.parse(
          'https://servicodados.ibge.gov.br/api/v1/localidades/municipios');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List dados = jsonDecode(response.body);
        final lista = dados.map((cidade) => cidade['nome'] as String).toList();

        setState(() {
          todasCidades = lista;
        });
      }
    } catch (e) {
      print('Erro ao carregar cidades: $e');
    }
  }

  void validarCampos() {
    setState(() {
      erroTipo = tipoSelecionado.isEmpty;
      erroDescricao = descricaoController.text.isEmpty;
      erroOrigem = origemController.text.isEmpty;
      erroDestino = destinoController.text.isEmpty;
      erroPeso = pesoController.text.isEmpty;
      erroPreco = precoController.text.isEmpty;
      erroRegras = regrasController.text.isEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFDDEBFF), Color(0xFFEAF3FA)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    'Adicionar Nova Carga',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                ),
                const SizedBox(height: 30),

                // Tipo de carga
                campoDropdown("Tipo de Carga", ["Seca", "Frigorífica", "Granel"],
                    tipoSelecionado, erroTipo, (value) {
                  setState(() => tipoSelecionado = value!);
                }),
                const SizedBox(height: 30),

                campoPadrao("Descrição", descricaoController,
                    erroDescricao, Icons.assignment_outlined),
                const SizedBox(height: 30),

                campoAutoComplete("Local de origem", origemController,
                    erroOrigem, Icons.location_on_outlined),
                const SizedBox(height: 30),

                campoAutoComplete("Local de destino", destinoController,
                    erroDestino, Icons.location_on_outlined),
                const SizedBox(height: 30),

                campoPeso(),
                const SizedBox(height: 30),

                campoPreco(),
                const SizedBox(height: 30),

                campoPadrao("Regras e diretrizes da empresa", regrasController,
                    erroRegras, Icons.warning_amber_outlined),
                const SizedBox(height: 40),

                // Botão
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      validarCampos();
                      if (!(erroTipo ||
                          erroDescricao ||
                          erroOrigem ||
                          erroDestino ||
                          erroPeso ||
                          erroPreco ||
                          erroRegras)) {
                        // Aqui vai a lógica para enviar os dados
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Carga adicionada com sucesso!")),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[800],
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                    ),
                    child: const Text(
                      "Adicionar Carga",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget campoDropdown(String label, List<String> opcoes, String valorSelecionado,
      bool erro, ValueChanged<String?> onChanged) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      Container(
        decoration: BoxDecoration(
          color: Colors.blue[100]?.withOpacity(0.6),
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: DropdownButtonFormField<String>(
          value: valorSelecionado.isEmpty ? null : valorSelecionado,
          decoration: const InputDecoration(border: InputBorder.none),
          items: opcoes
              .map((op) => DropdownMenuItem(value: op, child: Text(op)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
      if (erro)
        const Padding(
          padding: EdgeInsets.only(top: 5, left: 8),
          child: Text("Campo obrigatório",
              style: TextStyle(color: Colors.red, fontSize: 12)),
        )
    ]);
  }

  Widget campoPadrao(String label, TextEditingController controller, bool erro,
      IconData icon) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      Container(
        decoration: BoxDecoration(
          color: Colors.blue[100]?.withOpacity(0.6),
          borderRadius: BorderRadius.circular(20),
        ),
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.black),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 15),
          ),
        ),
      ),
      if (erro)
        const Padding(
          padding: EdgeInsets.only(top: 5, left: 8),
          child: Text("Campo obrigatório",
              style: TextStyle(color: Colors.red, fontSize: 12)),
        )
    ]);
  }

  Widget campoAutoComplete(String label, TextEditingController controller,
      bool erro, IconData icon) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      Container(
        decoration: BoxDecoration(
          color: Colors.blue[100]?.withOpacity(0.6),
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Autocomplete<String>(
          optionsBuilder: (TextEditingValue value) {
            if (value.text.isEmpty) {
              return const Iterable<String>.empty();
            }
            return todasCidades.where((cidade) =>
                cidade.toLowerCase().startsWith(value.text.toLowerCase()));
          },
          onSelected: (String selection) {
            controller.text = selection;
          },
          fieldViewBuilder:
              (context, textEditingController, focusNode, onFieldSubmitted) {
            return TextField(
              controller: textEditingController,
              focusNode: focusNode,
              decoration: InputDecoration(
                prefixIcon: Icon(icon, color: Colors.black),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 15),
              ),
            );
          },
        ),
      ),
      if (erro)
        const Padding(
          padding: EdgeInsets.only(top: 5, left: 8),
          child: Text("Campo obrigatório",
              style: TextStyle(color: Colors.red, fontSize: 12)),
        )
    ]);
  }

  Widget campoPeso() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text("Peso",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      Container(
        decoration: BoxDecoration(
          color: Colors.blue[100]?.withOpacity(0.6),
          borderRadius: BorderRadius.circular(20),
        ),
        child: TextField(
          controller: pesoController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.scale_outlined, color: Colors.black),
            suffixText: "kg",
            suffixStyle:
                TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 15),
          ),
        ),
      ),
      if (erroPeso)
        const Padding(
          padding: EdgeInsets.only(top: 5, left: 8),
          child: Text("Campo obrigatório",
              style: TextStyle(color: Colors.red, fontSize: 12)),
        )
    ]);
  }

  Widget campoPreco() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text("Preço",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      Container(
        decoration: BoxDecoration(
          color: Colors.blue[100]?.withOpacity(0.6),
          borderRadius: BorderRadius.circular(20),
        ),
        child: TextField(
          controller: precoController,
          keyboardType: TextInputType.number,
          inputFormatters: [CurrencyInputFormatter()],
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.attach_money_outlined, color: Colors.black),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 15),
          ),
        ),
      ),
      if (erroPreco)
        const Padding(
          padding: EdgeInsets.only(top: 5, left: 8),
          child: Text("Campo obrigatório",
              style: TextStyle(color: Colors.red, fontSize: 12)),
        )
    ]);
  }
}

// Formatter para preço no formato 0,00
class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String digits = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.isEmpty) digits = '0';

    double value = double.parse(digits) / 100;
    String formatted = value.toStringAsFixed(2).replaceAll('.', ',');

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}