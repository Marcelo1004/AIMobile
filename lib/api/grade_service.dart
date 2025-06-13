
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/grade.dart';
import '../models/period.dart';
import 'api_client.dart';

/// Servicio para manejar las operaciones relacionadas con calificaciones
class GradeService {
  final ApiClient _apiClient;

  GradeService(this._apiClient);

  /// Obtiene todos los períodos académicos disponibles
  Future<List<Period>> getPeriods() async {
    try {
      final response = await _apiClient.get('notas/periodos/');

      // Convertir la respuesta a una lista de objetos Period
      final List<dynamic> periodsList = response.data;
      return periodsList.map((period) => Period.fromJson(period)).toList();
    } catch (e) {
      print('Error al obtener períodos: $e');
      return [];
    }
  }

  /// Obtiene las calificaciones según los filtros especificados
  ///
  /// Los filtros son opcionales y pueden incluir: estudiante, materia, periodo, curso
  Future<List<Grade>> getGrades({
    int? studentId,
    int? subjectId,
    int? periodId,
    int? courseId,
  }) async {
    try {
      // Construir los parámetros de consulta
      final Map<String, dynamic> queryParams = {};
      if (studentId != null) queryParams['estudiante'] = studentId;
      if (subjectId != null) queryParams['materia'] = subjectId;
      if (periodId != null) queryParams['periodo'] = periodId;
      if (courseId != null) queryParams['curso'] = courseId;

      final response = await _apiClient.get(
        'notas/calificaciones/',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      // Convertir la respuesta a una lista de objetos Grade
      final List<dynamic> gradesList = response.data;
      return gradesList.map((grade) => Grade.fromJson(grade)).toList();
    } catch (e) {
      print('Error al obtener calificaciones: $e');
      return [];
    }
  }

  /// Obtiene el detalle de una calificación específica por su ID
  Future<Grade?> getGradeById(int gradeId) async {
    try {
      final response = await _apiClient.get('notas/calificaciones/$gradeId/');
      return Grade.fromJson(response.data);
    } catch (e) {
      print('Error al obtener detalle de calificación: $e');
      return null;
    }
  }

  /// Crea una nueva calificación (solo para profesores)
  Future<Grade?> createGrade(Grade grade) async {
    try {
      final response = await _apiClient.post(
        'notas/calificaciones/',
        data: grade.toJson(),
      );

      if (response.statusCode == 201) {
        return Grade.fromJson(response.data);
      }
      return null;
    } catch (e) {
      print('Error al crear calificación: $e');
      return null;
    }
  }

  /// Actualiza una calificación existente (solo para profesores)
  Future<Grade?> updateGrade(Grade grade) async {
    try {
      if (grade.id == null) {
        throw Exception('No se puede actualizar una calificación sin ID');
      }

      final response = await _apiClient.put(
        'notas/calificaciones/${grade.id}/',
        data: grade.toJson(),
      );

      if (response.statusCode == 200) {
        return Grade.fromJson(response.data);
      }
      return null;
    } catch (e) {
      print('Error al actualizar calificación: $e');
      return null;
    }
  }

  /// Elimina una calificación (solo para profesores)
  Future<bool> deleteGrade(int gradeId) async {
    try {
      final response = await _apiClient.delete('notas/calificaciones/$gradeId/');
      return response.statusCode == 204;
    } catch (e) {
      print('Error al eliminar calificación: $e');
      return false;
    }
  }

  /// Realiza la autoevaluación del estudiante (solo para el estudiante asociado)
  Future<bool> submitSelfEvaluation(int gradeId, double serScore, double decidirScore) async {
    try {
      final response = await _apiClient.post(
        'notas/calificaciones/$gradeId/autoevaluacion/',
        data: {
          'autoevaluacion_ser': serScore,
          'autoevaluacion_decidir': decidirScore,
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error al enviar autoevaluación: $e');
      return false;
    }
  }

  /// Obtiene estadísticas del estudiante
  Future<Map<String, dynamic>?> getStudentStatistics(int studentId) async {
    try {
      final response = await _apiClient.get(
        'notas/calificaciones/estadisticas_estudiante/',
        queryParameters: {'estudiante': studentId},
      );

      if (response.statusCode == 200) {
        return response.data;
      }
      return null;
    } catch (e) {
      print('Error al obtener estadísticas del estudiante: $e');
      return null;
    }
  }

  /// Obtiene estadísticas de una materia (solo para profesores y administrativos)
  Future<Map<String, dynamic>?> getSubjectStatistics({
    required int subjectId,
    int? periodId,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {'materia': subjectId};
      if (periodId != null) queryParams['periodo'] = periodId;

      final response = await _apiClient.get(
        'notas/calificaciones/estadisticas_materia/',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        return response.data;
      }
      return null;
    } catch (e) {
      print('Error al obtener estadísticas de la materia: $e');
      return null;
    }
  }

  /// Obtiene reporte trimestral (solo para profesores y administrativos)
  Future<Map<String, dynamic>?> getTermReport({
    required int courseId,
    required int periodId,
  }) async {
    try {
      final response = await _apiClient.get(
        'notas/calificaciones/reporte_trimestral/',
        queryParameters: {
          'curso': courseId,
          'periodo': periodId,
        },
      );

      if (response.statusCode == 200) {
        return response.data;
      }
      return null;
    } catch (e) {
      print('Error al obtener reporte trimestral: $e');
      return null;
    }
  }

  /// Obtiene las notas de los estudiantes de un curso específico para una materia y período
  /// Método específico para profesores según la documentación.
  Future<Map<String, dynamic>> getStudentGradesByCourse(int courseId, int subjectId, int periodId) async {
    try {
      final response = await _apiClient.get('cursos/$courseId/estudiantes-con-notas/',
        queryParameters: {
          'materia_id': subjectId,
          'periodo_id': periodId,
        },
      );

      return response.data;
    } catch (e) {
      print('Error al obtener notas de estudiantes por curso: $e');
      return {};
    }
  }

  /// Crea una nueva nota para un estudiante específico
  /// Método específico para profesores según la documentación.
  Future<Map<String, dynamic>?> createStudentGrade({
    required int courseId,
    required int studentId,
    required int subjectId,
    required int periodId,
    required double serPuntaje,
    required double saberPuntaje,
    required double hacerPuntaje,
    required double decidirPuntaje,
    double? autoevaluacionSer,
    double? autoevaluacionDecidir,
    String? comentario,
  }) async {
    try {
      final data = {
        "estudiante_id": studentId,
        "materia_id": subjectId,
        "periodo_id": periodId,
        "ser_puntaje": serPuntaje,
        "saber_puntaje": saberPuntaje,
        "hacer_puntaje": hacerPuntaje,
        "decidir_puntaje": decidirPuntaje,
        "autoevaluacion_ser": autoevaluacionSer ?? 0,
        "autoevaluacion_decidir": autoevaluacionDecidir ?? 0,
        "comentario": comentario ?? "",
      };

      // Obtener el token de autenticación explícitamente
      final FlutterSecureStorage secureStorage = FlutterSecureStorage();
      final token = await secureStorage.read(key: 'access_token');

      final response = await _apiClient.post(
        'cursos/$courseId/crear-nota/',
        data: data,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token', // Añadir token explícitamente
          },
        ),
      );

      if (response.statusCode == 201) {
        return response.data;
      }
      return null;
    } catch (e) {
      print('Error al crear nota para estudiante: $e');
      return null;
    }
  }

  /// Actualiza una nota existente
  /// Método específico para profesores según la documentación.
  Future<Map<String, dynamic>?> updateStudentGrade({
    required int courseId,
    required int notaId,
    double? serPuntaje,
    double? saberPuntaje,
    double? hacerPuntaje,
    double? decidirPuntaje,
    String? comentario,
  }) async {
    try {
      final data = {};

      if (serPuntaje != null) data["ser_puntaje"] = serPuntaje;
      if (saberPuntaje != null) data["saber_puntaje"] = saberPuntaje;
      if (hacerPuntaje != null) data["hacer_puntaje"] = hacerPuntaje;
      if (decidirPuntaje != null) data["decidir_puntaje"] = decidirPuntaje;
      if (comentario != null) data["comentario"] = comentario;

      // Obtener el token de autenticación explícitamente
      final FlutterSecureStorage secureStorage = FlutterSecureStorage();
      final token = await secureStorage.read(key: 'access_token');

      final response = await _apiClient.put(
        'cursos/$courseId/actualizar-nota/$notaId/',
        data: data,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token', // Añadir token explícitamente
          },
        ),
      );

      if (response.statusCode == 200) {
        return response.data;
      }
      return null;
    } catch (e) {
      print('Error al actualizar nota de estudiante: $e');
      return null;
    }
  }

  /// Elimina una nota existente
  /// Método específico para profesores según la documentación.
  Future<bool> deleteStudentGrade(int courseId, int notaId) async {
    try {
      // Obtener el token de autenticación explícitamente
      final FlutterSecureStorage secureStorage = FlutterSecureStorage();
      final token = await secureStorage.read(key: 'access_token');

      final response = await _apiClient.delete(
        'cursos/$courseId/eliminar-nota/$notaId/',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token', // Añadir token explícitamente
          },
        ),
      );

      return response.statusCode == 204;
    } catch (e) {
      print('Error al eliminar nota de estudiante: $e');
      return false;
    }
  }
}
