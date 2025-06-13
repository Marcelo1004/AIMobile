/// Modelo que representa los componentes de una nota
class GradeComponents {
  final double ser;
  final double saber;
  final double hacer;
  final double decidir;
  final double autoEvaluation;

  GradeComponents({
    required this.ser,
    required this.saber,
    required this.hacer,
    required this.decidir,
    required this.autoEvaluation,
  });

  factory GradeComponents.fromJson(Map<String, dynamic> json) {
    // Función para manejar conversiones seguras de double
    double parseDoubleSafely(dynamic value) {
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) {
        try {
          return double.parse(value);
        } catch (e) {
          print("Error parsing double in GradeComponents: $value, using default 0.0");
          return 0.0;
        }
      }
      return 0.0;
    }

    return GradeComponents(
      ser: parseDoubleSafely(json['ser']),
      saber: parseDoubleSafely(json['saber']),
      hacer: parseDoubleSafely(json['hacer']),
      decidir: parseDoubleSafely(json['decidir']),
      autoEvaluation: parseDoubleSafely(json['autoevaluacion']),
    );
  }
}

/// Modelo que representa un trimestre con su nota
class TermGrade {
  final int term;
  final int year;
  final double totalGrade;
  final GradeComponents components;

  TermGrade({
    required this.term,
    required this.year,
    required this.totalGrade,
    required this.components,
  });

  factory TermGrade.fromJson(String key, Map<String, dynamic> json) {
    // Función para manejar conversiones seguras de enteros
    int parseIntSafely(dynamic value) {
      if (value is int) return value;
      if (value is String) {
        try {
          return int.parse(value);
        } catch (e) {
          print("Error parsing int in TermGrade: $value, using default 0");
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
          print("Error parsing double in TermGrade: $value, using default 0.0");
          return 0.0;
        }
      }
      return 0.0;
    }

    final parts = key.split('_');
    return TermGrade(
      term: parseIntSafely(json['trimestre']),
      year: parseIntSafely(json['año']),
      totalGrade: parseDoubleSafely(json['nota_total']),
      components: GradeComponents.fromJson(json['componentes']),
    );
  }
}

/// Modelo que representa las notas de un curso
class CourseGrade {
  final int id;
  final String name;
  final Map<String, TermGrade> terms;

  CourseGrade({
    required this.id,
    required this.name,
    required this.terms,
  });

  factory CourseGrade.fromJson(Map<String, dynamic> json) {
    // Función para manejar conversiones seguras de enteros
    int parseIntSafely(dynamic value) {
      if (value is int) return value;
      if (value is String) {
        try {
          return int.parse(value);
        } catch (e) {
          print("Error parsing int in CourseGrade: $value, using default 0");
          return 0;
        }
      }
      return 0;
    }

    final Map<String, TermGrade> terms = {};

    if (json['trimestres'] != null) {
      json['trimestres'].forEach((key, value) {
        terms[key] = TermGrade.fromJson(key, value);
      });
    }

    return CourseGrade(
      id: parseIntSafely(json['id']),
      name: json['nombre'] ?? '',
      terms: terms,
    );
  }
}

/// Modelo que representa la asistencia a un curso
class CourseAttendance {
  final int courseId;
  final String courseName;
  final double percentage;
  final int present;
  final int total;

  CourseAttendance({
    required this.courseId,
    required this.courseName,
    required this.percentage,
    required this.present,
    required this.total,
  });

  factory CourseAttendance.fromJson(Map<String, dynamic> json) {
    // Función para manejar conversiones seguras de enteros
    int parseIntSafely(dynamic value) {
      if (value is int) return value;
      if (value is String) {
        try {
          return int.parse(value);
        } catch (e) {
          print("Error parsing int in CourseAttendance: $value, using default 0");
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
          print("Error parsing double in CourseAttendance: $value, using default 0.0");
          return 0.0;
        }
      }
      return 0.0;
    }

    return CourseAttendance(
      courseId: parseIntSafely(json['materia_id']),
      courseName: json['materia_nombre'] ?? '',
      percentage: parseDoubleSafely(json['porcentaje']),
      present: parseIntSafely(json['presentes']),
      total: parseIntSafely(json['total']),
    );
  }
}

/// Modelo que representa la participación en un curso
class CourseParticipation {
  final int courseId;
  final String courseName;
  final int total;
  final double averageValue;

