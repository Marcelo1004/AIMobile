import 'package:flutter/foundation.dart';
import '../api/grade_service.dart';
import '../models/grade.dart';
import '../models/period.dart';

/// Provider que maneja el estado de las calificaciones en la aplicación
class GradeProvider with ChangeNotifier {
  final GradeService _gradeService;

  List<Period> _periods = [];
  List<Grade> _grades = [];
  Map<String, dynamic> _courseStudentGrades = {};
  bool _loading = false;
  String? _error;

  // Constructor que recibe una instancia de GradeService
  GradeProvider(this._gradeService);

  // Getters para acceder al estado
  List<Period> get periods => _periods;
  List<Grade> get grades => _grades;
  Map<String, dynamic> get courseStudentGrades => _courseStudentGrades;
  bool get isLoading => _loading;
  String? get error => _error;

  /// Carga la lista de periodos académicos
  Future<void> loadPeriods() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final periods = await _gradeService.getPeriods();
      _periods = periods;
    } catch (e) {
      _error = 'Error al cargar periodos: $e';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Carga las calificaciones según los filtros proporcionados
  Future<void> loadGrades({
    int? studentId,
    int? subjectId,
    int? periodId,
    int? courseId,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final grades = await _gradeService.getGrades(
        studentId: studentId,
        subjectId: subjectId,
        periodId: periodId,
        courseId: courseId,
      );
      _grades = grades;
    } catch (e) {
      _error = 'Error al cargar calificaciones: $e';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Carga el detalle de una calificación específica
  Future<Grade?> loadGradeDetails(int gradeId) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final grade = await _gradeService.getGradeById(gradeId);
      _loading = false;
      notifyListeners();
      return grade;
    } catch (e) {
      _error = 'Error al cargar detalle de calificación: $e';
      _loading = false;
      notifyListeners();
      return null;
    }
  }

  /// Crea una nueva calificación (para profesores)
  Future<bool> createGrade(Grade grade) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final createdGrade = await _gradeService.createGrade(grade);
      if (createdGrade != null) {
        _grades.add(createdGrade);
        _loading = false;
        notifyListeners();
        return true;
      }
      _error = 'No se pudo crear la calificación';
      return false;
    } catch (e) {
      _error = 'Error al crear calificación: $e';
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Actualiza una calificación existente (para profesores)
  Future<bool> updateGrade(Grade grade) async {
    if (grade.id == null) {
      _error = 'No se puede actualizar una calificación sin ID';
      notifyListeners();
      return false;
    }

    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedGrade = await _gradeService.updateGrade(grade);
      if (updatedGrade != null) {
        // Actualizar la calificación en la lista
        final index = _grades.indexWhere((g) => g.id == grade.id);
        if (index != -1) {
          _grades[index] = updatedGrade;
        }
        return true;
      }
      _error = 'No se pudo actualizar la calificación';
      return false;
    } catch (e) {
      _error = 'Error al actualizar calificación: $e';
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Elimina una calificación (para profesores)
  Future<bool> deleteGrade(int gradeId) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _gradeService.deleteGrade(gradeId);
      if (success) {
        // Eliminar la calificación de la lista
        _grades.removeWhere((g) => g.id == gradeId);
        return true;
      }
      _error = 'No se pudo eliminar la calificación';
      return false;
    } catch (e) {
      _error = 'Error al eliminar calificación: $e';
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Envía autoevaluación para una calificación (para estudiantes)
  Future<bool> submitSelfEvaluation(int gradeId, double serScore, double decidirScore) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _gradeService.submitSelfEvaluation(
        gradeId,
        serScore,
        decidirScore
      );

      if (success) {
        // Actualizar la calificación en la lista con nueva autoevaluación
        await loadGradeDetails(gradeId).then((updatedGrade) {
          if (updatedGrade != null) {
            final index = _grades.indexWhere((g) => g.id == gradeId);
            if (index >= 0) {
              _grades[index] = updatedGrade;
            }
          }
        });

        _loading = false;
        notifyListeners();
        return true;
      }

      _error = 'No se pudo enviar la autoevaluación';
      _loading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Error al enviar autoevaluación: $e';
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  /// Carga estadísticas del estudiante
  Future<Map<String, dynamic>?> loadStudentStatistics(int studentId) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final statistics = await _gradeService.getStudentStatistics(studentId);
      _loading = false;
      notifyListeners();
      return statistics;
    } catch (e) {
      _error = 'Error al cargar estadísticas: $e';
      _loading = false;
      notifyListeners();
      return null;
    }
  }

  /// Carga estadísticas de una materia
  Future<Map<String, dynamic>?> loadSubjectStatistics({
    required int subjectId,
    int? periodId,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final statistics = await _gradeService.getSubjectStatistics(
        subjectId: subjectId,
        periodId: periodId,
      );
      _loading = false;
      notifyListeners();
      return statistics;
    } catch (e) {
      _error = 'Error al cargar estadísticas de materia: $e';
      _loading = false;
      notifyListeners();
      return null;
    }
  }

  /// Carga reporte trimestral
  Future<Map<String, dynamic>?> loadTermReport({
    required int courseId,
    required int periodId,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final report = await _gradeService.getTermReport(
        courseId: courseId,
        periodId: periodId,
      );
      _loading = false;
      notifyListeners();
      return report;
    } catch (e) {
      _error = 'Error al cargar reporte trimestral: $e';
      _loading = false;
      notifyListeners();
      return null;
    }
  }

  /// Carga las notas de los estudiantes de un curso específico para una materia y período
  /// Método específico para profesores
  Future<void> loadStudentGradesByCourse(int courseId, int subjectId, int periodId) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _gradeService.getStudentGradesByCourse(
        courseId,
        subjectId,
        periodId
      );

      _courseStudentGrades = result;
    } catch (e) {
      _error = 'Error al cargar notas de estudiantes: $e';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Crea una nueva nota para un estudiante específico
  /// Método específico para profesores
  Future<bool> createStudentGrade({
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
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _gradeService.createStudentGrade(
        courseId: courseId,
        studentId: studentId,
        subjectId: subjectId,
        periodId: periodId,
        serPuntaje: serPuntaje,
        saberPuntaje: saberPuntaje,
        hacerPuntaje: hacerPuntaje,
        decidirPuntaje: decidirPuntaje,
        autoevaluacionSer: autoevaluacionSer,
        autoevaluacionDecidir: autoevaluacionDecidir,
        comentario: comentario,
      );

      return result != null;
    } catch (e) {
      _error = 'Error al crear nota para estudiante: $e';
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Actualiza una nota existente
  /// Método específico para profesores
  Future<bool> updateStudentGrade({
    required int courseId,
    required int notaId,
    double? serPuntaje,
    double? saberPuntaje,
    double? hacerPuntaje,
    double? decidirPuntaje,
    String? comentario,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _gradeService.updateStudentGrade(
        courseId: courseId,
        notaId: notaId,
        serPuntaje: serPuntaje,
        saberPuntaje: saberPuntaje,
        hacerPuntaje: hacerPuntaje,
        decidirPuntaje: decidirPuntaje,
        comentario: comentario,
      );

      return result != null;
    } catch (e) {
      _error = 'Error al actualizar nota de estudiante: $e';
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Elimina una nota existente
  /// Método específico para profesores
  Future<bool> deleteStudentGrade(int courseId, int notaId) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _gradeService.deleteStudentGrade(courseId, notaId);
      return success;
    } catch (e) {
      _error = 'Error al eliminar nota de estudiante: $e';
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
