class Carga {
  final String id;
  final String? empresaId;
  final String? empresaNome;
  final String? origem;
  final String? destino;
  final double? peso;
  final DateTime data;
  final String status;
  final String? titulo;
  final String? tipoCarga;
  bool avaliada;

  Carga({
    required this.id,
    this.empresaId,
    this.empresaNome,
    this.origem,
    this.destino,
    this.peso,
    required this.data,
    required this.status,
    this.titulo,
    this.tipoCarga,
    this.avaliada = false,
  });

  factory Carga.fromJson(Map<String, dynamic> json) {
    return Carga(
      id: json['id'] ?? '',
      empresaId: json['empresaId'],
      empresaNome: json['empresaNome'],
      origem: json['origem'],
      destino: json['destino'],
      peso: json['peso']?.toDouble(),
      data: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      status: json['status'] ?? 'pendente',
      titulo: json['titulo'],
      tipoCarga: json['tipoCarga'],
      avaliada: json['avaliada'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'empresaId': empresaId,
      'empresaNome': empresaNome,
      'origem': origem,
      'destino': destino,
      'peso': peso,
      'created_at': data.toIso8601String(),
      'status': status,
      'titulo': titulo,
      'tipoCarga': tipoCarga,
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

  bool get isFutura => data.isAfter(DateTime.now());
  bool get isConcluida => status == 'concluida';
  bool get isCancelada => status.contains('cancelada');
}
