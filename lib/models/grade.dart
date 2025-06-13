/// Modelo que representa una calificación o nota en el sistema
///
/// Este modelo implementa la estructura de evaluación ser-saber-hacer-decidir
/// utilizada en el sistema educativo.
class Grade {
  final int? id;
  final int estudiante;
  final int materia;
  final int periodo;
  final double serPuntaje;
  final double saberPuntaje;
  final double hacerPuntaje;
  final double decidirPuntaje;
  final double? autoevaluacionSer;
  final double? autoevaluacionDecidir;
  final DateTime fechaRegistro;
  final DateTime ultimaModificacion;
  final String? comentario;

  Grade({
    this.id,
    required this.estudiante,
    required this.materia,
    required this.periodo,
    required this.serPuntaje,
    required this.saberPuntaje,
    required this.hacerPuntaje,
    required this.decidirPuntaje,
    this.autoevaluacionSer,
    this.autoevaluacionDecidir,
    required this.fechaRegistro,
    required this.ultimaModificacion,
    this.comentario,
  });

  /// Crea una instancia de Grade a partir de un mapa JSON
  factory Grade.fromJson(Map<String, dynamic> json) {
    return Grade(
      id: json['id'],
      estudiante: json['estudiante'],
      materia: json['materia'],
      periodo: json['periodo'],
      serPuntaje: _parseDouble(json['ser_puntaje']),
      saberPuntaje: _parseDouble(json['saber_puntaje']),
      hacerPuntaje: _parseDouble(json['hacer_puntaje']),
      decidirPuntaje: _parseDouble(json['decidir_puntaje']),
      autoevaluacionSer: json['autoevaluacion_ser'] != null ?
        _parseDouble(json['autoevaluacion_ser']) : null,
      autoevaluacionDecidir: json['autoevaluacion_decidir'] != null ?
        _parseDouble(json['autoevaluacion_decidir']) : null,
      fechaRegistro: DateTime.parse(json['fecha_registro']),
      ultimaModificacion: DateTime.parse(json['ultima_modificacion']),
      comentario: json['comentario'],
    );
  }

  /// Convierte una instancia de Grade a un mapa JSON
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'estudiante': estudiante,
      'materia': materia,
      'periodo': periodo,
      'ser_puntaje': serPuntaje,
      'saber_puntaje': saberPuntaje,
      'hacer_puntaje': hacerPuntaje,
      'decidir_puntaje': decidirPuntaje,
      if (autoevaluacionSer != null) 'autoevaluacion_ser': autoevaluacionSer,
      if (autoevaluacionDecidir != null) 'autoevaluacion_decidir': autoevaluacionDecidir,
      'fecha_registro': fechaRegistro.toIso8601String(),
      'ultima_modificacion': ultimaModificacion.toIso8601String(),
      if (comentario != null) 'comentario': comentario,
    };
  }

  /// Calcula el puntaje total de la calificación
  double get puntajeTotal => serPuntaje + saberPuntaje + hacerPuntaje + decidirPuntaje;

  /// Calcula la autoevaluación total
  double? get autoevaluacionTotal =>
      (autoevaluacionSer != null && autoevaluacionDecidir != null) ?
      autoevaluacionSer! + autoevaluacionDecidir! : null;

  /// Calcula el puntaje total final incluyendo la autoevaluación si está disponible
  double get puntajeFinal => puntajeTotal + (autoevaluacionTotal ?? 0.0);

  /// Construye una copia de la calificación con los campos modificados
  Grade copyWith({
    int? id,
    int? estudiante,
    int? materia,
    int? periodo,
    double? serPuntaje,
    double? saberPuntaje,
    double? hacerPuntaje,
    double? decidirPuntaje,
    double? autoevaluacionSer,
    double? autoevaluacionDecidir,
    DateTime? fechaRegistro,
    DateTime? ultimaModificacion,
    String? comentario,
  }) {
    return Grade(
      id: id ?? this.id,
      estudiante: estudiante ?? this.estudiante,
      materia: materia ?? this.materia,
      periodo: periodo ?? this.periodo,
      serPuntaje: serPuntaje ?? this.serPuntaje,
      saberPuntaje: saberPuntaje ?? this.saberPuntaje,
      hacerPuntaje: hacerPuntaje ?? this.hacerPuntaje,
      decidirPuntaje: decidirPuntaje ?? this.decidirPuntaje,
      autoevaluacionSer: autoevaluacionSer ?? this.autoevaluacionSer,
      autoevaluacionDecidir: autoevaluacionDecidir ?? this.autoevaluacionDecidir,
      fechaRegistro: fechaRegistro ?? this.fechaRegistro,
      ultimaModificacion: ultimaModificacion ?? this.ultimaModificacion,
      comentario: comentario ?? this.comentario,
    );
  }


  static double _parseDouble(dynamic value) {
    if (value is int) {
      return value.toDouble();
    } else if (value is double) {
      return value;
    } else if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }
}

