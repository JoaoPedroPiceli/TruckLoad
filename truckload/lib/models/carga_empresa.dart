class CargaEmpresa {
  final String id;
<<<<<<< HEAD
  final String? empresaId;
  final String? empresaNome;
=======
>>>>>>> b6a42f1baca63803288e53c189d87d2950f01a15
  final String? caminhoneiroId;
  final String? caminhoneiroNome;
  final String? origem;
  final String? destino;
  final double? peso;
  final double? preco;
  final DateTime data;
  final String status;
  final String? titulo;
  final String? descricao;
  final String? tipoCarga;
  final String? regras;
  final bool avaliada;

  CargaEmpresa({
    required this.id,
<<<<<<< HEAD
    this.empresaId,
    this.empresaNome,
=======
>>>>>>> b6a42f1baca63803288e53c189d87d2950f01a15
    this.caminhoneiroId,
    this.caminhoneiroNome,
    this.origem,
    this.destino,
    this.peso,
    this.preco,
    required this.data,
    required this.status,
    this.titulo,
    this.descricao,
    this.tipoCarga,
    this.regras,
    this.avaliada = false,
  });

  factory CargaEmpresa.fromJson(Map<String, dynamic> json) {
    return CargaEmpresa(
      id: json['id'] ?? '',
<<<<<<< HEAD
      empresaId: json['empresaId']?.toString(),
      empresaNome: json['empresaNome']?.toString(),
      caminhoneiroId: json['caminhoneiroId']?.toString(),
      caminhoneiroNome: json['caminhoneiroNome']?.toString(),
      origem: json['origem']?.toString(),
      destino: json['destino']?.toString(),
=======
      caminhoneiroId: json['caminhoneiroId'],
      caminhoneiroNome: json['caminhoneiroNome'],
      origem: json['origem'],
      destino: json['destino'],
>>>>>>> b6a42f1baca63803288e53c189d87d2950f01a15
      peso: json['peso']?.toDouble(),
      preco: json['preco']?.toDouble(),
      data: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      status: json['status'] ?? 'pendente',
<<<<<<< HEAD
      titulo: json['titulo']?.toString(),
      descricao: json['descricao']?.toString(),
      tipoCarga: json['tipoCarga']?.toString(),
      regras: json['regras']?.toString(),
=======
      titulo: json['titulo'],
      descricao: json['descricao'],
      tipoCarga: json['tipoCarga'],
      regras: json['regras'],
>>>>>>> b6a42f1baca63803288e53c189d87d2950f01a15
      avaliada: json['avaliada'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
<<<<<<< HEAD
      'empresaId': empresaId,
      'empresaNome': empresaNome,
=======
>>>>>>> b6a42f1baca63803288e53c189d87d2950f01a15
      'caminhoneiroId': caminhoneiroId,
      'caminhoneiroNome': caminhoneiroNome,
      'origem': origem,
      'destino': destino,
      'peso': peso,
      'preco': preco,
      'created_at': data.toIso8601String(),
      'status': status,
      'titulo': titulo,
      'descricao': descricao,
      'tipoCarga': tipoCarga,
      'regras': regras,
      'avaliada': avaliada,
    };
  }

  String get statusDisplay {
    switch (status) {
      case 'pendente':
        return 'Pendente';
      case 'aceita':
        return 'Aceita';
      case 'concluida':
        return 'Concluída';
      case 'cancelada_pelo_motorista':
        return 'Cancelada pelo motorista';
      case 'cancelada_pela_empresa':
        return 'Cancelada pela empresa';
      default:
        return 'Desconhecido';
    }
  }

  bool get isPendente => status == 'pendente';
  bool get isAceita => status == 'aceita';
  bool get isConcluida => status == 'concluida';
  bool get isCancelada => status.contains('cancelada');
  bool get temCaminhoneiro =>
      caminhoneiroId != null && caminhoneiroId!.isNotEmpty;
  String get pesoDisplay =>
      peso != null ? '${peso!.toStringAsFixed(0)} kg' : '—';
  String get precoDisplay =>
      preco != null ? 'R\$ ${preco!.toStringAsFixed(2)}' : '—';
}
