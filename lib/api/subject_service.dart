// filepath: c:\Users\Andres\AndroidStudioProjects\Aula_Inteligente\lib\api\subject_service.dart
import 'dart:convert';
import '../models/subject.dart';
import 'api_client.dart';

/// Servicio para manejar las operaciones relacionadas con materias
class SubjectService {
  final ApiClient _apiClient;

  SubjectService(this._apiClient);

  /// Obtiene todas las materias disponibles
  Future<List<Subject>> getSubjects() async {
    try {
      final response = await _apiClient.get('materias/');

      // Convertir la respuesta a una lista de objetos Subject
      final List<dynamic> subjectsList = response.data;
      return subjectsList.map((subject) => Subject.fromJson(subject)).toList();
    } catch (e) {
      print('Error al obtener materias: $e');
      return [];
    }
  }

  /// Obtiene el detalle de una materia específica por su ID
  Future<Subject?> getSubjectById(int subjectId) async {
    try {
      final response = await _apiClient.get('materias/$subjectId/');
      return Subject.fromJson(response.data);
    } catch (e) {
      print('Error al obtener detalle de materia: $e');
      return null;
    }
  }

  /// Busca la materia asignada a un profesor específico
  Future<Subject?> getSubjectByTeacherId(int teacherId) async {
    try {
      // Obtener todas las materias
      final subjects = await getSubjects();

      // Buscar la materia que tiene asignado al profesor
      for (var subject in subjects) {
        if (subject.profesorId == teacherId) {
          return subject;
        }
      }

      return null; // No se encontró una materia para este profesor
    } catch (e) {
      print('Error al buscar materia por profesor: $e');
      return null;
    }
  }
}
