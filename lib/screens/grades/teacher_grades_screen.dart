
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/grade_provider.dart';
import '../../providers/subject_provider.dart';
import '../../models/period.dart';
import '../../models/subject.dart';

class TeacherGradesScreen extends StatefulWidget {
  static const routeName = '/teacher-grades';

  const TeacherGradesScreen({Key? key}) : super(key: key);

  @override
  State<TeacherGradesScreen> createState() => _TeacherGradesScreenState();
}

class _TeacherGradesScreenState extends State<TeacherGradesScreen> {
  int? _selectedCourseId;
  int? _selectedPeriodId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
    });

    // Cargar la materia del profesor
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final subjectProvider = Provider.of<SubjectProvider>(context, listen: false);

    await subjectProvider.loadTeacherSubject(authProvider.currentUser!.id);

    // Cargar períodos
    final gradeProvider = Provider.of<GradeProvider>(context, listen: false);
    await gradeProvider.loadPeriods();

    if (gradeProvider.periods.isNotEmpty) {
      setState(() {
        _selectedPeriodId = gradeProvider.periods.first.id;
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadGradesForCourse() async {
    if (_selectedCourseId == null || _selectedPeriodId == null) return;

    final subjectProvider = Provider.of<SubjectProvider>(context, listen: false);
    final gradeProvider = Provider.of<GradeProvider>(context, listen: false);

    if (subjectProvider.teacherSubject == null) return;

    await gradeProvider.loadStudentGradesByCourse(
      _selectedCourseId!,
      subjectProvider.teacherSubject!.id,
      _selectedPeriodId!
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Notas'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildBody(),
    );
  }

  Widget _buildBody() {
    final subjectProvider = Provider.of<SubjectProvider>(context);
    final gradeProvider = Provider.of<GradeProvider>(context);

    if (subjectProvider.isLoading || gradeProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (subjectProvider.error != null) {
      return Center(child: Text('Error: ${subjectProvider.error}'));
    }

    if (subjectProvider.teacherSubject == null) {
      return const Center(
        child: Text('No tienes una materia asignada como profesor.'),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSubjectInfo(subjectProvider.teacherSubject!),
          const SizedBox(height: 20),
          _buildPeriodSelector(gradeProvider.periods),
          const SizedBox(height: 20),
          _buildCourseSelector(),
          const SizedBox(height: 20),
          if (_selectedCourseId != null && _selectedPeriodId != null)
            _buildGradesList(gradeProvider),
        ],
      ),
    );
  }

  Widget _buildSubjectInfo(Subject subject) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Materia: ${subject.nombre}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Código: ${subject.codigo}'),
            const SizedBox(height: 4),
            Text('Créditos: ${subject.creditos}'),
            const SizedBox(height: 4),
            Text('Descripción: ${subject.descripcion}'),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodSelector(List<Period> periods) {
    if (periods.isEmpty) {
      return const Text('No hay períodos disponibles');
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: DropdownButtonFormField<int>(
          decoration: const InputDecoration(
            labelText: 'Período',
            border: InputBorder.none,
          ),
          value: _selectedPeriodId,
          items: periods.map((period) {
            return DropdownMenuItem<int>(
              value: period.id,
              child: Text('${period.nombre} (${period.yearAcademico})'),
            );
          }).toList(),
          onChanged: (periodId) {
            setState(() {
              _selectedPeriodId = periodId;
            });
            if (_selectedCourseId != null) {
              _loadGradesForCourse();
            }
          },
        ),
      ),
    );
  }

  Widget _buildCourseSelector() {
    // Todos los cursos disponibles en el sistema
    final allCourses = [
      {'id': 1, 'nombre': '1ro Primaria', 'nivel': 'PRIMARIA', 'materias': [11, 12, 13, 14, 15]},
      {'id': 2, 'nombre': '2do Primaria', 'nivel': 'PRIMARIA', 'materias': [11, 12, 13, 14, 15]},
      {'id': 3, 'nombre': '3ro Primaria', 'nivel': 'PRIMARIA', 'materias': [11, 12, 13, 14, 15]},
      {'id': 4, 'nombre': '4to Primaria', 'nivel': 'PRIMARIA', 'materias': [11, 12, 13, 14, 15]},
      {'id': 5, 'nombre': '5to Primaria', 'nivel': 'PRIMARIA', 'materias': [11, 12, 13, 14, 15]},
      {'id': 6, 'nombre': '6to Primaria', 'nivel': 'PRIMARIA', 'materias': [11, 12, 13, 14, 15]},
      {'id': 7, 'nombre': '1ro Secundaria', 'nivel': 'SECUNDARIA', 'materias': [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]},
      {'id': 8, 'nombre': '2do Secundaria', 'nivel': 'SECUNDARIA', 'materias': [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]},
      {'id': 9, 'nombre': '3ro Secundaria', 'nivel': 'SECUNDARIA', 'materias': [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]},
      {'id': 10, 'nombre': '4to Secundaria', 'nivel': 'SECUNDARIA', 'materias': [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]},
      {'id': 11, 'nombre': '5to Secundaria', 'nivel': 'SECUNDARIA', 'materias': [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]},
      {'id': 12, 'nombre': '6to Secundaria', 'nivel': 'SECUNDARIA', 'materias': [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]},
    ];

    // Obtener la materia del profesor
    final subjectProvider = Provider.of<SubjectProvider>(context);
    final Subject? teacherSubject = subjectProvider.teacherSubject;

    if (teacherSubject == null) {
      return const Card(
        elevation: 2,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('No hay materia asignada para filtrar cursos'),
        ),
      );
    }

    // Filtrar los cursos para mostrar solo aquellos donde se imparte la materia del profesor
    final filteredCourses = allCourses.where((course) {
      final List<dynamic> materias = course['materias'] as List<dynamic>;
      return materias.contains(teacherSubject.id);
    }).toList();

    if (filteredCourses.isEmpty) {
      return const Card(
        elevation: 2,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('No hay cursos asignados a tu materia'),
        ),
      );
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: DropdownButtonFormField<int>(
          decoration: const InputDecoration(
            labelText: 'Curso',
            border: InputBorder.none,
          ),
          value: _selectedCourseId,
          items: filteredCourses.map((course) {
            return DropdownMenuItem<int>(
              value: course['id'] as int,
              child: Text('${course['nombre']} (${course['nivel']})'),
            );
          }).toList(),
          onChanged: (courseId) {
            setState(() {
              _selectedCourseId = courseId;
            });
            _loadGradesForCourse();
          },
        ),
      ),
    );
  }

  Widget _buildGradesList(GradeProvider gradeProvider) {
    if (gradeProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (gradeProvider.error != null) {
      return Center(child: Text('Error: ${gradeProvider.error}'));
    }

    final courseData = gradeProvider.courseStudentGrades;

    if (courseData.isEmpty) {
      return const Center(child: Text('No hay datos disponibles'));
    }

    final List<dynamic> students = courseData['estudiantes'] ?? [];

    if (students.isEmpty) {
      return const Center(child: Text('No hay estudiantes en este curso'));
    }

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Curso: ${courseData['nombre']} - ${courseData['nivel']}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text('Total de estudiantes: ${students.length}'),
          const SizedBox(height: 16),
          _buildGradesTable(students),
        ],
      ),
    );
  }

  Widget _buildGradesTable(List<dynamic> students) {
    return Expanded(
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: 12,
            horizontalMargin: 12,
            headingRowColor: MaterialStateProperty.all(
              Theme.of(context).colorScheme.primary.withOpacity(0.1),
            ),
            columns: const [
              DataColumn(label: Text('Nombre')),
              DataColumn(label: Text('Ser\n(10pts)')),
              DataColumn(label: Text('Saber\n(35pts)')),
              DataColumn(label: Text('Hacer\n(35pts)')),
              DataColumn(label: Text('Decidir\n(10pts)')),
              DataColumn(label: Text('Total\n(100%)')),
              DataColumn(label: Text('Estado')),
            ],
            rows: students.map<DataRow>((student) {
              final bool tieneNota = student['tiene_nota'] ?? false;

              return DataRow(
                cells: [
                  DataCell(Text('${student['first_name']} ${student['last_name']}')),
                  DataCell(tieneNota
                    ? Text('${student['ser_puntaje']}')
                    : const Text('-')),
                  DataCell(tieneNota
                    ? Text('${student['saber_puntaje']}')
                    : const Text('-')),
                  DataCell(tieneNota
                    ? Text('${student['hacer_puntaje']}')
                    : const Text('-')),
                  DataCell(tieneNota
                    ? Text('${student['decidir_puntaje']}')
                    : const Text('-')),
                  DataCell(tieneNota
                    ? Text('${student['nota_total']}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: student['aprobado'] == true
                            ? Colors.green
                            : Colors.red,
                        ))
                    : const Text('-')),
                  DataCell(tieneNota
                    ? Text(
                        student['aprobado'] == true ? 'Aprobado' : 'Reprobado',
                        style: TextStyle(
                          color: student['aprobado'] == true
                            ? Colors.green
                            : Colors.red,
                        ),
                      )
                    : const Text('Pendiente')),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
