import 'dart:convert';
import 'package:http/http.dart' as http;

/// Base URL da API
const String kApiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'https://truckload-u4nu.onrender.com',
);

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  /// Obter perfil completo do caminhoneiro com métricas
  Future<Map<String, dynamic>> getPerfilCaminhoneiro(String userId) async {
    try {
      final url = Uri.parse('$kApiBaseUrl/perfil/caminhoneiro/$userId');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Erro ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Falha ao carregar perfil: $e');
    }
  }

  /// Obter dados básicos do caminhoneiro
  Future<Map<String, dynamic>> getCaminhoneiro(String userId) async {
    try {
      final url = Uri.parse('$kApiBaseUrl/caminhoneiros/$userId');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Erro ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Falha ao carregar dados: $e');
    }
  }

  /// Atualizar dados do caminhoneiro
  Future<Map<String, dynamic>> atualizarCaminhoneiro(
    String userId,
    Map<String, dynamic> dados,
  ) async {
    try {
      final url = Uri.parse('$kApiBaseUrl/caminhoneiros/$userId');
      final response = await http.patch(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(dados),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Erro ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Falha ao atualizar dados: $e');
    }
  }

  /// Obter histórico de cargas do caminhoneiro
  Future<List<Map<String, dynamic>>> getCargasCaminhoneiro(
    String userId,
  ) async {
    try {
      final url = Uri.parse('$kApiBaseUrl/cargas/?caminhoneiroId=$userId');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Erro ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Falha ao carregar cargas: $e');
    }
  }

  /// Obter avaliações do caminhoneiro
  Future<List<Map<String, dynamic>>> getAvaliacoesCaminhoneiro(
    String userId,
  ) async {
    try {
      final url = Uri.parse('$kApiBaseUrl/avaliacoes/?caminhoneiroId=$userId');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Erro ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Falha ao carregar avaliações: $e');
    }
  }

  /// Criar nova carga
  Future<Map<String, dynamic>> criarCarga(Map<String, dynamic> dados) async {
    try {
      final url = Uri.parse('$kApiBaseUrl/cargas/');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(dados),
      );

      if (response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception('Erro ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Falha ao criar carga: $e');
    }
  }

  /// Atualizar status de uma carga
  Future<Map<String, dynamic>> atualizarCarga(
    String cargaId,
    Map<String, dynamic> dados,
  ) async {
    try {
      final url = Uri.parse('$kApiBaseUrl/cargas/$cargaId');
      final response = await http.patch(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(dados),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Erro ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Falha ao atualizar carga: $e');
    }
  }

  /// Criar avaliação
  Future<Map<String, dynamic>> criarAvaliacao(
    Map<String, dynamic> dados,
  ) async {
    try {
      final url = Uri.parse('$kApiBaseUrl/avaliacoes/');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(dados),
      );

      if (response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception('Erro ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Falha ao criar avaliação: $e');
    }
  }

  /// Buscar cargas disponíveis com filtros
  Future<List<Map<String, dynamic>>> buscarCargasDisponiveis(
    Map<String, dynamic> filtros,
  ) async {
    try {
      // Construir query parameters
      final queryParams = <String, String>{};

      if (filtros.containsKey('origem')) {
        queryParams['origem'] = filtros['origem'];
      }

      if (filtros.containsKey('destino')) {
        queryParams['destino'] = filtros['destino'];
      }

      if (filtros.containsKey('pesoMinimo')) {
        queryParams['pesoMin'] = filtros['pesoMinimo'].toString();
      }

      if (filtros.containsKey('pesoMaximo')) {
        queryParams['pesoMax'] = filtros['pesoMaximo'].toString();
      }

      if (filtros.containsKey('precoMinimo')) {
        queryParams['precoMin'] = filtros['precoMinimo'].toString();
      }

      if (filtros.containsKey('precoMaximo')) {
        queryParams['precoMax'] = filtros['precoMaximo'].toString();
      }

      if (filtros.containsKey('tipoCarga')) {
        queryParams['tipoCarga'] = filtros['tipoCarga'];
      }

      final uri = Uri.parse(
        '$kApiBaseUrl/cargas/disponiveis',
      ).replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Erro ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Falha ao buscar cargas disponíveis: $e');
    }
  }

  // =============================================================================
  // Métodos para Empresas
  // =============================================================================

  /// Obter perfil completo da empresa com métricas
  Future<Map<String, dynamic>> getPerfilEmpresa(String empresaId) async {
    try {
      final url = Uri.parse('$kApiBaseUrl/perfil/empresa/$empresaId');
      print('DEBUG: API Service - URL chamada: $url'); // Debug log
      final response = await http.get(url);
      print(
        'DEBUG: API Service - Status code: ${response.statusCode}',
      ); // Debug log
      print(
        'DEBUG: API Service - Response body: ${response.body}',
      ); // Debug log

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Erro ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('DEBUG: API Service - Erro: $e'); // Debug log
      throw Exception('Falha ao carregar perfil da empresa: $e');
    }
  }

  /// Obter dados básicos da empresa
  Future<Map<String, dynamic>> getEmpresa(String empresaId) async {
    try {
      final url = Uri.parse('$kApiBaseUrl/empresas/$empresaId');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Erro ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Falha ao carregar dados da empresa: $e');
    }
  }

  /// Atualizar dados da empresa
  Future<Map<String, dynamic>> atualizarEmpresa(
    String empresaId,
    Map<String, dynamic> dados,
  ) async {
    try {
      final url = Uri.parse('$kApiBaseUrl/empresas/$empresaId');
      final response = await http.patch(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(dados),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Erro ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Falha ao atualizar dados da empresa: $e');
    }
  }

  /// Obter cargas da empresa
  Future<List<Map<String, dynamic>>> getCargasEmpresa(String empresaId) async {
    try {
      final url = Uri.parse(
        '$kApiBaseUrl/cargas-empresa/?empresaId=$empresaId',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Erro ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Falha ao carregar cargas da empresa: $e');
    }
  }

  /// Obter cargas da empresa por status
  Future<List<Map<String, dynamic>>> getCargasEmpresaPorStatus(
    String empresaId,
    String status,
  ) async {
    try {
      final url = Uri.parse(
        '$kApiBaseUrl/cargas-empresa/?empresaId=$empresaId&status=$status',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Erro ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Falha ao carregar cargas da empresa: $e');
    }
  }

  /// Criar nova carga para empresa
  Future<Map<String, dynamic>> criarCargaEmpresa(
    Map<String, dynamic> dados,
  ) async {
    try {
      final url = Uri.parse('$kApiBaseUrl/cargas-empresa/');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(dados),
      );

      if (response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception('Erro ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Falha ao criar carga empresarial: $e');
    }
  }

  /// Atualizar carga da empresa
  Future<Map<String, dynamic>> atualizarCargaEmpresa(
    String cargaId,
    Map<String, dynamic> dados,
  ) async {
    try {
      final url = Uri.parse('$kApiBaseUrl/cargas-empresa/$cargaId');
      final response = await http.patch(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(dados),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Erro ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Falha ao atualizar carga empresarial: $e');
    }
  }

  /// Deletar carga da empresa
  Future<void> deletarCargaEmpresa(String cargaId) async {
    try {
      final url = Uri.parse('$kApiBaseUrl/cargas-empresa/$cargaId');
      final response = await http.delete(url);

      if (response.statusCode != 204) {
        throw Exception('Erro ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Falha ao deletar carga empresarial: $e');
    }
  }

  /// Obter carga empresarial específica
  Future<Map<String, dynamic>> getCargaEmpresa(String cargaId) async {
    try {
      final url = Uri.parse('$kApiBaseUrl/cargas-empresa/$cargaId');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Erro ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Falha ao carregar carga empresarial: $e');
    }
  }
}
