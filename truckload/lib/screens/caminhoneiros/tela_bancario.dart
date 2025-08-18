// lib/screens/caminhoneiros/tela_bancario.dart
import 'package:flutter/material.dart';
import 'package:truckload/services/api_service.dart';
import 'tela_menu.dart';

class TelaBancario extends StatefulWidget {
  final String userId; // <- obrigatório
  final String nomeCaminhoneiro; // opcional, só para exibir

  const TelaBancario({
    super.key,
    required this.userId, // <- agora exigimos userId
    this.nomeCaminhoneiro = '',
  });

  @override
  State<TelaBancario> createState() => _TelaBancarioState();
}

class _TelaBancarioState extends State<TelaBancario> {
  bool saldoVisivel = false;
  double saldo = 0.0;
  bool _loading = true;
  String? _error;
  String _nomeCaminhoneiro = '';
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final perfil = await _apiService.getPerfilCaminhoneiro(widget.userId);

      setState(() {
        _nomeCaminhoneiro = perfil['nome'] ?? '';
        // Por enquanto, saldo é simulado baseado na avaliação média
        saldo = (perfil['avaliacao_media'] ?? 0.0) * 100;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
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
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
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
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Erro: $_error'),
              ElevatedButton(
                onPressed: _carregarDados,
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
        backgroundColor: const Color(0xFFE6F0FA),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black),
          onPressed: () {
            // volta para o menu passando o mesmo userId
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
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            // Foto e nome
            Row(
              children: [
                const CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.grey,
                  child: Icon(Icons.person, color: Colors.white, size: 35),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _nomeCaminhoneiro.isNotEmpty
                          ? _nomeCaminhoneiro
                          : 'Caminhoneiro',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        const Text("Saldo: ", style: TextStyle(fontSize: 16)),
                        Text(
                          saldoVisivel
                              ? "R\$ ${saldo.toStringAsFixed(2)}"
                              : "•••",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            saldoVisivel
                                ? Icons.visibility
                                : Icons.visibility_off,
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() => saldoVisivel = !saldoVisivel);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 30),

            // Botões
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                children: [
                  botaoAcao(Icons.receipt_long, "Extrato"),
                  botaoAcao(Icons.edit, "Alterar dados"),
                  botaoAcao(Icons.history, "Transações recentes"),
                  botaoAcao(Icons.schedule, "Transações pendentes"),
                  botaoAcao(Icons.compare_arrows, "Transferir"),
                ],
              ),
            ),

            // Logo
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Image.asset('assets/logo.png', height: 50),
            ),
          ],
        ),
      ),
    );
  }

  Widget botaoAcao(IconData icone, String titulo) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.all(16),
      ),
      onPressed: () {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("$titulo clicado")));
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icone, size: 40, color: Colors.black),
          const SizedBox(height: 8),
          Text(
            titulo,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
