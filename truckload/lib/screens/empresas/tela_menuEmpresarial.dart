import 'package:flutter/material.dart';
import 'package:truckload/screens/empresas/tela_adicionarcarga.dart';
import 'package:truckload/screens/empresas/tela_cargasRealizadas.dart';
import 'package:truckload/screens/empresas/tela_cargasPendentes.dart';
import 'package:truckload/screens/empresas/tela_perfilEmpresarial.dart';
import 'package:truckload/screens/tela_inicial.dart';
import 'package:truckload/services/session_manager.dart';

class TelaMenuEmpresa extends StatelessWidget {
  final String? empresaId;

  const TelaMenuEmpresa({super.key, this.empresaId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6F0FA),
      body: Column(
        children: [
          const SizedBox(height: 60),
          const Text(
            'MENU',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 30),
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: const Color(0xFFB0CCE5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  menuItem(
                    context,
                    Icons.business_center,
                    'Perfil empresarial',
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              TelaPerfilEmpresa(empresaId: empresaId ?? ''),
                        ),
                      );
                    },
                  ),
                  divider(),
                  menuItem(
                    context,
                    Icons.add_circle_outline,
                    'Adicionar cargas',
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              AdicionarCarga(empresaId: empresaId ?? ''),
                        ),
                      );
                    },
                  ),
                  divider(),
                  menuItem(
                    context,
                    Icons.check_circle_outline,
                    'Cargas Realizadas',
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              CargasRealizadas(empresaId: empresaId ?? ''),
                        ),
                      );
                    },
                  ),
                  divider(),
                  menuItem(
                    context,
                    Icons.pending_actions_outlined,
                    'Cargas Pendentes',
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              CargasPendentes(empresaId: empresaId ?? ''),
                        ),
                      );
                    },
                  ),
                  divider(),
                  menuItem(context, Icons.logout, 'Sair', () {
                    _logoutEmpresa(context);
                  }),
                  divider(),
                  const Spacer(),
                  Image.asset('assets/logo.png', height: 60),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget menuItem(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        child: Row(
          children: [
            Icon(icon, size: 28, color: Colors.black87),
            const SizedBox(width: 16),
            Text(
              label,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget divider() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Divider(color: Colors.black54),
    );
  }

  // Função para logout da empresa
  void _logoutEmpresa(BuildContext context) async {
    try {
      // Mostrar diálogo de confirmação
      bool? confirmar = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Confirmar Logout'),
            content: const Text('Tem certeza que deseja sair?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Sair'),
              ),
            ],
          );
        },
      );

      if (confirmar == true) {
        // Verificar se o widget ainda está montado
        if (!context.mounted) return;

        // Mostrar loading
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) =>
              const Center(child: CircularProgressIndicator()),
        );

        try {
          // Limpar sessão atual
          await SessionManager.logout();

          // Chamar API de logout (opcional - pode ser implementado no futuro)
          // Por enquanto, apenas simula o logout
          await Future.delayed(const Duration(seconds: 1));

          // Verificar se o widget ainda está montado
          if (!context.mounted) return;

          // Fechar loading
          Navigator.of(context).pop();

          // Navegar para a tela inicial removendo todas as rotas anteriores
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const TelaInicial()),
            (Route<dynamic> route) => false,
          );

          // Mostrar mensagem de sucesso
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Logout realizado com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
        } catch (e) {
          // Verificar se o widget ainda está montado
          if (!context.mounted) return;

          // Fechar loading em caso de erro
          Navigator.of(context).pop();

          // Navegar para a tela inicial mesmo com erro
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const TelaInicial()),
            (Route<dynamic> route) => false,
          );
        }
      }
    } catch (e) {
      // Em caso de erro, ainda navega para a tela inicial
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const TelaInicial()),
          (Route<dynamic> route) => false,
        );
      }
    }
  }
}
