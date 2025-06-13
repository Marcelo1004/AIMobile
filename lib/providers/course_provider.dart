import 'package:flutter/material.dart';

import '../api/course_service.dart';

/// Provider para gestionar los datos relacionados con los cursos
class CourseProvider with ChangeNotifier {
  final CourseService _courseService;

  List<Map<String, dynamic>> _courses = [];
  List<Map<String, dynamic>> _coursesForSubject = [];
  List<Map<String, dynamic>> _studentsInCourse = [];
  Map<String, dynamic>? _selectedCourse;

  bool _isLoading = false;
  String? _error;

  CourseProvider(this._courseService);

  // Getters
  List<Map<String, dynamic>> get courses => _courses;
  List<Map<String, dynamic>> get coursesForSubject => _coursesForSubject;
  List<Map<String, dynamic>> get studentsInCourse => _studentsInCourse;
  Map<String, dynamic>? get selectedCourse => _selectedCourse;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Carga la lista de todos los cursos disponibles
  Future<void> loadCourses() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final courses = await _courseService.getCourses();
      _courses = courses;
    } catch (e) {
      _error = 'Error al cargar los cursos: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Carga los cursos relacionados con una materia específica
  Future<void> loadCoursesBySubjectId(int subjectId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final courses = await _courseService.getCoursesBySubjectId(subjectId);
      _coursesForSubject = courses;
    } catch (e) {
      _error = 'Error al cargar los cursos para la materia: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Carga los estudiantes de un curso específico
  Future<void> loadStudentsForCourse(int courseId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final students = await _courseService.getStudentsByCourseId(courseId);
      _studentsInCourse = students;
    } catch (e) {
      _error = 'Error al cargar los estudiantes del curso: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Establece el curso seleccionado y carga sus estudiantes
  void selectCourse(Map<String, dynamic> course) {
    _selectedCourse = course;
    if (course.containsKey('id')) {
      loadStudentsForCourse(course['id']);
    }
    notifyListeners();
  }

  /// Limpia el curso seleccionado y su lista de estudiantes
  void clearSelection() {
    _selectedCourse = null;
    _studentsInCourse = [];
    notifyListeners();
  }
}
