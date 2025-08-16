import 'package:flutter/material.dart';
import 'package:truckload/screens/caminhoneiros/tela_menu.dart';

// --- Tela Alterar Dados ---
class AlterarDados extends StatefulWidget {
  const AlterarDados({super.key});

  @override
  _AlterarDadosState createState() => _AlterarDadosState();
}

class _AlterarDadosState extends State<AlterarDados> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController contatoController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController senhaAtualController = TextEditingController();
  final TextEditingController novaSenhaController = TextEditingController();
  final TextEditingController sobreVoceController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Alterar dados"),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const TelaMenu()),
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Foto de perfil
              const CircleAvatar(
                radius: 40,
                child: Icon(Icons.person, size: 40),
              ),
              const SizedBox(height: 8),
              const Text(
                "Joao Pedro Piceli",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {},
                child: const Text("ALTERAR FOTO DE PERFIL"),
              ),
              const SizedBox(height: 20),

              // Contato
              _buildTextField(
                controller: contatoController,
                label: "Contato",
                icon: Icons.phone,
              ),
              const SizedBox(height: 12),

              // Email
              _buildTextField(
                controller: emailController,
                label: "Email",
                icon: Icons.email,
              ),
              const SizedBox(height: 12),

              // Senha Atual
              _buildTextField(
                controller: senhaAtualController,
                label: "Senha Atual",
                icon: Icons.lock,
                obscureText: true,
              ),
              const SizedBox(height: 12),

              // Nova Senha
              _buildTextField(
                controller: novaSenhaController,
                label: "Nova senha",
                icon: Icons.lock,
                obscureText: true,
              ),
              const SizedBox(height: 6),
              const Text(
                "Para alterar senha, favor inserir senha atual",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 12),

              // Sobre você
              _buildTextField(
                controller: sobreVoceController,
                label: "Sobre você",
                icon: Icons.assignment,
              ),
              const SizedBox(height: 20),

              // Botão salvar alterações
              ElevatedButton.icon(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Aqui você pode salvar as alterações
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Alterações salvas!")),
                    );
                  }
                },
                icon: const Icon(Icons.save),
                label: const Text("Salvar alterações"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        labelText: label,
        filled: true,
        fillColor: Colors.blue.shade100,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Campo obrigatório";
        }
        return null;
      },
    );
  }
}