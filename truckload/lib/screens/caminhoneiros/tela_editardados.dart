// lib/screens/caminhoneiros/tela_editardados.dart
import 'package:flutter/material.dart';
import 'package:truckload/services/api_service.dart';

class AlterarDados extends StatefulWidget {
  final String userId;
  final String nome;
  final String telefone;
  final String descricao;
  final String fotoUrl;
  final String email;

  const AlterarDados({
    super.key,
    required this.userId,
    required this.nome,
    required this.telefone,
    required this.descricao,
    required this.fotoUrl,
    required this.email,
  });

  @override
  State<AlterarDados> createState() => _AlterarDadosState();
}

class _AlterarDadosState extends State<AlterarDados> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();

  late final TextEditingController _contatoCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _senhaAtualCtrl; // opcional (só UI)
  late final TextEditingController _novaSenhaCtrl;
  late final TextEditingController _sobreCtrl;
  late final TextEditingController _fotoUrlCtrl;
  late final TextEditingController _nomeCtrl;

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _contatoCtrl = TextEditingController(text: widget.telefone);
    _emailCtrl = TextEditingController(text: widget.email);
    _senhaAtualCtrl = TextEditingController();
    _novaSenhaCtrl = TextEditingController();
    _sobreCtrl = TextEditingController(text: widget.descricao);
    _fotoUrlCtrl = TextEditingController(text: widget.fotoUrl);
    _nomeCtrl = TextEditingController(text: widget.nome);
  }

  @override
  void dispose() {
    _contatoCtrl.dispose();
    _emailCtrl.dispose();
    _senhaAtualCtrl.dispose();
    _novaSenhaCtrl.dispose();
    _sobreCtrl.dispose();
    _fotoUrlCtrl.dispose();
    _nomeCtrl.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    // monta payload apenas com o que tem valor (evita sobrescrever com vazio)
    final Map<String, dynamic> update = {};
    if (_nomeCtrl.text.trim().isNotEmpty)
      update['nome'] = _nomeCtrl.text.trim();
    if (_emailCtrl.text.trim().isNotEmpty)
      update['email'] = _emailCtrl.text.trim();
    if (_contatoCtrl.text.trim().isNotEmpty)
      update['telefone'] = _contatoCtrl.text.trim();
    if (_sobreCtrl.text.trim().isNotEmpty)
      update['descricao'] = _sobreCtrl.text.trim();
    if (_fotoUrlCtrl.text.trim().isNotEmpty)
      update['fotoUrl'] = _fotoUrlCtrl.text.trim();
    if (_novaSenhaCtrl.text.isNotEmpty) update['senha'] = _novaSenhaCtrl.text;

    if (update.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nenhuma alteração para salvar.')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      await _apiService.atualizarCaminhoneiro(widget.userId, update);

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Dados atualizados!')));
      Navigator.pop(context, true); // volta informando sucesso
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Falha ao salvar: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6F0FA),
      appBar: AppBar(
        title: const Text(
          "Alterar dados",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Foto / nome
              _avatar(widget.fotoUrl),
              const SizedBox(height: 8),
              Text(
                widget.nome.isEmpty ? 'Sem nome' : widget.nome,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  /* implementar upload futuramente */
                },
                child: const Text("ALTERAR FOTO DE PERFIL"),
              ),
              const SizedBox(height: 20),

              _input(label: "Nome", icon: Icons.person, controller: _nomeCtrl),
              const SizedBox(height: 12),

              _input(
                label: "Contato (telefone)",
                icon: Icons.phone,
                controller: _contatoCtrl,
              ),
              const SizedBox(height: 12),

              _input(label: "Email", icon: Icons.email, controller: _emailCtrl),
              const SizedBox(height: 12),

              _input(
                label: "Senha Atual (opcional)",
                icon: Icons.lock,
                controller: _senhaAtualCtrl,
                obscureText: true,
              ),
              const SizedBox(height: 12),

              _input(
                label: "Nova senha (opcional)",
                icon: Icons.lock_outline,
                controller: _novaSenhaCtrl,
                obscureText: true,
              ),
              const SizedBox(height: 6),
              const Text(
                "Para alterar senha, preencha a nova senha. (No backend atual não é verificada a senha atual.)",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 12),

              _input(
                label: "Sobre você",
                icon: Icons.assignment,
                controller: _sobreCtrl,
                maxLines: 3,
              ),
              const SizedBox(height: 12),

              _input(
                label: "Foto (URL opcional)",
                icon: Icons.link,
                controller: _fotoUrlCtrl,
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _saving ? null : _salvar,
                  icon: _saving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save),
                  label: const Text("Salvar alterações"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _input({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    bool obscureText = false,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      maxLines: maxLines,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        labelText: label,
        filled: true,
        fillColor: Colors.blue.shade100,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (value) {
        if (maxLines == 1 && (value == null || value.trim().isEmpty)) {
          // só valida como obrigatório nos campos de uma linha (nome/telefone/email).
          // descrição/foto/senhas são opcionais.
          if (label == "Nome" ||
              label.startsWith("Contato") ||
              label == "Email") {
            return "Campo obrigatório";
          }
        }
        return null;
      },
    );
  }

  Widget _avatar(String url) {
    if (url.isNotEmpty) {
      return CircleAvatar(
        radius: 40,
        backgroundImage: NetworkImage(url),
        backgroundColor: Colors.grey.shade200,
      );
    }
    return const CircleAvatar(radius: 40, child: Icon(Icons.person, size: 40));
  }
}
