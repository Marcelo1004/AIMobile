import 'dart:convert';
import 'package:flutter/material.dart';

class Prediction {
  final int id;
  final int estudiante;
  final int materia;
  final double valorNumerico;
  final String nivelRendimiento;  // "BAJO", "MEDIO", "ALTO"
  final DateTime fechaPrediccion;
  final double promedioNotas;
  final double porcentajeAsistencia;
  final double promedioParticipaciones;
  final int confianza;  // De 0 a 100

  Prediction({
    required this.id,
    required this.estudiante,
    required this.materia,
    required this.valorNumerico,
    required this.nivelRendimiento,
    required this.fechaPrediccion,
    required this.promedioNotas,
    required this.porcentajeAsistencia,
    required this.promedioParticipaciones,
    required this.confianza,
  });

  factory Prediction.fromJson(Map<String, dynamic> json) {
    return Prediction(
      id: json['id'],
      estudiante: json['estudiante'],
      materia: json['materia'],
      valorNumerico: _parseToDouble(json['valor_numerico']),
      nivelRendimiento: json['nivel_rendimiento'],
      fechaPrediccion: DateTime.parse(json['fecha_prediccion']),
      promedioNotas: _parseToDouble(json['promedio_notas']),
      porcentajeAsistencia: _parseToDouble(json['porcentaje_asistencia']),
      promedioParticipaciones: _parseToDouble(json['promedio_participaciones']),
      confianza: json['confianza'],
    );
  }

  // Método auxiliar para convertir valores que pueden ser double o String a double
  static double _parseToDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.parse(value);
    return 0.0; // Valor por defecto si es null o de un tipo no esperado
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'estudiante': estudiante,
      'materia': materia,
      'valor_numerico': valorNumerico,
      'nivel_rendimiento': nivelRendimiento,
      'fecha_prediccion': fechaPrediccion.toIso8601String(),
      'promedio_notas': promedioNotas,
      'porcentaje_asistencia': porcentajeAsistencia,
      'promedio_participaciones': promedioParticipaciones,
      'confianza': confianza,
    };
  }

  // Métodos de utilidad

  // Devuelve el color según el nivel de rendimiento
  Color getRendimientoColor() {
    switch (nivelRendimiento) {
      case 'BAJO':
        return Colors.red;
      case 'MEDIO':
        return Colors.amber;
      case 'ALTO':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  // Devuelve el icono según el nivel de rendimiento
  IconData getRendimientoIcon() {
    switch (nivelRendimiento) {
      case 'BAJO':
        return Icons.arrow_downward;
      case 'MEDIO':
        return Icons.arrow_forward;
      case 'ALTO':
        return Icons.arrow_upward;
      default:
        return Icons.help_outline;
    }
  }
}

class StudentAtRisk {
  final int estudianteId;
  final String nombre;
  final String username;
  final String curso;
  final List<MateriaRiesgo> materiasRiesgo;
  final int totalMateriasRiesgo;

  StudentAtRisk({
    required this.estudianteId,
    required this.nombre,
    required this.username,
    required this.curso,
    required this.materiasRiesgo,
    required this.totalMateriasRiesgo,
  });

  factory StudentAtRisk.fromJson(Map<String, dynamic> json) {
    final List<dynamic> materias = json['materias_riesgo'] ?? [];

    return StudentAtRisk(
      estudianteId: json['estudiante_id'],
      nombre: json['nombre'] ?? '',
      username: json['username'] ?? '',
      curso: json['curso'] ?? '',
      materiasRiesgo: materias.map((m) => MateriaRiesgo.fromJson(m)).toList(),
      totalMateriasRiesgo: json['total_materias_riesgo'] ?? 0,
    );
  }
}

class MateriaRiesgo {
  final int materiaId;
  final String materiaNombre;
  final double valorPredicho;
  final String nivelRendimiento;
  final DateTime fechaPrediccion;

  MateriaRiesgo({
    required this.materiaId,
    required this.materiaNombre,
    required this.valorPredicho,
    required this.nivelRendimiento,
    required this.fechaPrediccion,
  });

  factory MateriaRiesgo.fromJson(Map<String, dynamic> json) {
    return MateriaRiesgo(
      materiaId: json['materia_id'],
      materiaNombre: json['materia_nombre'] ?? '',
      valorPredicho: _parseToDouble(json['valor_predicho']),
      nivelRendimiento: json['nivel_rendimiento'] ?? '',
      fechaPrediccion: DateTime.parse(json['fecha_prediccion']),
    );
  }

  // Método auxiliar para convertir valores que pueden ser double o String a double
  static double _parseToDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.parse(value);
    return 0.0; // Valor por defecto si es null o de un tipo no esperado
  }

  // Devuelve el color según el nivel de rendimiento
  Color getRendimientoColor() {
    switch (nivelRendimiento) {
      case 'BAJO':
        return Colors.red;
      case 'MEDIO':
        return Colors.amber;
      case 'ALTO':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}

class PredictionRecommendation {
  final String titulo;
  final String descripcion;
  final String tipo; // "ACADEMICA", "ASISTENCIA", "PARTICIPACION", "GENERAL"
  final int prioridad; // 1 (alta) a 5 (baja)

  PredictionRecommendation({
    required this.titulo,
    required this.descripcion,
    required this.tipo,
    required this.prioridad,
  });

  factory PredictionRecommendation.fromJson(Map<String, dynamic> json) {
    return PredictionRecommendation(
      titulo: json['titulo'],
      descripcion: json['descripcion'],
      tipo: json['tipo'],
      prioridad: json['prioridad'],
    );
  }

  // Devuelve el color según el tipo de recomendación
  Color getTipoColor() {
    switch (tipo) {
      case 'ACADEMICA':
        return Colors.blue;
      case 'ASISTENCIA':
        return Colors.green;
      case 'PARTICIPACION':
        return Colors.orange;
      case 'GENERAL':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  // Devuelve el icono según el tipo de recomendación
  IconData getTipoIcon() {
    switch (tipo) {
      case 'ACADEMICA':
        return Icons.school;
      case 'ASISTENCIA':
        return Icons.calendar_today;
      case 'PARTICIPACION':
        return Icons.record_voice_over;
      case 'GENERAL':
        return Icons.info;
      default:
        return Icons.help_outline;
    }
  }
}

