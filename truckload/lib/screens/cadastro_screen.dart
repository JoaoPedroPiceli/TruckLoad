import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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

  Future<void> enviarCadastro() async {
    final url = tipoConta == 'caminhoneiro'
        ? Uri.parse('http://10.0.2.2:8000/caminhoneiros/')
        : Uri.parse('http://10.0.2.2:8000/empresas/');

    final body = tipoConta == 'caminhoneiro'
        ? {
            'nome': _usernameController.text,
            'email': _emailController.text,
            'cpf': _cpfCnpjController.text,
            'telefone': _telefoneController.text,
            'tipoCaminhao': 'simples', // placeholder
            'senha': _senhaController.text,
          }
        : {
            'nome': _usernameController.text,
            'email': _emailController.text,
            'cnpj': _cpfCnpjController.text,
            'telefone': _telefoneController.text,
            'endereco': 'endereço teste', // placeholder
            'senha': _senhaController.text,
          };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        print('Cadastro bem-sucedido: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cadastro realizado com sucesso!')),
        );
      } else {
        print('Erro no cadastro: ${response.body}');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro: ${response.body}')));
      }
    } catch (e) {
      print('Erro de conexão: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro de conexão com o servidor.')),
      );
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
              onPressed: enviarCadastro,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black87,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text('Criar conta'),
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
