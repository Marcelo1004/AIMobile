import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/grade.dart';
import '../../models/period.dart';
import '../../models/user.dart';
import '../../providers/auth_provider.dart';
import '../../providers/grade_provider.dart';
import 'self_evaluation_dialog.dart';

class GradesScreen extends StatefulWidget {
  const GradesScreen({super.key});

  @override
  State<GradesScreen> createState() => _GradesScreenState();
}

class _GradesScreenState extends State<GradesScreen> {
  Period? _selectedPeriod;
  int? _selectedCourseId;
  List<Map<String, dynamic>> _availableCourses = [];
  bool _isLoadingData = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoadingData = true;
    });

    // Cargar los periodos
    final gradeProvider = Provider.of<GradeProvider>(context, listen: false);
    await gradeProvider.loadPeriods();

    // Cargar los cursos disponibles si el usuario es profesor
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final User? currentUser = authProvider.currentUser;

    if (currentUser != null && currentUser.isTeacher) {
      await _loadAvailableCourses();
    }

    // Si hay periodos disponibles, seleccionar el primero
    if (gradeProvider.periods.isNotEmpty) {
      setState(() {
        _selectedPeriod = gradeProvider.periods.first;
      });

      // Cargar calificaciones del periodo seleccionado
      await _loadGrades();
    }

    setState(() {
      _isLoadingData = false;
    });
  }

  // Método para cargar los cursos disponibles para el profesor
  Future<void> _loadAvailableCourses() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final User? currentUser = authProvider.currentUser;

      if (currentUser != null && currentUser.isTeacher) {
        // TODO: Implementar el servicio para obtener los cursos
        // Por ahora, simulamos algunos cursos disponibles
        setState(() {
          _availableCourses = [
            {'id': 1, 'name': 'Curso 1-A'},
            {'id': 2, 'name': 'Curso 2-B'},
            {'id': 3, 'name': 'Curso 3-C'},
          ];

          // Seleccionar el primer curso por defecto si hay disponibles
          if (_availableCourses.isNotEmpty) {
            _selectedCourseId = _availableCourses.first['id'] as int;
          }
        });
      }
    } catch (e) {
      print('Error al cargar cursos disponibles: $e');
    }
  }

  Future<void> _loadGrades() async {
    if (_selectedPeriod == null) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final gradeProvider = Provider.of<GradeProvider>(context, listen: false);
    final User? currentUser = authProvider.currentUser;

    if (currentUser != null) {
      // Carga las calificaciones según el rol del usuario
      if (currentUser.isStudent) {
        // Estudiante solo ve sus propias calificaciones
        await gradeProvider.loadGrades(
          studentId: currentUser.id,
          periodId: _selectedPeriod!.id,
        );
      } else if (currentUser.isTeacher) {
        // Profesor ve las calificaciones de sus materias, filtradas por curso si hay uno seleccionado
        await gradeProvider.loadGrades(
          periodId: _selectedPeriod!.id,
          courseId: _selectedCourseId, // Usar el curso seleccionado para filtrar
        );
      } else if (currentUser.isAdmin) {
        // Administrativo ve todas las calificaciones
        await gradeProvider.loadGrades(
          periodId: _selectedPeriod!.id,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final gradeProvider = Provider.of<GradeProvider>(context);
    final User? currentUser = authProvider.currentUser;

    // Si no hay usuario o está cargando los datos iniciales
    if (currentUser == null || _isLoadingData) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // Si no hay periodos disponibles
    if (gradeProvider.periods.isEmpty) {
      return const Center(
        child: Text('No hay periodos académicos disponibles'),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Selector de periodo
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Periodo Académico',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<Period>(
                    value: _selectedPeriod,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    items: gradeProvider.periods.map((period) {
                      return DropdownMenuItem<Period>(
                        value: period,
                        child: Text(period.toString()),
                      );
                    }).toList(),
                    onChanged: (Period? value) {
                      if (value != null && value != _selectedPeriod) {
                        setState(() {
                          _selectedPeriod = value;
                        });
                        _loadGrades();
                      }
                    },
                  ),

                  // Selector de curso (solo para profesores)
                  if (currentUser.isTeacher && _availableCourses.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Filtrar por Curso',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<int>(
                      value: _selectedCourseId,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      items: _availableCourses.map((course) {
                        return DropdownMenuItem<int>(
                          value: course['id'] as int,
                          child: Text(course['name'] as String),
                        );
                      }).toList(),
                      onChanged: (int? value) {
                        if (value != null && value != _selectedCourseId) {
                          setState(() {
                            _selectedCourseId = value;
                          });
                          _loadGrades();
                        }
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Lista de Calificaciones
          Expanded(
            child: gradeProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : gradeProvider.grades.isEmpty
                    ? const Center(
                        child: Text('No hay calificaciones disponibles para este periodo'),
                      )
                    : ListView.builder(
                        itemCount: gradeProvider.grades.length,
                        itemBuilder: (context, index) {
                          final grade = gradeProvider.grades[index];
                          return GradeCard(grade: grade);
                        },
                      ),
          ),

          // Botón para añadir calificación (solo visible para profesores)
          if (currentUser.isTeacher || currentUser.isAdmin)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: ElevatedButton.icon(
                onPressed: () {
                  // Navegar a la pantalla de creación de calificación
                },
                icon: const Icon(Icons.add),
                label: const Text('Añadir Calificación'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class GradeCard extends StatelessWidget {
  final Grade grade;

  const GradeCard({super.key, required this.grade});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Aquí iría el nombre de la materia (no disponible en el modelo actual)
                Text(
                  'Materia ID: ${grade.materia}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Total: ${grade.puntajeFinal.toStringAsFixed(1)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const Divider(),
            // Detalles de la calificación
            _buildScoreRow('SER', grade.serPuntaje, 10),
            _buildScoreRow('SABER', grade.saberPuntaje, 35),
            _buildScoreRow('HACER', grade.hacerPuntaje, 35),
            _buildScoreRow('DECIDIR', grade.decidirPuntaje, 10),

            // Autoevaluación (si existe)
            if (grade.autoevaluacionSer != null && grade.autoevaluacionDecidir != null) ...[
              const Divider(),
              const Text(
                'Autoevaluación',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              _buildScoreRow('SER', grade.autoevaluacionSer!, 5),
              _buildScoreRow('DECIDIR', grade.autoevaluacionDecidir!, 5),
            ],

            // Opciones adicionales
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    // Navegar al detalle de la calificación
                  },
                  child: const Text('Ver Detalles'),
                ),
                const SizedBox(width: 8),
                // Si el usuario es estudiante y no hay autoevaluación, mostrar botón
                if (Provider.of<AuthProvider>(context).currentUser?.isStudent == true &&
                    (grade.autoevaluacionSer == null || grade.autoevaluacionDecidir == null))
                  TextButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => SelfEvaluationDialog(grade: grade),
                      );
                    },
                    child: const Text('Autoevaluar'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreRow(String label, double score, double maxScore) {
    final percentage = (score / maxScore) * 100;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                Container(
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: percentage / 100,
                  child: Container(
                    height: 10,
                    decoration: BoxDecoration(
                      color: _getColorForScore(percentage),
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 70,
            child: Text(
              '${score.toStringAsFixed(1)}/$maxScore',
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Color _getColorForScore(double percentage) {
    if (percentage >= 80) {
      return Colors.green;
    } else if (percentage >= 60) {
      return Colors.amber;
    } else {
      return Colors.red;
    }
  }
}
