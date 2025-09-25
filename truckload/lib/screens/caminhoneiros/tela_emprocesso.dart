import 'package:flutter/material.dart';
import 'menu_screen.dart'; 

class EmProcessoScreen extends StatefulWidget {
  const EmProcessoScreen({super.key});

  @override
  State<EmProcessoScreen> createState() => _EmProcessoScreenState();
}

class _EmProcessoScreenState extends State<EmProcessoScreen> {
  bool chegadaConfirmada = false;
  String statusCarga = "Carga pendente";

  final String origem = "São Paulo, SP";
  final String destino = "Rio de Janeiro, RJ";
  final String alertas = "Paradas não planejadas";
  final String especificacoes = "Temperatura controlada";

  void confirmarEntrega() {
    setState(() {
      chegadaConfirmada = true;
      statusCarga = "Carga completa";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6F0FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE6F0FA),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black87),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MenuScreen()),
            );
          },
        ),
        title: const Text(
          "Em Processo",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  Image.asset("assets/logo.png", height: 100),
                  const SizedBox(height: 10),
                  Text(
                    statusCarga,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            const Text(
              "Localização:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.black87),
                const SizedBox(width: 8),
                Text(origem),
                const Spacer(),
                const Icon(Icons.check_circle, color: Colors.green),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.black87),
                const SizedBox(width: 8),
                Text(destino),
                const Spacer(),
                chegadaConfirmada
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : ElevatedButton(
                        onPressed: confirmarEntrega,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black87,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text("Confirmar chegada"),
                      ),
              ],
            ),

            const SizedBox(height: 30),

            const Text(
              "Alertas:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _infoCard(Icons.warning, alertas),

            const SizedBox(height: 20),

            const Text(
              "Especificações:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _infoCard(Icons.info_outline, especificacoes),

            const SizedBox(height: 20),

            const Text(
              "Chat com a empresa:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _infoCard(Icons.phone, "Entrar em contato"),
          ],
        ),
      ),
    );
  }

  Widget _infoCard(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.black87),
          const SizedBox(width: 10),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}