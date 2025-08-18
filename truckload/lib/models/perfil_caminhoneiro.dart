class PerfilCaminhoneiro {
  final String id;
  final String nome;
  final String email;
  final String telefone;
  final String? descricao;
  final String? fotoUrl;
  final String? cpf;
  final String? tipoCaminhao;
  final DateTime? dataCadastro;
  final double avaliacaoMedia;
  final int avaliacaoQtd;
  final double taxaCancelamento;

  PerfilCaminhoneiro({
    required this.id,
    required this.nome,
    required this.email,
    required this.telefone,
    this.descricao,
    this.fotoUrl,
    this.cpf,
    this.tipoCaminhao,
    this.dataCadastro,
    this.avaliacaoMedia = 0.0,
    this.avaliacaoQtd = 0,
    this.taxaCancelamento = 0.0,
  });

  factory PerfilCaminhoneiro.fromJson(Map<String, dynamic> json) {
    return PerfilCaminhoneiro(
      id: json['id'] ?? '',
      nome: json['nome'] ?? '',
      email: json['email'] ?? '',
      telefone: json['telefone'] ?? '',
      descricao: json['descricao'],
      fotoUrl: json['fotoUrl'],
      cpf: json['cpf'],
      tipoCaminhao: json['tipoCaminhao'],
      dataCadastro: json['data_cadastro'] != null
          ? DateTime.parse(json['data_cadastro'])
          : null,
      avaliacaoMedia: (json['avaliacao_media'] ?? 0.0).toDouble(),
      avaliacaoQtd: json['avaliacao_qtd'] ?? 0,
      taxaCancelamento: (json['taxa_cancelamento'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
      'telefone': telefone,
      'descricao': descricao,
      'fotoUrl': fotoUrl,
      'cpf': cpf,
      'tipoCaminhao': tipoCaminhao,
      'data_cadastro': dataCadastro?.toIso8601String(),
      'avaliacao_media': avaliacaoMedia,
      'avaliacao_qtd': avaliacaoQtd,
      'taxa_cancelamento': taxaCancelamento,
    };
  }

  String get avaliacaoDisplay => avaliacaoMedia.toStringAsFixed(1);
  String get taxaCancelamentoDisplay =>
      (taxaCancelamento * 100).toStringAsFixed(1);
  String get nomeDisplay => nome.isEmpty ? 'Sem nome' : nome;
  String get descricaoDisplay => descricao?.isEmpty == true
      ? 'Sem descrição'
      : (descricao ?? 'Sem descrição');
  String get telefoneDisplay => telefone.isEmpty ? '—' : telefone;
  String get emailDisplay => email.isEmpty ? '—' : email;
}
