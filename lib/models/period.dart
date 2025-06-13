/// Modelo que representa un período académico
class Period {
  final int id;
  final String nombre;
  final String trimestre;
  final String yearAcademico;
  final DateTime fechaInicio;
  final DateTime fechaFin;

  Period({
    required this.id,
    required this.nombre,
    required this.trimestre,
    required this.yearAcademico,
    required this.fechaInicio,
    required this.fechaFin,
  });

  /// Crea una instancia de Period a partir de un mapa JSON
  factory Period.fromJson(Map<String, dynamic> json) {
    return Period(
      id: json['id'],
      nombre: json['nombre'],
      trimestre: json['trimestre'],
      yearAcademico: json['año_academico'],
      fechaInicio: DateTime.parse(json['fecha_inicio']),
      fechaFin: DateTime.parse(json['fecha_fin']),
    );
  }

  /// Convierte la instancia de Period a un mapa JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'trimestre': trimestre,
      'año_academico': yearAcademico,
      'fecha_inicio': fechaInicio.toIso8601String(),
      'fecha_fin': fechaFin.toIso8601String(),
    };
  }

  /// Representación textual del periodo
  @override
  String toString() => '$nombre ($trimestre) - $yearAcademico';
}

