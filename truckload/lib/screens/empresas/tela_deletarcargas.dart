import 'package:flutter/material.dart';
import 'tela_menuEmpresarial.dart';

class TelaDeletarCarga extends StatefulWidget {
  final VoidCallback onDelete; // callback para remover a carga

  const TelaDeletarCarga({super.key, required this.onDelete});

  @override
  State<TelaDeletarCarga> createState() => _TelaDeletarCargaState();
}

class _TelaDeletarCargaState extends State<TelaDeletarCarga> {
  String? motivoSelecionado;
  final TextEditingController outroController = TextEditingController();

  final List<String> motivos = [
    "Erro no cadastro da carga (informações incorretas ou incompletas).",
    "Mudança no planejamento logístico (rota, horário ou estratégia alterada).",
    "Carga já foi negociada fora da plataforma.",
    "Problemas com o cliente (cancelamento do pedido ou alteração de demanda).",
    "Preço/tarifa não atrativo (frete ficou inviável).",
    "Tempo de espera muito alto (atraso no carregamento ou descarregamento).",
    "Condições inadequadas de carga (peso, tipo de mercadoria, exigências não compatíveis).",
    "Outro (especificar)"
  ];

  void confirmarExclusao() {
    if (motivoSelecionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Selecione um motivo para cancelar.")),
      );
      return;
    }

    if (motivoSelecionado == "Outro (especificar)" &&
        outroController.text.trim().length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Escreva pelo menos 10 caracteres no motivo.")),
      );
      return;
    }

    // simulação
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Carga deletada com sucesso!")),
    );

    widget.onDelete(); // chama o callback que remove a carga
    Navigator.pop(context); // volta para Cargas Pendentes
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6F0FA),
      appBar: AppBar(
        title: const Text("Deletar carga"),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TelaMenuEmpresa()),
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Motivo principal do cancelamento:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...motivos.map((motivo) {
              return RadioListTile(
                title: Text(motivo),
                value: motivo,
                groupValue: motivoSelecionado,
                onChanged: (value) {
                  setState(() {
                    motivoSelecionado = value.toString();
                  });
                },
              );
            }).toList(),
            if (motivoSelecionado == "Outro (especificar)")
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: TextField(
                  controller: outroController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Escreva o motivo...",
                  ),
                ),
              ),
            const SizedBox(height: 16),
            const Text(
              "Você tem certeza que deseja cancelar?",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text(
              "Isso pode impactar sua reputação na plataforma.",
              style: TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton.icon(
                onPressed: confirmarExclusao,
                icon: const Icon(Icons.delete),
                label: const Text("Apagar Carga"),
                style: ElevatedButton.styleFrom(
                  backgroundColor:  const Color(0xFFB0CCE5),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}