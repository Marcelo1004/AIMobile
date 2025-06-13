import 'package:flutter/foundation.dart';
import '../api/subject_service.dart';
import '../models/subject.dart';

/// Provider que maneja el estado de las materias en la aplicación
class SubjectProvider with ChangeNotifier {
  final SubjectService _subjectService;

  List<Subject> _subjects = [];
  Subject? _teacherSubject;
  bool _loading = false;
  String? _error;

  // Constructor que recibe una instancia de SubjectService
  SubjectProvider(this._subjectService);

  // Getters para acceder al estado
  List<Subject> get subjects => _subjects;
  Subject? get teacherSubject => _teacherSubject;
  bool get isLoading => _loading;
  String? get error => _error;

  /// Carga la lista de todas las materias disponibles
  Future<void> loadSubjects() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final subjects = await _subjectService.getSubjects();
      _subjects = subjects;
    } catch (e) {
      _error = 'Error al cargar materias: $e';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Carga la materia asignada a un profesor específico
  Future<void> loadTeacherSubject(int teacherId) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final subject = await _subjectService.getSubjectByTeacherId(teacherId);
      _teacherSubject = subject;
    } catch (e) {
      _error = 'Error al cargar la materia del profesor: $e';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
