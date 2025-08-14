import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class TelaFiltroCarga extends StatefulWidget {
  const TelaFiltroCarga({super.key});

  @override
  State<TelaFiltroCarga> createState() => _TelaFiltroCargaState();
}

class _TelaFiltroCargaState extends State<TelaFiltroCarga> {
  final TextEditingController origemController = TextEditingController();
  final TextEditingController destinoController = TextEditingController();
  final TextEditingController pesoController = TextEditingController();

  String tipoSelecionado = '';
  List<String> todasCidades = [];
  List<String> cidadesFiltradas = [];

  @override
  void initState() {
    super.initState(); 
    carregarCidades();
  }

  Future<void> carregarCidades() async { // carregar lista de cidades
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

  void filtrarCidades(String prefixo) {
    if (prefixo.isEmpty) {
      setState(() => cidadesFiltradas = []);
      return;
    }
    final lista = todasCidades
        .where((nome) =>
            nome.toLowerCase().startsWith(prefixo.toLowerCase()))
        .toList();
    setState(() {
      cidadesFiltradas = lista;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6F0FA),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Filtrar carga',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Filtre as cargas disponíveis de acordo com as suas preferências',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 20),

            // Campo origem
            campoAutocomplete(origemController, 'Digite a cidade de origem', Icons.location_on),

            const SizedBox(height: 10),

            // Campo destino
            campoAutocomplete(destinoController, 'Digite a cidade de destino', Icons.location_on),

            const SizedBox(height: 10),

            // Campo peso mínimo (só números)
            campoTexto(
              pesoController,
              'Digite o peso mínimo',
              null,
              sufixo: 'kg',
              somenteNumeros: true,
            ),

            const SizedBox(height: 20),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'TIPO DE CARGA',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 10),

            // Botões tipo carga
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                botaoTipo('Seca'),
                botaoTipo('Frigorífica'),
                botaoTipo('Granel'),
              ],
            ),

            const Spacer(),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: () {
                print('Origem: ${origemController.text}');
                print('Destino: ${destinoController.text}');
                print('Peso: ${pesoController.text}');
                print('Tipo: $tipoSelecionado');
              },
              child: const Text(
                'APLICAR FILTROS',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),

            const SizedBox(height: 20),
            Image.asset('assets/logo.png', height: 50),
          ],
        ),
      ),
    );
  }

  /// Campo com autocomplete
  Widget campoAutocomplete(TextEditingController controller, String hint, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFB0CCE5),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.black54),
          Expanded(
            child: Autocomplete<String>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                filtrarCidades(textEditingValue.text);
                return cidadesFiltradas;
              },
              onSelected: (String selection) {
                controller.text = selection;
              },
              fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
                textEditingController.text = controller.text;
                textEditingController.selection = TextSelection.fromPosition(
                  TextPosition(offset: textEditingController.text.length),
                );

                return TextField(
                  controller: textEditingController,
                  focusNode: focusNode,
                  decoration: InputDecoration(
                    hintText: hint,
                    border: InputBorder.none,
                  ),
                  onChanged: (value) {
                    controller.text = value;
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Campo normal
  Widget campoTexto(
    TextEditingController controller,
    String hint,
    IconData? icon, {
    String? sufixo,
    bool somenteNumeros = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFB0CCE5),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          if (icon != null) Icon(icon, color: Colors.black54),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType:
                  somenteNumeros ? TextInputType.number : TextInputType.text,
              inputFormatters: somenteNumeros
                  ? [FilteringTextInputFormatter.digitsOnly]
                  : [],
              decoration: InputDecoration(
                hintText: hint,
                border: InputBorder.none,
              ),
            ),
          ),
          if (sufixo != null)
            Text(
              sufixo,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
        ],
      ),
    );
  }

  /// Botão tipo carga
  Widget botaoTipo(String label) {
    final bool selecionado = tipoSelecionado == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          tipoSelecionado = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selecionado ? Colors.blue[300] : const Color(0xFFB0CCE5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: selecionado ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}