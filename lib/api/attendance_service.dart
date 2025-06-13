import '../api/api_client.dart';
import '../models/attendance.dart';

class AttendanceService {
  final ApiClient _apiClient;

  AttendanceService(this._apiClient);

  Future<List<Attendance>> getAttendances({
    int? estudianteId,
    int? materiaId,
    DateTime? fechaInicio,
    DateTime? fechaFin,
    bool? presente,
    int? cursoId,
    DateTime? fecha,
  }) async {
    try {
      Map<String, dynamic>? queryParams;

      if (estudianteId != null || materiaId != null || fechaInicio != null ||
          fechaFin != null || presente != null || cursoId != null || fecha != null) {
        queryParams = {};
        if (estudianteId != null) queryParams['estudiante'] = estudianteId;
        if (materiaId != null) queryParams['materia'] = materiaId;
        if (fechaInicio != null) queryParams['fecha_inicio'] = fechaInicio.toIso8601String().split('T')[0];
        if (fechaFin != null) queryParams['fecha_fin'] = fechaFin.toIso8601String().split('T')[0];
        if (presente != null) queryParams['presente'] = presente;
        if (cursoId != null) queryParams['curso'] = cursoId;
        if (fecha != null) queryParams['fecha'] = fecha.toIso8601String().split('T')[0];
      }

      final response = await _apiClient.get(
        'asistencias/',
        queryParameters: queryParams
      );

      final List<dynamic> attendanceData = response.data;
      return attendanceData
          .map((json) => Attendance.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener asistencias: $e');
    }
  }

  Future<Attendance> getAttendanceDetail(int attendanceId) async {
    try {
      final response = await _apiClient.get('asistencias/$attendanceId/');
      return Attendance.fromJson(response.data);
    } catch (e) {
      throw Exception('Error al obtener detalle de asistencia: $e');
    }
  }

  Future<Attendance> createAttendance(Attendance attendance) async {
    try {
      final response = await _apiClient.post(
        'asistencias/',
        data: attendance.toJson(),
      );
      return Attendance.fromJson(response.data);
    } catch (e) {
      throw Exception('Error al crear asistencia: $e');
    }
  }

  Future<Attendance> updateAttendance(Attendance attendance) async {
    try {
      final response = await _apiClient.put(
        'asistencias/${attendance.id}/',
        data: attendance.toJson(),
      );
      return Attendance.fromJson(response.data);
    } catch (e) {
      throw Exception('Error al actualizar asistencia: $e');
    }
  }

  Future<void> deleteAttendance(int attendanceId) async {
    try {
      await _apiClient.delete('asistencias/$attendanceId/');
    } catch (e) {
      throw Exception('Error al eliminar asistencia: $e');
    }
  }

  Future<AttendanceStatistics> getAttendanceStatistics({
    int? estudianteId,
    int? materiaId,
    DateTime? fechaInicio,
    DateTime? fechaFin,
  }) async {
    try {
      Map<String, dynamic>? queryParams;

      if (estudianteId != null || materiaId != null || fechaInicio != null || fechaFin != null) {
        queryParams = {};
        if (estudianteId != null) queryParams['estudiante'] = estudianteId;
        if (materiaId != null) queryParams['materia'] = materiaId;
        if (fechaInicio != null) queryParams['fecha_inicio'] = fechaInicio.toIso8601String().split('T')[0];
        if (fechaFin != null) queryParams['fecha_fin'] = fechaFin.toIso8601String().split('T')[0];
      }

      final response = await _apiClient.get(
        'asistencias/estadisticas_asistencia/',
        queryParameters: queryParams
      );

      return AttendanceStatistics.fromJson(response.data);
    } catch (e) {
      throw Exception('Error al obtener estadísticas de asistencia: $e');
    }
  }
}
