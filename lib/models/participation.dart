import 'dart:convert';

class Participation {
  final int id;
  final int estudiante;
  final int materia;
  final DateTime fecha;
  final String tipo;      // VOLUNTARIA, SOLICITADA, etc.
  final String descripcion;
  final int valor;        // Valor de la participación (1-10)

  Participation({
    required this.id,
    required this.estudiante,
    required this.materia,
    required this.fecha,
    required this.tipo,
    required this.descripcion,
    required this.valor,
  });

  factory Participation.fromJson(Map<String, dynamic> json) {
    return Participation(
      id: json['id'],
      estudiante: json['estudiante'],
      materia: json['materia'],
      fecha: DateTime.parse(json['fecha']),
      tipo: json['tipo'],
      descripcion: json['descripcion'],
      valor: json['valor'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'estudiante': estudiante,
      'materia': materia,
      'fecha': fecha.toIso8601String().split('T')[0], // Formato YYYY-MM-DD
      'tipo': tipo,
      'descripcion': descripcion,
      'valor': valor,
    };
  }
}

class ParticipationStatistics {
  final int totalParticipaciones;
  final double promedioValor;
  final Map<String, int> participacionesPorTipo;

  ParticipationStatistics({
    required this.totalParticipaciones,
    required this.promedioValor,
    required this.participacionesPorTipo,
  });

  factory ParticipationStatistics.fromJson(Map<String, dynamic> json) {
    Map<String, int> tipoMap = {};
    if (json['participaciones_por_tipo'] != null) {
      json['participaciones_por_tipo'].forEach((key, value) {
        tipoMap[key] = value;
      });
    }

    return ParticipationStatistics(
      totalParticipaciones: json['total_participaciones'],
      promedioValor: json['promedio_valor'].toDouble(),
      participacionesPorTipo: tipoMap,
    );
  }
}
