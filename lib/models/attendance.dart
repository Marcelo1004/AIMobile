import 'dart:convert';

class Attendance {
  final int id;
  final int estudiante;
  final int materia;
  final DateTime fecha;
  final bool presente;
  final String? justificacion;

  Attendance({
    required this.id,
    required this.estudiante,
    required this.materia,
    required this.fecha,
    required this.presente,
    this.justificacion,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      id: json['id'],
      estudiante: json['estudiante'],
      materia: json['materia'],
      fecha: DateTime.parse(json['fecha']),
      presente: json['presente'],
      justificacion: json['justificacion'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'estudiante': estudiante,
      'materia': materia,
      'fecha': fecha.toIso8601String().split('T')[0], // Formato YYYY-MM-DD
      'presente': presente,
      'justificacion': justificacion,
    };
  }
}

class AttendanceStatistics {
  final int totalClases;
  final int asistencias;
  final int faltas;
  final double porcentajeAsistencia;

  AttendanceStatistics({
    required this.totalClases,
    required this.asistencias,
    required this.faltas,
    required this.porcentajeAsistencia,
  });

  factory AttendanceStatistics.fromJson(Map<String, dynamic> json) {
    return AttendanceStatistics(
      totalClases: json['total_clases'],
      asistencias: json['asistencias'],
      faltas: json['faltas'],
      porcentajeAsistencia: json['porcentaje_asistencia'].toDouble(),
    );
  }
}
