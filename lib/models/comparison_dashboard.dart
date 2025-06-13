/// Modelo que representa la comparación de rendimiento de un estudiante
class PerformanceComparison {
  final int studentId;
  final String studentName;
  final int courseId;
  final String courseName;
  final double predictedGrade;
  final double actualGrade;
  final double difference;
  final String predictedLevel;

  PerformanceComparison({
    required this.studentId,
    required this.studentName,
    required this.courseId,
    required this.courseName,
    required this.predictedGrade,
    required this.actualGrade,
    required this.difference,
    required this.predictedLevel,
  });

  factory PerformanceComparison.fromJson(Map<String, dynamic> json) {
    return PerformanceComparison(
      studentId: json['estudiante_id'],
      studentName: json['estudiante_nombre'],
      courseId: json['materia_id'],
      courseName: json['materia_nombre'],
      predictedGrade: json['nota_predicha'].toDouble(),
      actualGrade: json['nota_real'].toDouble(),
      difference: json['diferencia'].toDouble(),
      predictedLevel: json['nivel_predicho'],
    );
  }
}

/// Modelo que representa el comparativo general de rendimiento
class PerformanceDashboard {
  final List<PerformanceComparison> comparisons;
  final double modelAccuracy;
  final int totalPredictions;

  PerformanceDashboard({
    required this.comparisons,
    required this.modelAccuracy,
    required this.totalPredictions,
  });

  factory PerformanceDashboard.fromJson(Map<String, dynamic> json) {
    return PerformanceDashboard(
      comparisons: (json['comparaciones'] as List)
          .map((item) => PerformanceComparison.fromJson(item))
          .toList(),
      modelAccuracy: json['precision_modelo'].toDouble(),
      totalPredictions: json['total_predicciones'],
    );
  }
}
