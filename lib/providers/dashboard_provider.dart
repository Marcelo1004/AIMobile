import 'package:flutter/foundation.dart';
import '../api/dashboard_service.dart';
import '../models/dashboard.dart';
import '../models/dashboard_general.dart';
import '../models/comparison_dashboard.dart';

/// Provider para gestionar el estado del Dashboard en la aplicación
class DashboardProvider with ChangeNotifier {
  final DashboardService _dashboardService;

  GeneralDashboard? _generalDashboard;
  StudentDashboard? _studentDashboard;
  PerformanceDashboard? _performanceDashboard;

  bool _isLoading = false;
  String? _error;

  DashboardProvider(this._dashboardService);

  // Getters
  GeneralDashboard? get generalDashboard => _generalDashboard;
  StudentDashboard? get studentDashboard => _studentDashboard;
  PerformanceDashboard? get performanceDashboard => _performanceDashboard;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Carga las estadísticas generales del dashboard
  Future<void> loadGeneralDashboard() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _generalDashboard = await _dashboardService.getGeneralStats();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Carga el dashboard específico de un estudiante
  ///
  /// Si no se proporciona studentId, carga el dashboard del estudiante autenticado
  Future<void> loadStudentDashboard({int? studentId}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _studentDashboard = await _dashboardService.getStudentDashboard(
        studentId: studentId
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Carga datos comparativos de rendimiento
  ///
  /// Permite filtrar por estudiante o materia
  Future<void> loadPerformanceDashboard({
    int? studentId,
    int? courseId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _performanceDashboard = await _dashboardService.getComparativeData(
        studentId: studentId,
        courseId: courseId,
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Reinicia todos los datos del dashboard
  void resetDashboard() {
    _generalDashboard = null;
    _studentDashboard = null;
    _performanceDashboard = null;
    _error = null;
    notifyListeners();
  }
}
