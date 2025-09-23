import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const String _sessionKey = 'user_sessions';
  static const String _currentSessionKey = 'current_session';

  // Estrutura de uma sessão
  static Map<String, dynamic> createSession({
    required String userId,
    required String email,
    required String tipo,
    required String nome,
    String? empresaId,
  }) {
    return {
      'sessionId': DateTime.now().millisecondsSinceEpoch.toString(),
      'userId': userId,
      'email': email,
      'tipo': tipo,
      'nome': nome,
      'empresaId': empresaId,
      'loginTime': DateTime.now().toIso8601String(),
      'lastActivity': DateTime.now().toIso8601String(),
      'isActive': true,
    };
  }

  // Salvar sessão atual
  static Future<void> saveCurrentSession(Map<String, dynamic> session) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentSessionKey, jsonEncode(session));
  }

  // Obter sessão atual
  static Future<Map<String, dynamic>?> getCurrentSession() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionData = prefs.getString(_currentSessionKey);

    if (sessionData != null) {
      try {
        final session = jsonDecode(sessionData) as Map<String, dynamic>;
        // Verificar se a sessão ainda é válida (24 horas)
        final loginTime = DateTime.parse(session['loginTime']);
        final now = DateTime.now();
        final difference = now.difference(loginTime);

        if (difference.inHours < 24 && session['isActive'] == true) {
          // Atualizar última atividade
          session['lastActivity'] = now.toIso8601String();
          await saveCurrentSession(session);
          return session;
        } else {
          // Sessão expirada, limpar
          await clearCurrentSession();
          return null;
        }
      } catch (e) {
        // Dados corrompidos, limpar
        await clearCurrentSession();
        return null;
      }
    }
    return null;
  }

  // Limpar sessão atual
  static Future<void> clearCurrentSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentSessionKey);
  }

  // Verificar se há sessão ativa
  static Future<bool> hasActiveSession() async {
    final session = await getCurrentSession();
    return session != null;
  }

  // Fazer logout (limpar sessão)
  static Future<void> logout() async {
    await clearCurrentSession();
  }

  // Obter informações do usuário logado
  static Future<Map<String, dynamic>?> getCurrentUser() async {
    final session = await getCurrentSession();
    if (session != null) {
      return {
        'userId': session['userId'],
        'email': session['email'],
        'tipo': session['tipo'],
        'nome': session['nome'],
        'empresaId': session['empresaId'],
      };
    }
    return null;
  }

  // Atualizar última atividade
  static Future<void> updateLastActivity() async {
    final session = await getCurrentSession();
    if (session != null) {
      session['lastActivity'] = DateTime.now().toIso8601String();
      await saveCurrentSession(session);
    }
  }

  // Verificar se o usuário é caminhoneiro
  static Future<bool> isCaminhoneiro() async {
    final user = await getCurrentUser();
    return user?['tipo'] == 'caminhoneiro';
  }

  // Verificar se o usuário é empresa
  static Future<bool> isEmpresa() async {
    final user = await getCurrentUser();
    return user?['tipo'] == 'empresa';
  }

  // Obter ID do usuário atual
  static Future<String?> getCurrentUserId() async {
    final user = await getCurrentUser();
    return user?['userId'];
  }

  // Obter email do usuário atual
  static Future<String?> getCurrentUserEmail() async {
    final user = await getCurrentUser();
    return user?['email'];
  }
}
