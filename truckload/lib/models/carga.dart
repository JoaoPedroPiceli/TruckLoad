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
    // Parse da data de forma mais robusta
    DateTime data;
    try {
      if (json['created_at'] != null) {
        if (json['created_at'] is String) {
          data = DateTime.parse(json['created_at']);
        } else if (json['created_at'] is int) {
          data = DateTime.fromMillisecondsSinceEpoch(json['created_at']);
        } else {
          data = DateTime.now();
        }
      } else {
        data = DateTime.now();
      }
    } catch (e) {
      data = DateTime.now();
    }

    return Carga(
      id: json['id']?.toString() ?? '',
      empresaId: json['empresaId']?.toString(),
      empresaNome: json['empresaNome']?.toString(),
      origem: json['origem']?.toString(),
      destino: json['destino']?.toString(),
      peso: json['peso']?.toDouble(),
      data: data,
      status: json['status']?.toString() ?? 'pendente',
      titulo: json['titulo']?.toString(),
      tipoCarga: json['tipoCarga']?.toString(),
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