  CourseParticipation({
    required this.courseId,
    required this.courseName,
    required this.total,
    required this.averageValue,
  });

  factory CourseParticipation.fromJson(Map<String, dynamic> json) {
    // Función para manejar conversiones seguras de enteros
    int parseIntSafely(dynamic value) {
      if (value is int) return value;
      if (value is String) {
        try {
          return int.parse(value);
        } catch (e) {
          print("Error parsing int in CourseParticipation: $value, using default 0");
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
          print("Error parsing double in CourseParticipation: $value, using default 0.0");
          return 0.0;
        }
      }
      return 0.0;
    }

    return CourseParticipation(
      courseId: parseIntSafely(json['materia_id']),
      courseName: json['materia_nombre'] ?? '',
      total: parseIntSafely(json['total']),
      averageValue: parseDoubleSafely(json['promedio_valor']),
    );
  }
}

/// Modelo que representa las variables de una predicción
class PredictionVariables {
  final double gradeAverage;
  final double attendancePercentage;
  final double participationAverage;

  PredictionVariables({
    required this.gradeAverage,
    required this.attendancePercentage,
    required this.participationAverage,
  });

  factory PredictionVariables.fromJson(Map<String, dynamic> json) {
    // Función para manejar conversiones seguras de double
    double parseDoubleSafely(dynamic value) {
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) {
        try {
          return double.parse(value);
        } catch (e) {
          print("Error parsing double in PredictionVariables: $value, using default 0.0");
          return 0.0;
        }
      }
      return 0.0;
    }

    return PredictionVariables(
      gradeAverage: parseDoubleSafely(json['promedio_notas']),
      attendancePercentage: parseDoubleSafely(json['porcentaje_asistencia']),
      participationAverage: parseDoubleSafely(json['promedio_participaciones']),
    );
  }
}

/// Modelo que representa una predicción para un estudiante
class StudentPrediction {
  final int id;
  final int courseId;
  final String courseName;
  final String predictionDate;
  final double numericValue;
  final String performanceLevel;
  final double passProb;
  final PredictionVariables variables;

  StudentPrediction({
    required this.id,
    required this.courseId,
    required this.courseName,
    required this.predictionDate,
    required this.numericValue,
    required this.performanceLevel,
    required this.passProb,
    required this.variables,
  });

  factory StudentPrediction.fromJson(Map<String, dynamic> json) {
    // Función para manejar conversiones seguras de enteros
    int parseIntSafely(dynamic value) {
      if (value is int) return value;
      if (value is String) {
        try {
          return int.parse(value);
        } catch (e) {
          print("Error parsing int in StudentPrediction: $value, using default 0");
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
          print("Error parsing double in StudentPrediction: $value, using default 0.0");
          return 0.0;
        }
      }
      return 0.0;
    }

    return StudentPrediction(
      id: parseIntSafely(json['id']),
      courseId: parseIntSafely(json['materia_id']),
      courseName: json['materia_nombre'] ?? '',
      predictionDate: json['fecha_prediccion'] ?? '',
      numericValue: parseDoubleSafely(json['valor_numerico']),
      performanceLevel: json['nivel_rendimiento'] ?? '',
      passProb: parseDoubleSafely(json['probabilidad_aprobar']),
      variables: PredictionVariables.fromJson(json['variables']),
    );
  }
}

/// Modelo que representa el dashboard de un estudiante
class StudentDashboard {
  final Map<String, dynamic> student;
  final List<CourseGrade> grades;
  final List<CourseAttendance> attendances;
  final List<CourseParticipation> participations;
  final List<StudentPrediction> predictions;

  StudentDashboard({
    required this.student,
    required this.grades,
    required this.attendances,
    required this.participations,
    required this.predictions,
  });

  factory StudentDashboard.fromJson(Map<String, dynamic> json) {
    return StudentDashboard(
      student: json['estudiante'] ?? {},
      grades: (json['notas'] as List? ?? [])
          .map((item) => CourseGrade.fromJson(item))
          .toList(),
      attendances: (json['asistencias'] as List? ?? [])
          .map((item) => CourseAttendance.fromJson(item))
          .toList(),
      participations: (json['participaciones'] as List? ?? [])
          .map((item) => CourseParticipation.fromJson(item))
          .toList(),
      predictions: (json['predicciones'] as List? ?? [])
          .map((item) => StudentPrediction.fromJson(item))
          .toList(),
    );
  }
}
