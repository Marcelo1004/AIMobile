import 'package:flutter/foundation.dart';
import '../api/attendance_service.dart';
import '../models/attendance.dart';

class AttendanceProvider extends ChangeNotifier {
  final AttendanceService _attendanceService;

  List<Attendance> _attendances = [];
  bool _isLoading = false;
  String? _error;

  AttendanceProvider(this._attendanceService);

  List<Attendance> get attendances => _attendances;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadAttendances({
    int? estudianteId,
    int? materiaId,
    DateTime? fechaInicio,
    DateTime? fechaFin,
    bool? presente,
    int? cursoId,
    DateTime? fecha,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _attendances = await _attendanceService.getAttendances(
        estudianteId: estudianteId,
        materiaId: materiaId,
        fechaInicio: fechaInicio,
        fechaFin: fechaFin,
        presente: presente,
        cursoId: cursoId,
        fecha: fecha,
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<AttendanceStatistics?> getStatistics({
    int? estudianteId,
    int? materiaId,
    DateTime? fechaInicio,
    DateTime? fechaFin,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final stats = await _attendanceService.getAttendanceStatistics(
        estudianteId: estudianteId,
        materiaId: materiaId,
        fechaInicio: fechaInicio,
        fechaFin: fechaFin,
      );
      _isLoading = false;
      notifyListeners();
      return stats;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<bool> createAttendance(Attendance attendance) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newAttendance = await _attendanceService.createAttendance(attendance);
      _attendances.add(newAttendance);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateAttendance(Attendance attendance) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedAttendance = await _attendanceService.updateAttendance(attendance);
      final index = _attendances.indexWhere((a) => a.id == attendance.id);
      if (index != -1) {
        _attendances[index] = updatedAttendance;
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteAttendance(int attendanceId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _attendanceService.deleteAttendance(attendanceId);
      _attendances.removeWhere((a) => a.id == attendanceId);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
