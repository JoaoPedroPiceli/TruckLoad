import 'dart:async';
import 'dart:convert';
import 'package:truckload/screens/tela_login.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // <- para TextInputFormatter
import 'package:http/http.dart' as http;
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class CadastroScreen extends StatefulWidget {
  const CadastroScreen({super.key});

  @override
  State<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  // ---- FORM ----
  final _formKey = GlobalKey<FormState>();

  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _cpfCnpjController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _senhaController = TextEditingController();

  String tipoConta = 'caminhoneiro'; // 'caminhoneiro' | 'empresa'
  bool _loading = false;

  // Base URL da API (Render)
  static const String baseUrl = 'https://truckload-u4nu.onrender.com';

  // ---- MASKS ----
  final _cpfFormatter = MaskTextInputFormatter(
    mask: '###.###.###-##',
    filter: {"#": RegExp(r'\d')},
    type: MaskAutoCompletionType.lazy,
  );

  final _cnpjFormatter = MaskTextInputFormatter(
    mask: '##.###.###/####-##',
    filter: {"#": RegExp(r'\d')},
    type: MaskAutoCompletionType.lazy,
  );

  // Telefone dinâmico (10 ou 11 dígitos)
  final _phoneFormatter = MaskTextInputFormatter(
    mask: '(##) #####-####', // começa como celular (11)
    filter: {"#": RegExp(r'\d')},
    type: MaskAutoCompletionType.lazy,
  );

  // ---- HELPERS ----
  String _soDigitos(String v) => v.replaceAll(RegExp(r'[^0-9]'), '');

  bool _emailValido(String email) {
    final re = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]{2,}$');
    return re.hasMatch(email.trim());
  }

  bool _telefoneValido(String telefone) {
    final d = _soDigitos(telefone);
    return d.length == 10 || d.length == 11;
  }

  bool _cpfValido(String cpf) {
    final d = _soDigitos(cpf);
    if (d.length != 11) return false;
    if (RegExp(r'^(\d)\1{10}$').hasMatch(d)) return false;

    int soma = 0;
    for (int i = 0; i < 9; i++) {
      soma += int.parse(d[i]) * (10 - i);
    }
    int dv1 = 11 - (soma % 11);
    if (dv1 >= 10) dv1 = 0;

    soma = 0;
    for (int i = 0; i < 10; i++) {
      soma += int.parse(d[i]) * (11 - i);
    }
    int dv2 = 11 - (soma % 11);
    if (dv2 >= 10) dv2 = 0;

    return d[9] == '$dv1' && d[10] == '$dv2';
  }

  bool _cnpjValido(String cnpj) {
    final d = _soDigitos(cnpj);
    if (d.length != 14) return false;
    if (RegExp(r'^(\d)\1{13}$').hasMatch(d)) return false;

    List<int> n = d.split('').map(int.parse).toList();

    int _dv(List<int> base) {
      const pesos = [6, 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2];
      int soma = 0;
      int off = pesos.length - base.length;
      for (int i = 0; i < base.length; i++) {
        soma += base[i] * pesos[i + off];
      }
      int resto = soma % 11;
      return resto < 2 ? 0 : 11 - resto;
    }

    final d1 = _dv(n.sublist(0, 12));
    final d2 = _dv([...n.sublist(0, 12), d1]);
    return n[12] == d1 && n[13] == d2;
  }

  void _ajustarMascaraTelefone(String value) {
    final digits = _soDigitos(value);
    if (digits.length <= 10) {
      _phoneFormatter.updateMask(mask: '(##) ####-####'); // fixo (10)
    } else {
      _phoneFormatter.updateMask(mask: '(##) #####-####'); // celular (11)
    }
  }

  // ---- SUBMIT ----
  Future<void> _enviarCadastro() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final endpoint = tipoConta == 'caminhoneiro'
        ? '/caminhoneiros/'
        : '/empresas/';
    final url = Uri.parse('$baseUrl$endpoint');

    final body = tipoConta == 'caminhoneiro'
        ? {
            'nome': _usernameController.text.trim(),
            'email': _emailController.text.trim(),
            'cpf': _soDigitos(_cpfCnpjController.text),
            'telefone': _soDigitos(_telefoneController.text),
            'tipoCaminhao': 'simples',
            'senha': _senhaController.text,
          }
        : {
            'nome': _usernameController.text.trim(),
            'email': _emailController.text.trim(),
            'cnpj': _soDigitos(_cpfCnpjController.text),
            'telefone': _soDigitos(_telefoneController.text),
            'endereco': 'endereço teste',
            'senha': _senhaController.text,
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

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cadastro realizado com sucesso!')),
        );
        Navigator.pop(context);
      } else {
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(msg)));
      }
    } on TimeoutException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Servidor demorou para responder.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao enviar: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ---- UI ----
  @override
  Widget build(BuildContext context) {
    final isCaminhoneiro = tipoConta == 'caminhoneiro';
    final docLabel = isCaminhoneiro ? 'CPF' : 'CNPJ';
    final docFormatter = isCaminhoneiro ? _cpfFormatter : _cnpjFormatter;

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Crie uma conta\nno Truck Load',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),

              _inputField(
                icon: Icons.person,
                hint: 'Username',
                controller: _usernameController,
                validator: (v) {
                  if (v == null || v.trim().isEmpty)
                    return 'Informe seu nome/username';
                  if (v.trim().length < 3) return 'Mínimo de 3 caracteres';
                  return null;
                },
              ),
              _inputField(
                icon: Icons.email,
                hint: 'E-mail',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Informe o e-mail';
                  if (!_emailValido(v)) return 'E-mail inválido';
                  return null;
                },
              ),
              _inputField(
                icon: Icons.badge,
                hint: docLabel,
                controller: _cpfCnpjController,
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[docFormatter],
                validator: (v) {
                  final val = v?.trim() ?? '';
                  if (val.isEmpty) return 'Informe $docLabel';
                  return isCaminhoneiro
                      ? (_cpfValido(val) ? null : 'CPF inválido')
                      : (_cnpjValido(val) ? null : 'CNPJ inválido');
                },
              ),
              _inputField(
                icon: Icons.phone,
                hint: 'Telefone (com DDD)',
                controller: _telefoneController,
                keyboardType: TextInputType.phone,
                inputFormatters: <TextInputFormatter>[_phoneFormatter],
                onChanged: _ajustarMascaraTelefone,
                validator: (v) {
                  if (v == null || v.trim().isEmpty)
                    return 'Informe o telefone';
                  if (!_telefoneValido(v))
                    return 'Telefone inválido (use 10 ou 11 dígitos)';
                  return null;
                },
              ),
              _inputField(
                icon: Icons.lock,
                hint: 'Senha',
                controller: _senhaController,
                isPassword: true,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Informe a senha';
                  if (v.length < 6) return 'Mínimo de 6 caracteres';
                  return null;
                },
              ),

              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _tipoButton('CAMINHONEIRO', 'caminhoneiro'),
                  _tipoButton('EMPRESA', 'empresa'),
                ],
              ),

              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loading ? null : _enviarCadastro,
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

              const SizedBox(height: 12),
              TextButton(
                onPressed: _loading
                    ? null
                    : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                        );
                      },
                child: const Text(
                  'Já possui uma conta? Entrar',
                  style: TextStyle(color: Colors.black87),
                ),
              ),

              const SizedBox(height: 12),
              // Logo do TruckLoad
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blueAccent, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(16),
                child: Image.asset('assets/logo.png', height: 60),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---- WIDGET BASE ----
  Widget _inputField({
    required IconData icon,
    required String hint,
    required TextEditingController controller,
    String? Function(String?)? validator,
    bool isPassword = false,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters, // <- tipado corretamente
    void Function(String)? onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        onChanged: onChanged,
        decoration: InputDecoration(
          icon: Icon(icon),
          border: InputBorder.none,
          hintText: hint,
        ),
        validator: validator,
      ),
    );
  }

  Widget _tipoButton(String label, String value) {
    final isSelected = tipoConta == value;
    return ElevatedButton(
      onPressed: _loading
          ? null
          : () {
              setState(() {
                tipoConta = value;
                _cpfCnpjController.clear(); // limpa quando muda o tipo
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

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _cpfCnpjController.dispose();
    _telefoneController.dispose();
    _senhaController.dispose();
    super.dispose();
    // (formatters não precisam de dispose)
  }
}
