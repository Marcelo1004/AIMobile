// filepath: c:\Users\Andres\AndroidStudioProjects\Aula_Inteligente\lib\models\subject.dart
/// Modelo que representa una materia en el sistema
///
/// Contiene información sobre una materia como su ID, nombre, código,
/// descripción, créditos y profesor asignado.
class Subject {
  final int id;
  final String nombre;
  final String codigo;
  final String descripcion;
  final int creditos;
  final int? profesorId;
  final Map<String, dynamic>? profesorDetail;

  Subject({
    required this.id,
    required this.nombre,
    required this.codigo,
    required this.descripcion,
    required this.creditos,
    this.profesorId,
    this.profesorDetail,
  });

  /// Crea una instancia de Subject a partir de un mapa JSON
  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      id: json['id'],
      nombre: json['nombre'],
      codigo: json['codigo'],
      descripcion: json['descripcion'],
      creditos: json['creditos'],
      profesorId: json['profesor'],
      profesorDetail: json['profesor_detail'],
    );
  }

  /// Convierte la instancia de Subject a un mapa JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'codigo': codigo,
      'descripcion': descripcion,
      'creditos': creditos,
      'profesor': profesorId,
      'profesor_detail': profesorDetail,
    };
  }
}
