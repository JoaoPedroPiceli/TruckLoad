class PerfilEmpresa {
  final String id;
  final String nome;
  final String email;
  final String telefone;
  final String? descricao;
  final String? fotoUrl;
  final String? cnpj;
  final String? endereco;
  final DateTime? dataCadastro;
  final double avaliacaoMedia;
  final int avaliacaoQtd;
  final int totalCargas;
  final int cargasConcluidas;

  PerfilEmpresa({
    required this.id,
    required this.nome,
    required this.email,
    required this.telefone,
    this.descricao,
    this.fotoUrl,
    this.cnpj,
    this.endereco,
    this.dataCadastro,
    this.avaliacaoMedia = 0.0,
    this.avaliacaoQtd = 0,
    this.totalCargas = 0,
    this.cargasConcluidas = 0,
  });

  factory PerfilEmpresa.fromJson(Map<String, dynamic> json) {
    return PerfilEmpresa(
      id: json['id'] ?? '',
      nome: json['nome'] ?? '',
      email: json['email'] ?? '',
      telefone: json['telefone'] ?? '',
      descricao: json['descricao'],
      fotoUrl: json['fotoUrl'],
      cnpj: json['cnpj'],
      endereco: json['endereco'],
      dataCadastro: json['data_cadastro'] != null
          ? DateTime.parse(json['data_cadastro'])
          : null,
      avaliacaoMedia: (json['avaliacao_media'] ?? 0.0).toDouble(),
      avaliacaoQtd: json['avaliacao_qtd'] ?? 0,
      totalCargas: json['total_cargas'] ?? 0,
      cargasConcluidas: json['cargas_concluidas'] ?? 0,
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
      'cnpj': cnpj,
      'endereco': endereco,
      'data_cadastro': dataCadastro?.toIso8601String(),
      'avaliacao_media': avaliacaoMedia,
      'avaliacao_qtd': avaliacaoQtd,
      'total_cargas': totalCargas,
      'cargas_concluidas': cargasConcluidas,
    };
  }

  String get avaliacaoDisplay => avaliacaoMedia.toStringAsFixed(1);
  String get nomeDisplay => nome.isEmpty ? 'Sem nome' : nome;
  String get descricaoDisplay => descricao?.isEmpty == true
      ? 'Sem descrição'
      : (descricao ?? 'Sem descrição');
  String get telefoneDisplay => telefone.isEmpty ? '—' : telefone;
  String get emailDisplay => email.isEmpty ? '—' : email;
  String get cnpjDisplay => cnpj?.isEmpty == true ? '—' : (cnpj ?? '—');
  String get enderecoDisplay =>
      endereco?.isEmpty == true ? '—' : (endereco ?? '—');
  double get taxaConclusao =>
      totalCargas > 0 ? (cargasConcluidas / totalCargas) : 0.0;
  String get taxaConclusaoDisplay => (taxaConclusao * 100).toStringAsFixed(1);
}
