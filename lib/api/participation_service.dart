import '../api/api_client.dart';
import '../models/participation.dart';

class ParticipationService {
  final ApiClient _apiClient;

  ParticipationService(this._apiClient);

  // Agregamos un getter público para acceder al ApiClient
  ApiClient get apiClient => _apiClient;

  Future<List<Participation>> getParticipations({
    int? estudianteId,
    int? materiaId,
    DateTime? fechaInicio,
    DateTime? fechaFin,
    String? tipo,
    int? cursoId,
    DateTime? fecha,
  }) async {
    try {
      Map<String, dynamic>? queryParams;

      if (estudianteId != null || materiaId != null || fechaInicio != null ||
          fechaFin != null || tipo != null || cursoId != null || fecha != null) {
        queryParams = {};
        if (estudianteId != null) queryParams['estudiante'] = estudianteId;
        if (materiaId != null) queryParams['materia'] = materiaId;
        if (fechaInicio != null) queryParams['fecha_inicio'] = fechaInicio.toIso8601String().split('T')[0];
        if (fechaFin != null) queryParams['fecha_fin'] = fechaFin.toIso8601String().split('T')[0];
        if (tipo != null) queryParams['tipo'] = tipo;
        if (cursoId != null) queryParams['curso'] = cursoId;
        if (fecha != null) queryParams['fecha'] = fecha.toIso8601String().split('T')[0];
      }

      final response = await _apiClient.get(
        'participaciones/',
        queryParameters: queryParams
      );

      final List<dynamic> participationData = response.data;
      return participationData
          .map((json) => Participation.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener participaciones: $e');
    }
  }

  Future<Participation> getParticipationDetail(int participationId) async {
    try {
      final response = await _apiClient.get('participaciones/$participationId/');
      return Participation.fromJson(response.data);
    } catch (e) {
      throw Exception('Error al obtener detalle de participación: $e');
    }
  }

  Future<Participation> createParticipation(Participation participation) async {
    try {
      final response = await _apiClient.post(
        'participaciones/',
        data: participation.toJson(),
      );
      return Participation.fromJson(response.data);
    } catch (e) {
      throw Exception('Error al crear participación: $e');
    }
  }

  Future<Participation> updateParticipation(Participation participation) async {
    try {
      final response = await _apiClient.put(
        'participaciones/${participation.id}/',
        data: participation.toJson(),
      );
      return Participation.fromJson(response.data);
    } catch (e) {
      throw Exception('Error al actualizar participación: $e');
    }
  }

  Future<void> deleteParticipation(int participationId) async {
    try {
      await _apiClient.delete('participaciones/$participationId/');
    } catch (e) {
      throw Exception('Error al eliminar participación: $e');
    }
  }

  Future<ParticipationStatistics> getParticipationStatistics({
    int? estudianteId,
    int? materiaId,
  }) async {
    try {
      Map<String, dynamic>? queryParams;

      if (estudianteId != null || materiaId != null) {
        queryParams = {};
        if (estudianteId != null) queryParams['estudiante'] = estudianteId;
        if (materiaId != null) queryParams['materia'] = materiaId;
      }

      final response = await _apiClient.get(
        'participaciones/estadisticas_participacion/',
        queryParameters: queryParams
      );

      return ParticipationStatistics.fromJson(response.data);
    } catch (e) {
      throw Exception('Error al obtener estadísticas de participación: $e');
    }
  }
}
