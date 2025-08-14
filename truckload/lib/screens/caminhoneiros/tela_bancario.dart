import 'package:flutter/material.dart';
import 'tela_menu.dart'; 

class TelaBancario extends StatefulWidget {
  final String nomeCaminhoneiro;

  const TelaBancario({super.key, this.nomeCaminhoneiro = ''});

  @override
  State<TelaBancario> createState() => _TelaBancarioState();
}

class _TelaBancarioState extends State<TelaBancario> {
  bool saldoVisivel = false;
  double saldo = 1234.56; // valor de exemplo

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6F0FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE6F0FA),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const TelaMenu()),
            );
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            // Foto e nome
            Row(
              children: [
                const CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.grey,
                  child: Icon(Icons.person, color: Colors.white, size: 35),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.nomeCaminhoneiro.isNotEmpty
                          ? widget.nomeCaminhoneiro
                          : 'Caminhoneiro',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        const Text("Saldo: ",
                            style: TextStyle(fontSize: 16)),
                        Text(
                          saldoVisivel
                              ? "R\$ ${saldo.toStringAsFixed(2)}"
                              : "•••",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            saldoVisivel
                                ? Icons.visibility
                                : Icons.visibility_off,
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() {
                              saldoVisivel = !saldoVisivel;
                            });
                          },
                        )
                      ],
                    )
                  ],
                )
              ],
            ),

            const SizedBox(height: 30),

            // Botões
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                children: [
                  botaoAcao(Icons.receipt_long, "Extrato"),
                  botaoAcao(Icons.edit, "Alterar dados"),
                  botaoAcao(Icons.history, "Transações recentes"),
                  botaoAcao(Icons.schedule, "Transações pendentes"),
                  botaoAcao(Icons.compare_arrows, "Transferir"),
                ],
              ),
            ),

            // Logo
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Image.asset('assets/logo.png', height: 50)

            )
          ],
        ),
      ),
    );
  }

  Widget botaoAcao(IconData icone, String titulo) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.all(16),
      ),
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("$titulo clicado")),
        );
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icone, size: 40, color: Colors.black),
          const SizedBox(height: 8),
          Text(
            titulo,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
          ),
        ],
      ),
    );
  }
}