/// Modelo que representa un usuario en el sistema
///
/// Contiene toda la información relevante de un usuario como su identificador,
/// nombre, correo, rol, etc.
class User {
  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String role;
  final int? courseId;
  final Map<String, dynamic>? courseDetail;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    this.courseId,
    this.courseDetail,
  });

  /// Crea una instancia de User a partir de un mapa JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      role: json['role'],
      courseId: json['curso'],
      courseDetail: json['curso_detail'],
    );
  }

  /// Convierte la instancia de User a un mapa JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'role': role,
      'curso': courseId,
      'curso_detail': courseDetail,
    };
  }

  /// Nombre completo del usuario
  String get fullName => '$firstName $lastName';

  /// Determina si el usuario es un estudiante
  bool get isStudent => role == 'ESTUDIANTE';

  /// Determina si el usuario es un profesor
  bool get isTeacher => role == 'PROFESOR';

  /// Determina si el usuario es un administrativo
  bool get isAdmin => role == 'ADMINISTRATIVO';
}

