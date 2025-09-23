import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:truckload/services/api_service.dart';
import 'package:truckload/screens/caminhoneiros/tela_menu.dart';
import 'package:truckload/screens/caminhoneiros/tela_listaCargas.dart';

class TelaFiltroCarga extends StatefulWidget {
  final String userId;

  const TelaFiltroCarga({super.key, required this.userId});

  @override
  State<TelaFiltroCarga> createState() => _TelaFiltroCargaState();
}

class _TelaFiltroCargaState extends State<TelaFiltroCarga> {
  final TextEditingController origemController = TextEditingController();
  final TextEditingController destinoController = TextEditingController();
  final TextEditingController pesoController = TextEditingController();

  String tipoSelecionado = '';
  List<String> todasCidades = [];
  final ApiService _apiService = ApiService();
  bool _buscando = false;

  @override
  void initState() {
    super.initState();
    carregarCidades();
  }

  Future<void> carregarCidades() async {
    // carregar lista de cidades
    try {
      final url = Uri.parse(
        'https://servicodados.ibge.gov.br/api/v1/localidades/municipios',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List dados = jsonDecode(response.body);
        final lista = dados.map((cidade) => cidade['nome'] as String).toList();

        setState(() {
          todasCidades = lista;
        });
      }
    } catch (e) {
      debugPrint('Erro ao carregar cidades: $e');
    }
  }

  List<String> filtrarCidades(String prefixo) {
    if (prefixo.isEmpty) {
      return [];
    }
    return todasCidades
        .where((nome) => nome.toLowerCase().startsWith(prefixo.toLowerCase()))
        .take(10) // Limitar a 10 sugestões para performance
        .toList();
  }

  Future<void> _buscarCargasDisponiveis() async {
    setState(() {
      _buscando = true;
    });

    try {
      // Preparar filtros
      final Map<String, dynamic> filtros = {};

      if (origemController.text.isNotEmpty) {
        filtros['origem'] = origemController.text.trim();
      }

      if (destinoController.text.isNotEmpty) {
        filtros['destino'] = destinoController.text.trim();
      }

      if (pesoController.text.isNotEmpty) {
        final peso = double.tryParse(pesoController.text);
        if (peso != null) {
          filtros['pesoMinimo'] = peso;
        }
      }

      if (tipoSelecionado.isNotEmpty) {
        filtros['tipoCarga'] = tipoSelecionado;
      }

      // Mostrar filtros aplicados
      final filtrosText = filtros.entries
          .map((e) => '${e.key}: ${e.value}')
          .join('\n');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              filtros.isEmpty
                  ? 'Nenhum filtro aplicado - mostrando todas as cargas disponíveis'
                  : 'Filtros aplicados:\n$filtrosText',
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }

      // Buscar cargas disponíveis na API
      final cargas = await _apiService.buscarCargasDisponiveis(filtros);

      if (!mounted) return;

      // Sempre navegar para a tela de lista de cargas
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TelaListaCargas(
            userId: widget.userId,
            cargas: cargas,
            filtrosAplicados: filtros,
          ),
        ),
      );

      // Mostrar feedback sobre a busca
      if (cargas.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Encontradas ${cargas.length} cargas disponíveis!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Nenhuma carga encontrada com os filtros aplicados.'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao buscar cargas: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _buscando = false;
        });
      }
    }
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
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => TelaMenu(userId: widget.userId),
              ),
            );
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Filtrar carga',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Filtre as cargas disponíveis de acordo com as suas preferências',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 20),

            // Campo origem
            campoAutocomplete(
              origemController,
              'Digite a cidade de origem',
              Icons.location_on,
            ),

            const SizedBox(height: 10),

            // Campo destino
            campoAutocomplete(
              destinoController,
              'Digite a cidade de destino',
              Icons.location_on,
            ),

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
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                botaoTipo('Seca'),
                botaoTipo('Frigorífica'),
                botaoTipo('Granel'),
                botaoTipo('Outros'),
              ],
            ),

            const Spacer(),

            ElevatedButton(
              onPressed: _buscando ? null : _buscarCargasDisponiveis,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _buscando
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'Buscar Cargas e Ver Resultados',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
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
  Widget campoAutocomplete(
    TextEditingController controller,
    String hint,
    IconData icon,
  ) {
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
                return filtrarCidades(textEditingValue.text);
              },
              onSelected: (String selection) {
                controller.text = selection;
              },
              fieldViewBuilder:
                  (
                    context,
                    textEditingController,
                    focusNode,
                    onFieldSubmitted,
                  ) {
                    textEditingController.text = controller.text;
                    textEditingController
                        .selection = TextSelection.fromPosition(
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
              keyboardType: somenteNumeros
                  ? TextInputType.number
                  : TextInputType.text,
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
            Text(sufixo, style: const TextStyle(fontWeight: FontWeight.bold)),
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: selecionado ? Colors.blue[300] : const Color(0xFFB0CCE5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: selecionado ? Colors.white : Colors.black,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
