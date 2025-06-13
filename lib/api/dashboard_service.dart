import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../api/api_client.dart';
import '../models/dashboard_general.dart';
import '../models/comparison_dashboard.dart';
import '../models/dashboard.dart';

/// Servicio para comunicarse con los endpoints del Dashboard en el backend
class DashboardService {
  final ApiClient _apiClient;

  DashboardService(this._apiClient);

  /// Obtiene las estadísticas generales del sistema
  ///
  /// El contenido dependerá del rol del usuario autenticado
  Future<GeneralDashboard> getGeneralStats() async {
    try {
      final response = await _apiClient.get('dashboard/general/');

      if (kDebugMode) {
        print('Dashboard general response: ${response.data}');
      }

      return GeneralDashboard.fromJson(response.data);
    } catch (e) {
      if (kDebugMode) {
        print('Error en getGeneralStats: $e');
      }
      throw Exception('Error al obtener estadísticas generales: $e');
    }
  }

  /// Obtiene el dashboard específico para un estudiante
  ///
  /// Si no se proporciona studentId, obtiene las estadísticas del estudiante autenticado
  Future<StudentDashboard> getStudentDashboard({int? studentId}) async {
    try {
      final String endpoint = studentId != null
          ? 'dashboard/estudiante/$studentId/'
          : 'dashboard/estudiante/';

      if (kDebugMode) {
        print('Calling endpoint: $endpoint');
      }

      final response = await _apiClient.get(endpoint);

      if (kDebugMode) {
        print('Dashboard estudiante response: ${response.data}');
      }

      return StudentDashboard.fromJson(response.data);
    } catch (e) {
      if (kDebugMode) {
        print('Error en getStudentDashboard: $e');
      }
      throw Exception('Error al obtener dashboard del estudiante: $e');
    }
  }

  /// Obtiene datos comparativos de rendimiento entre predicción y realidad
  ///
  /// Permite filtrar por estudiante o materia
  Future<PerformanceDashboard> getComparativeData({
    int? studentId,
    int? courseId,
  }) async {
    try {
      Map<String, dynamic>? queryParams;

      if (studentId != null || courseId != null) {
        queryParams = {};
        if (studentId != null) queryParams['estudiante'] = studentId;
        if (courseId != null) queryParams['materia'] = courseId;
      }

      final response = await _apiClient.get(
        'dashboard/comparativo/',
        queryParameters: queryParams
      );

      if (kDebugMode) {
        print('Dashboard comparativo response: ${response.data}');
      }

      return PerformanceDashboard.fromJson(response.data);
    } catch (e) {
      if (kDebugMode) {
        print('Error en getComparativeData: $e');
      }
      throw Exception('Error al obtener datos comparativos: $e');
    }
  }
}
