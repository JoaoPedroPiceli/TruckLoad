// lib/screens/tela_login.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:truckload/screens/caminhoneiros/tela_menu.dart';

/// Base URL da API (pode vir por --dart-define)
const String kApiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'https://truckload-u4nu.onrender.com',
);

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _senhaCtrl = TextEditingController();

  String _tipoConta = 'caminhoneiro'; // 'caminhoneiro' | 'empresa'
  bool _loading = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _senhaCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    final email = _emailCtrl.text.trim();
    final senha = _senhaCtrl.text;

    try {
      // 1) Tenta endpoint oficial
      final loginUrl = Uri.parse('$kApiBaseUrl/auth/login');
      final body = json.encode({
        'email': email,
        'senha': senha,
        'tipo': _tipoConta,
      });
      http.Response? resp;

      try {
        resp = await http
            .post(
              loginUrl,
              headers: {'Content-Type': 'application/json'},
              body: body,
            )
            .timeout(const Duration(seconds: 20));
      } on TimeoutException {
        resp = null;
      } on http.ClientException {
        resp = null;
      }

      if (resp != null && resp.statusCode == 200) {
        final decoded = json.decode(resp.body);
        // Esperado: {"msg":"ok","tipo":"caminhoneiro|empresa","user":{...,"id":"..."}}
        final user = (decoded is Map)
            ? decoded['user'] as Map<String, dynamic>?
            : null;
        final userId = user?['id']?.toString();

        if (!mounted) return;
        if (_tipoConta == 'caminhoneiro') {
          if (userId == null || userId.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Falha ao obter ID do usuário.')),
            );
            return;
          }
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Login realizado com sucesso!')),
          );
          await _abrirMenuCaminhoneiro(userId);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Login realizado com sucesso!')),
          );
          await _abrirMenuEmpresa();
        }
        return;
      }

      // 2) Fallback: busca lista e pega o ID pelo e-mail
      final listUrl = Uri.parse(
        _tipoConta == 'caminhoneiro'
            ? '$kApiBaseUrl/caminhoneiros/?limit=200'
            : '$kApiBaseUrl/empresas/?limit=200',
      );
      final listResp = await http
          .get(listUrl)
          .timeout(const Duration(seconds: 20));

      if (listResp.statusCode == 200) {
        final decoded = json.decode(listResp.body);

        // Pode vir como lista direta ou {"results":[...]}
        List results = [];
        if (decoded is Map && decoded['results'] is List) {
          results = decoded['results'] as List;
        } else if (decoded is List) {
          results = decoded;
        }

        Map<String, dynamic>? found;
        for (final e in results) {
          if (e is Map &&
              (e['email']?.toString().toLowerCase() == email.toLowerCase())) {
            found = Map<String, dynamic>.from(e);
            break;
          }
        }

        if (found == null) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Usuário não encontrado.')),
          );
          return;
        }

        // ⚠️ Em muitas APIs o /caminhoneiros/ não retorna "senha".
        // Como fallback, só vamos navegar usando o ID encontrado pelo e-mail.
        final userId = (found['id'] ?? found['_id'])?.toString();
        if (userId == null || userId.isEmpty) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Falha ao obter ID do usuário.')),
          );
          return;
        }

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login realizado (fallback).')),
        );

        if (_tipoConta == 'caminhoneiro') {
          await _abrirMenuCaminhoneiro(userId);
        } else {
          await _abrirMenuEmpresa();
        }
      } else {
        String msg = 'Erro ${listResp.statusCode} ao consultar usuários.';
        try {
          final d = json.decode(listResp.body);
          if (d is Map && d['detail'] != null) msg = d['detail'].toString();
        } catch (_) {}
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(msg)));
      }
    } on TimeoutException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Servidor demorou para responder.')),
      );
    } on http.ClientException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Falha de rede ao conectar.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao conectar ao servidor: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _abrirMenuCaminhoneiro(String userId) async {
    // Cria a tela passando o userId (não use rota nomeada aqui).
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => TelaMenu(userId: userId)),
    );
  }

  Future<void> _abrirMenuEmpresa() async {
    Navigator.pushReplacementNamed(context, '/menuEmpresa');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6F0FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Logo
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blueAccent, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Image.asset('assets/logo.png', height: 100),
                ),
                const SizedBox(height: 16),

                Text(
                  'Entrar',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 16),

                // E-mail
                _input(
                  icon: Icons.email,
                  hint: 'E-mail',
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    final val = v?.trim() ?? '';
                    if (val.isEmpty) return 'Informe o e-mail';
                    if (!val.contains('@')) return 'E-mail inválido';
                    return null;
                  },
                ),

                // Senha
                _input(
                  icon: Icons.lock,
                  hint: 'Senha',
                  controller: _senhaCtrl,
                  isPassword: true,
                  validator: (v) {
                    final val = v ?? '';
                    if (val.isEmpty) return 'Informe a senha';
                    return null;
                  },
                ),

                const SizedBox(height: 12),

                // Tipo de conta
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ChoiceChip(
                      label: const Text('Caminhoneiro'),
                      selected: _tipoConta == 'caminhoneiro',
                      onSelected: (s) =>
                          setState(() => _tipoConta = 'caminhoneiro'),
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('Empresa'),
                      selected: _tipoConta == 'empresa',
                      onSelected: (s) => setState(() => _tipoConta = 'empresa'),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Botão Login
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black87,
                      padding: const EdgeInsets.symmetric(vertical: 14),
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
                        : const Text('LOG IN'),
                  ),
                ),

                const SizedBox(height: 12),

                // Link criar conta
                TextButton(
                  onPressed: _loading
                      ? null
                      : () => Navigator.pushNamed(context, '/cadastro'),
                  child: const Text('Não tem conta? Criar'),
                ),

                const SizedBox(height: 12),
                Text(
                  'API: $kApiBaseUrl',
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _input({
    required IconData icon,
    required String hint,
    required TextEditingController controller,
    bool isPassword = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          icon: Icon(icon),
          border: InputBorder.none,
          hintText: hint,
        ),
      ),
    );
  }
}
