import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/// Base URL da API (pode vir por --dart-define)
const String kApiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'https://truckload-u4nu.onrender.com',
);

class CadastroScreen extends StatefulWidget {
  const CadastroScreen({super.key});

  @override
  State<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _cpfCnpjController = TextEditingController();
  final TextEditingController _telefoneController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();

  String tipoConta = 'caminhoneiro';
  bool _loading = false;

  Future<void> enviarCadastro() async {
    final Uri url = tipoConta == 'caminhoneiro'
        ? Uri.parse('$kApiBaseUrl/caminhoneiros/')
        : Uri.parse('$kApiBaseUrl/empresas/');

    // Monte o body conforme o tipo de conta (não enviamos senha aqui)
    final Map<String, dynamic> body = tipoConta == 'caminhoneiro'
        ? {
            'nome': _usernameController.text.trim(),
            'email': _emailController.text.trim(),
            'cpf': _cpfCnpjController.text.trim(),
            'telefone': _telefoneController.text.trim(),
            'tipoCaminhao': 'simples', // TODO: pegar da UI quando tiver
          }
        : {
            'nome': _usernameController.text.trim(),
            'email': _emailController.text.trim(),
            'cnpj': _cpfCnpjController.text.trim(),
            'telefone': _telefoneController.text.trim(),
            'endereco': 'endereço teste', // TODO: pegar da UI quando tiver
          };

    setState(() => _loading = true);
    try {
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: json.encode(body),
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        debugPrint('Cadastro OK: $data');
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cadastro realizado com sucesso!')),
        );
        // TODO: navegar para outra tela se quiser
      } else {
        // tenta extrair mensagem vinda da API
        String msg = 'Erro ${response.statusCode}';
        try {
          final decoded = json.decode(response.body);
          if (decoded is Map && decoded['detail'] != null) {
            msg = decoded['detail'].toString();
          } else if (decoded is Map && decoded['msg'] != null) {
            msg = decoded['msg'].toString();
          } else {
            msg = response.body.toString();
          }
        } catch (_) {
          msg = response.body.toString();
        }
        debugPrint(
          'Falha no cadastro: ${response.statusCode} - ${response.body}',
        );
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro: $msg')));
      }
    } on http.ClientException catch (e) {
      debugPrint('ClientException: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Falha de rede ao conectar.')),
      );
    } on TimeoutException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Servidor demorou para responder.')),
      );
    } catch (e) {
      debugPrint('Erro inesperado: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao conectar ao servidor.')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6F0FA),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Crie uma conta\nno Truck Load',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            _inputField(Icons.person, 'Username', _usernameController),
            _inputField(Icons.email, 'E-mail', _emailController),
            _inputField(Icons.badge, 'CPF ou CNPJ', _cpfCnpjController),
            _inputField(Icons.phone, 'Telefone', _telefoneController),
            _inputField(
              Icons.lock,
              'Senha',
              _senhaController,
              isPassword: true,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _tipoButton('CAMINHONEIRO', 'caminhoneiro'),
                _tipoButton('EMPRESA', 'empresa'),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loading ? null : enviarCadastro,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black87,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: _loading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Criar conta'),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                // TODO: Navegar para tela de login
              },
              child: const Text(
                'Já possui uma conta? Entrar',
                style: TextStyle(color: Colors.black87),
              ),
            ),
            const SizedBox(height: 16),
            Image.asset('assets/logo.png', height: 60),
            const SizedBox(height: 24),
            Center(
              child: Text(
                'API: $kApiBaseUrl',
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _inputField(
    IconData icon,
    String hint,
    TextEditingController controller, {
    bool isPassword = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(
          icon: Icon(icon),
          border: InputBorder.none,
          hintText: hint,
        ),
      ),
    );
  }

  Widget _tipoButton(String label, String value) {
    final isSelected = tipoConta == value;
    return ElevatedButton(
      onPressed: () {
        setState(() {
          tipoConta = value;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.blueAccent : Colors.white,
        foregroundColor: isSelected ? Colors.white : Colors.black87,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
      child: Text(label),
    );
  }
}
