import 'package:flutter/material.dart';

class CargasPendentes extends StatefulWidget {
  @override
  _CargasPendentesState createState() => _CargasPendentesState();
}

class _CargasPendentesState extends State<CargasPendentes> {
  List<Map<String, String>> esperandoAprovacao = [
    {
      "nome": "Nome da Empresa",
      "origem": "São Paulo",
      "destino": "Rio de Janeiro",
      "peso": "500kg",
      "data": "15/08/2025",
    },
  ];

  List<Map<String, String>> cargasAprovadas = [
    {
      "nome": "João Caminhoneiro",
      "origem": "Belo Horizonte",
      "destino": "Brasília",
      "peso": "800kg",
    },
  ];

  void selecionarCaminhoneiro(int index) {
    setState(() {
      var carga = esperandoAprovacao.removeAt(index);
      carga["nome"] = "Nome do Caminhoneiro"; // Aqui poderia ser selecionado de uma lista
      cargasAprovadas.add(carga);
    });
  }

  void deletarCarga(List<Map<String, String>> lista, int index) {
    setState(() {
      lista.removeAt(index);
    });
  }

  void editarCarga(Map<String, String> carga) {
    // Aqui você pode abrir uma tela para edição
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Função de editar carga ainda não implementada")),
    );
  }

  Widget cardCarga({
    required Map<String, String> carga,
    required VoidCallback onDelete,
    required VoidCallback onEdit,
    VoidCallback? onSelecionar,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[100],
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          const CircleAvatar(radius: 25, child: Icon(Icons.person, size: 30)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("CARGA", style: TextStyle(fontWeight: FontWeight.bold)),
                Text("Origem: ${carga["origem"]}"),
                Text("Destino: ${carga["destino"]}"),
                Text("Peso: ${carga["peso"]}"),
                if (carga.containsKey("data")) Text("Data: ${carga["data"]}"),
                const SizedBox(height: 6),
                Row(
                  children: [
                    if (onSelecionar != null)
                      ElevatedButton(
                        onPressed: onSelecionar,
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                        child: const Text("Selecionar Caminhoneiro",
                            style: TextStyle(color: Colors.black)),
                      ),
                    const SizedBox(width: 6),
                    ElevatedButton(
                      onPressed: onEdit,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                      child: const Text("Editar Carga",
                          style: TextStyle(color: Colors.black)),
                    ),
                    const SizedBox(width: 6),
                    ElevatedButton(
                      onPressed: onDelete,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                      child: const Text("Deletar Carga",
                          style: TextStyle(color: Colors.black)),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            // Abrir tela de menu empresarial
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Abrir Menu Empresarial")),
            );
          },
        ),
        title: const Text("Cargas Postadas:"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFEAF3FA),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Esperando aprovação:",
                style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            for (int i = 0; i < esperandoAprovacao.length; i++)
              cardCarga(
                carga: esperandoAprovacao[i],
                onSelecionar: () => selecionarCaminhoneiro(i),
                onEdit: () => editarCarga(esperandoAprovacao[i]),
                onDelete: () => deletarCarga(esperandoAprovacao, i),
              ),
            const SizedBox(height: 20),
            const Text("Cargas aprovadas:",
                style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            for (int i = 0; i < cargasAprovadas.length; i++)
              cardCarga(
                carga: cargasAprovadas[i],
                onEdit: () => editarCarga(cargasAprovadas[i]),
                onDelete: () => deletarCarga(cargasAprovadas, i),
              ),
            const SizedBox(height: 40),
            Center(
              child: Column(
                children: [
                  Icon(Icons.local_shipping, size: 60, color: Colors.blue),
                  const SizedBox(height: 5),
                  const Text("TruckLoad",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}