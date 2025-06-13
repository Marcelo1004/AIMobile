import 'api_client.dart';

/// Servicio para manejar las operaciones relacionadas con cursos
class CourseService {
  final ApiClient _apiClient;

  CourseService(this._apiClient);

  /// Obtiene la lista de todos los cursos disponibles
  Future<List<Map<String, dynamic>>> getCourses() async {
    try {
      final response = await _apiClient.get('cursos/');

      // Convertir la respuesta a una lista de mapas
      final List<dynamic> coursesList = response.data;
      return coursesList.map((course) => course as Map<String, dynamic>).toList();
    } catch (e) {
      print('Error al obtener cursos: $e');
      // En caso de error, devolver una lista vacía
      return [];
    }
  }

  /// Obtiene los detalles de un curso específico por su ID
  Future<Map<String, dynamic>?> getCourseById(int courseId) async {
    try {
      final response = await _apiClient.get('cursos/$courseId/');
      return response.data;
    } catch (e) {
      print('Error al obtener el curso con ID $courseId: $e');
      return null;
    }
  }

  /// Obtiene la lista de estudiantes de un curso específico
  Future<List<Map<String, dynamic>>> getStudentsByCourseId(int courseId) async {
    try {
      // Usar el endpoint correcto: /usuarios/estudiantes/ con parámetro de query 'curso'
      final response = await _apiClient.get(
        'usuarios/estudiantes/',
        queryParameters: {'curso': courseId}
      );

      // Convertir la respuesta a una lista de mapas
      final List<dynamic> studentsList = response.data;
      return studentsList.map((student) => student as Map<String, dynamic>).toList();
    } catch (e) {
      print('Error al obtener estudiantes del curso $courseId: $e');
      // En caso de error, devolver una lista vacía
      return [];
    }
  }

  /// Obtiene los cursos que tienen una materia específica
  Future<List<Map<String, dynamic>>> getCoursesBySubjectId(int subjectId) async {
    try {
      // Primero obtenemos todos los cursos disponibles
      final response = await _apiClient.get('cursos/');

      // Convertir la respuesta a una lista de mapas
      final List<dynamic> allCourses = response.data;

      // Filtrar los cursos que contienen la materia especificada
      // Asumimos que cada curso tiene un campo 'materias' que es una lista de IDs de materias
      return allCourses.where((course) {
        if (course['materias'] is List) {
          final List<dynamic> materias = course['materias'];
          return materias.contains(subjectId);
        }
        return false;
      }).map((course) => course as Map<String, dynamic>).toList();
    } catch (e) {
      print('Error al obtener cursos para la materia $subjectId: $e');
      return [];
    }
  }
}

