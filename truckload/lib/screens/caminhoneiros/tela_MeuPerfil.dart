// lib/screens/caminhoneiros/tela_MeuPerfil.dart
import 'package:flutter/material.dart';
import 'package:truckload/services/api_service.dart';
import 'package:truckload/models/perfil_caminhoneiro.dart';
import 'package:truckload/screens/caminhoneiros/tela_menu.dart';
import 'package:truckload/screens/caminhoneiros/tela_editardados.dart';

class TelaMeuPerfil extends StatefulWidget {
  final String userId; // ObjectId em string

  const TelaMeuPerfil({super.key, required this.userId});

  @override
  State<TelaMeuPerfil> createState() => _TelaMeuPerfilState();
}

class _TelaMeuPerfilState extends State<TelaMeuPerfil> {
  bool _loading = true;
  String? _error;
  PerfilCaminhoneiro? _perfil;
  final ApiService _apiService = ApiService();

  Future<void> _carregarPerfil() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final perfilData = await _apiService.getPerfilCaminhoneiro(widget.userId);
      final perfil = PerfilCaminhoneiro.fromJson(perfilData);

      setState(() {
        _perfil = perfil;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Falha ao carregar: $e';
        _loading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _carregarPerfil();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6F0FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE6F0FA),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => TelaMenu(userId: widget.userId),
              ),
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black87),
            onPressed: _carregarPerfil,
            tooltip: 'Atualizar',
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? _erroView()
          : RefreshIndicator(
              onRefresh: _carregarPerfil,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _avatar(),
                    const SizedBox(height: 16),
                    Text(
                      _perfil?.nomeDisplay ?? 'Sem nome',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    campoInfo(
                      icon: Icons.star,
                      label: 'Avaliação:',
                      value:
                          '${_perfil?.avaliacaoDisplay ?? '0.0'} / 5 ⭐ (${_perfil?.avaliacaoQtd ?? 0} cargas)',
                    ),
                    campoInfo(
                      icon: Icons.cancel,
                      label: 'Taxa de cancelamentos:',
                      value: '${_perfil?.taxaCancelamentoDisplay ?? '0.0'}%',
                    ),
                    campoInfo(
                      icon: Icons.phone,
                      label: 'Contato:',
                      value: _perfil?.telefoneDisplay ?? '—',
                    ),
                    campoInfo(
                      icon: Icons.description,
                      label: 'Descrição:',
                      value: _perfil?.descricaoDisplay ?? 'Sem descrição',
                    ),
                    campoInfo(
                      icon: Icons.email,
                      label: 'E-mail:',
                      value: _perfil?.emailDisplay ?? '—',
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton.icon(
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AlterarDados(
                              userId: widget.userId,
                              nome: _perfil?.nome ?? '',
                              telefone: _perfil?.telefone ?? '',
                              descricao: _perfil?.descricao ?? '',
                              fotoUrl: _perfil?.fotoUrl ?? '',
                              email: _perfil?.email ?? '',
                            ),
                          ),
                        );
                        if (mounted) _carregarPerfil();
                      },
                      icon: const Icon(Icons.edit, color: Colors.black),
                      label: const Text(
                        'Alterar dados',
                        style: TextStyle(color: Colors.black),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Image.asset('assets/logo.png', height: 50),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _erroView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
            const SizedBox(height: 12),
            Text(_error ?? 'Erro', textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _carregarPerfil,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _avatar() {
    if (_perfil?.fotoUrl?.isNotEmpty == true) {
      return CircleAvatar(
        radius: 40,
        backgroundImage: NetworkImage(_perfil!.fotoUrl!),
        backgroundColor: Colors.grey.shade200,
      );
    }
    return const CircleAvatar(
      radius: 40,
      backgroundColor: Colors.grey,
      child: Icon(Icons.person, size: 40, color: Colors.white),
    );
  }

  Widget campoInfo({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFB0CCE5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon),
          const SizedBox(width: 10),
          Expanded(
            child: Text.rich(
              TextSpan(
                text: '$label ',
                style: const TextStyle(fontWeight: FontWeight.bold),
                children: [
                  TextSpan(
                    text: value,
                    style: const TextStyle(fontWeight: FontWeight.normal),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
