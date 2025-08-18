import 'package:flutter/material.dart';
import 'package:truckload/services/api_service.dart';
import 'package:truckload/models/perfil_empresa.dart';
import 'package:truckload/screens/empresas/tela_menuEmpresarial.dart';

class TelaPerfilEmpresa extends StatefulWidget {
  final String empresaId;

  const TelaPerfilEmpresa({super.key, required this.empresaId});

  @override
  State<TelaPerfilEmpresa> createState() => _TelaPerfilEmpresaState();
}

class _TelaPerfilEmpresaState extends State<TelaPerfilEmpresa> {
  bool _loading = true;
  String? _error;
  PerfilEmpresa? _perfil;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _carregarPerfil();
  }

  Future<void> _carregarPerfil() async {
    print(
      'DEBUG: Carregando perfil para empresa ID: ${widget.empresaId}',
    ); // Debug log
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      print('DEBUG: Chamando API getPerfilEmpresa...'); // Debug log
      final perfilData = await _apiService.getPerfilEmpresa(widget.empresaId);
      print('DEBUG: Dados recebidos da API: $perfilData'); // Debug log
      final perfil = PerfilEmpresa.fromJson(perfilData);

      setState(() {
        _perfil = perfil;
        _loading = false;
      });
    } catch (e) {
      print('DEBUG: Erro ao carregar perfil: $e'); // Debug log
      setState(() {
        _error = 'Falha ao carregar: $e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
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
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
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
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Erro: $_error'),
              ElevatedButton(
                onPressed: _carregarPerfil,
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }

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
        title: Text(
          _perfil?.nomeDisplay ?? 'Empresa',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundColor: Colors.grey,
              child: Icon(Icons.business, color: Colors.white, size: 40),
            ),
            const SizedBox(height: 15),

            buildInfoItem(
              Icons.star,
              "Avaliação:",
              "${_perfil?.avaliacaoDisplay ?? '0.0'} / 5.0 (de ${_perfil?.avaliacaoQtd ?? 0} avaliações)",
              iconColor: Colors.amber,
            ),
            buildInfoItem(
              Icons.check_circle,
              "Taxa de conclusão:",
              "${_perfil?.taxaConclusaoDisplay ?? '0.0'}% (${_perfil?.cargasConcluidas ?? 0}/${_perfil?.totalCargas ?? 0} cargas)",
              iconColor: Colors.green,
            ),
            buildInfoItem(Icons.badge, "CNPJ:", _perfil?.cnpjDisplay ?? '—'),
            buildInfoItem(
              Icons.location_on,
              "Endereço:",
              _perfil?.enderecoDisplay ?? '—',
            ),
            buildInfoItem(
              Icons.phone,
              "Contato:",
              _perfil?.telefoneDisplay ?? '—',
            ),
            buildInfoItem(Icons.email, "Email:", _perfil?.emailDisplay ?? '—'),
            buildInfoItem(
              Icons.description,
              "Descrição:",
              _perfil?.descricaoDisplay ?? '—',
            ),

            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[300],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              onPressed: () {
                // TODO: Implementar tela de edição
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Funcionalidade em desenvolvimento'),
                  ),
                );
              },
              icon: const Icon(Icons.edit, color: Colors.black),
              label: const Text(
                "Alterar dados",
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildInfoItem(
    IconData icon,
    String label,
    String value, {
    Color iconColor = Colors.black,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFB0CCE5),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              children: [
                Icon(icon, color: iconColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    value,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
