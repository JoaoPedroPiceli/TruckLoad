import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'caminhoneiros/tela_menu.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  String? tipoConta; // nulo

  bool get camposPreenchidos =>
      _usernameController.text.isNotEmpty &&
      _senhaController.text.isNotEmpty &&
      tipoConta != null;

  Future<void> verificarLogin() async {
    final url = Uri.parse(
      tipoConta == 'caminhoneiro'
          ? 'http://10.0.2.2:8000/caminhoneiros/login/'
          : 'http://10.0.2.2:8000/empresas/login/',
    ); // URL de login com base no tipo de conta

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': _usernameController.text,
        'senha': _senhaController.text,
      }), // Requisição POST com username e senha
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login realizado com sucesso!')),
      );
      Navigator.push( // Muda para a TelaMenu
        context,
        MaterialPageRoute(builder: (context) => const TelaMenu()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuário ou senha inválidos.')),
      );
    }
  }

  Widget _inputField(String hint, TextEditingController controller, {bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(
          hintText: hint,
          border: const UnderlineInputBorder(),
        ),
        onChanged: (_) => setState(() {}), // Atualiza estado ao digitar
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6F0FA),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 60),
        child: Column(
          children: [
            Image.asset('assets/logo.png', height: 120),
            const SizedBox(height: 20),
            const Text(
              'Log In',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.indigo),
            ),
            const SizedBox(height: 30),
            _inputField('Username', _usernameController),
            _inputField('Senha', _senhaController, isPassword: true),
            const Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Esqueci a senha',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 30),

            // Botões de tipo de conta
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() => tipoConta = 'caminhoneiro');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        tipoConta == 'caminhoneiro' ? Colors.blue : Colors.white,
                    foregroundColor:
                        tipoConta == 'caminhoneiro' ? Colors.white : Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: const Text('CAMINHONEIRO'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() => tipoConta = 'empresa');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        tipoConta == 'empresa' ? Colors.blue : Colors.white,
                    foregroundColor:
                        tipoConta == 'empresa' ? Colors.white : Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: const Text('EMPRESA'),
                ),
              ],
            ),

            const SizedBox(height: 40),

            // Botão de ENTRAR
            ElevatedButton(
              onPressed: camposPreenchidos ? verificarLogin : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: camposPreenchidos ? Colors.indigo : Colors.grey[400],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 80),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text('ENTRAR'),
            ),
          ],
        ),
      ),
    );
  }
}