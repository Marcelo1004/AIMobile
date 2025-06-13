import 'package:aula_inteligente/models/user.dart';

/// Modelo que representa la distribución de predicciones
class PredictionDistribution {
  final String levelName;
  final int count;

  PredictionDistribution({
    required this.levelName,
    required this.count,
  });

  factory PredictionDistribution.fromJson(Map<String, dynamic> json) {
    // Función para manejar conversiones seguras de enteros
    int parseIntSafely(dynamic value) {
      if (value is int) return value;
      if (value is String) {
        try {
          return int.parse(value);
        } catch (e) {
          print("Error parsing int: $value, using default 0");
          return 0;
        }
      }
      return 0;
    }

    return PredictionDistribution(
      levelName: json['nivel_rendimiento'] ?? '',
      count: parseIntSafely(json['cantidad']),
    );
  }
}

/// Modelo que representa estadísticas de una materia
class CourseStats {
  final int id;
  final String name;
  final int totalStudents;
  final double averageGrade;

  CourseStats({
    required this.id,
    required this.name,
    required this.totalStudents,
    required this.averageGrade,
  });

  factory CourseStats.fromJson(Map<String, dynamic> json) {
    // Para manejar posibles valores no numéricos
    int parseIntSafely(dynamic value) {
      if (value is int) return value;
      if (value is String) {
        try {
          return int.parse(value);
        } catch (e) {
          print("Error parsing int: $value, using default 0");
          return 0;
        }
      }
      return 0;
    }

    double parseDoubleSafely(dynamic value) {
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) {
        try {
          return double.parse(value);
        } catch (e) {
          print("Error parsing double: $value, using default 0.0");
          return 0.0;
        }
      }
      return 0.0;
    }

    return CourseStats(
      id: parseIntSafely(json['id']),
      name: json['nombre'] ?? '',
      totalStudents: parseIntSafely(json['total_estudiantes']),
      averageGrade: parseDoubleSafely(json['promedio_notas']),
    );
  }
}

/// Modelo que representa estadísticas por trimestre
class TermStats {
  final int term;
  final double average;
  final int students;

  TermStats({
    required this.term,
    required this.average,
    required this.students,
  });

  factory TermStats.fromJson(Map<String, dynamic> json) {
    // Función para manejar conversiones seguras de enteros
    int parseIntSafely(dynamic value) {
      if (value is int) return value;
      if (value is String) {
        try {
          return int.parse(value);
        } catch (e) {
          print("Error parsing int in TermStats: $value, using default 0");
          return 0;
        }
      }
      return 0;
    }

    // Función para manejar conversiones seguras de double
    double parseDoubleSafely(dynamic value) {
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) {
        try {
          return double.parse(value);
        } catch (e) {
          print("Error parsing double in TermStats: $value, using default 0.0");
          return 0.0;
        }
      }
      return 0.0;
    }

    return TermStats(
      term: parseIntSafely(json['trimestre']),
      average: parseDoubleSafely(json['promedio']),
      students: parseIntSafely(json['estudiantes']),
    );
  }
}

/// Modelo que representa el dashboard general
class GeneralDashboard {
  final int totalStudents;
  final int totalCourses;
  final double generalAverage;
  final double attendanceAverage;
  final List<PredictionDistribution> predictionsDistribution;
  final List<CourseStats> coursesStats;
  final List<TermStats> termsStats;

  GeneralDashboard({
    required this.totalStudents,
    required this.totalCourses,
    required this.generalAverage,
    required this.attendanceAverage,
    required this.predictionsDistribution,
    required this.coursesStats,
    required this.termsStats,
  });

  factory GeneralDashboard.fromJson(Map<String, dynamic> json) {
    // Función para manejar conversiones seguras de enteros
    int parseIntSafely(dynamic value) {
      if (value is int) return value;
      if (value is String) {
        try {
          return int.parse(value);
        } catch (e) {
          print("Error parsing int in GeneralDashboard: $value, using default 0");
          return 0;
        }
      }
      return 0;
    }

    // Función para manejar conversiones seguras de double
    double parseDoubleSafely(dynamic value) {
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) {
        try {
          return double.parse(value);
        } catch (e) {
          print("Error parsing double in GeneralDashboard: $value, using default 0.0");
          return 0.0;
        }
      }
      return 0.0;
    }

    return GeneralDashboard(
      totalStudents: parseIntSafely(json['total_estudiantes']),
      totalCourses: parseIntSafely(json['total_materias']),
      generalAverage: parseDoubleSafely(json['promedio_general']),
      attendanceAverage: parseDoubleSafely(json['asistencia_promedio']),
      predictionsDistribution: (json['predicciones_distribucion'] as List? ?? [])
          .map((item) => PredictionDistribution.fromJson(item))
          .toList(),
      coursesStats: (json['materias_stats'] as List? ?? [])
          .map((item) => CourseStats.fromJson(item))
          .toList(),
      termsStats: (json['trimestres_stats'] as List? ?? [])
          .map((item) => TermStats.fromJson(item))
          .toList(),
    );
  }
}
