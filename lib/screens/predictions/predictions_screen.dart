import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../models/prediction.dart';
import '../../providers/auth_provider.dart';
import '../../providers/prediction_provider.dart';
import '../../providers/course_provider.dart';
import '../../providers/subject_provider.dart';
import 'prediction_detail_screen.dart';
import 'students_at_risk_screen.dart';

class PredictionsScreen extends StatefulWidget {
  static const String routeName = '/predictions';

  const PredictionsScreen({Key? key}) : super(key: key);

  @override
  State<PredictionsScreen> createState() => _PredictionsScreenState();
}

class _PredictionsScreenState extends State<PredictionsScreen> {
  int? _selectedMateriaId;
  int? _selectedCursoId;

  @override
  void initState() {
    super.initState();

    // Cargar predicciones al iniciar la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPredictions();
    });
  }

  Future<void> _loadPredictions() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final predictionProvider = Provider.of<PredictionProvider>(context, listen: false);

    final user = authProvider.currentUser;

    if (user != null) {
      if (user.role == 'ESTUDIANTE') {
        // Si es estudiante, solo verá sus propias predicciones
        await predictionProvider.loadPredictions(
          estudianteId: user.id,
          materiaId: _selectedMateriaId,
        );
      } else {
        // Si es profesor o administrativo, puede filtrar por curso o materia
        await predictionProvider.loadPredictions(
          materiaId: _selectedMateriaId,
          cursoId: _selectedCursoId,
        );
      }
    }
  }

  Future<void> _showFilterDialog() async {
    // Implementar filtro para curso y materia
    // Esta implementación es simplificada, idealmente deberías cargar
    // la lista de cursos y materias del backend
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Filtrar Predicciones'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'ID de Materia (opcional)'),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                if (value.isNotEmpty) {
                  _selectedMateriaId = int.tryParse(value);
                } else {
                  _selectedMateriaId = null;
                }
              },
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(labelText: 'ID de Curso (opcional)'),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                if (value.isNotEmpty) {
                  _selectedCursoId = int.tryParse(value);
                } else {
                  _selectedCursoId = null;
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          TextButton(
            child: const Text('Limpiar'),
            onPressed: () {
              setState(() {
                _selectedMateriaId = null;
                _selectedCursoId = null;
              });
              Navigator.of(ctx).pop();
              _loadPredictions();
            },
          ),
          TextButton(
            child: const Text('Aplicar'),
            onPressed: () {
              Navigator.of(ctx).pop();
              _loadPredictions();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;
    final bool isTeacherOrAdmin = user?.role == 'PROFESOR' || user?.role == 'ADMINISTRATIVO';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Predicciones Académicas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          if (isTeacherOrAdmin)
            IconButton(
              icon: const Icon(Icons.warning),
              tooltip: 'Estudiantes en Riesgo',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const StudentsAtRiskScreen()),
                );
              },
            ),
        ],
      ),
      body: _buildPredictionsList(),
      floatingActionButton: isTeacherOrAdmin ? FloatingActionButton(
        onPressed: _showGeneratePredictionDialog,
        child: const Icon(Icons.add),
        tooltip: 'Generar Predicción',
      ) : null,
    );
  }

  Widget _buildPredictionsList() {
    return Consumer<PredictionProvider>(
      builder: (ctx, predictionProvider, _) {
        if (predictionProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (predictionProvider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 60, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Error al cargar predicciones',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(predictionProvider.error!),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadPredictions,
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          );
        }

        final predictions = predictionProvider.predictions;

        if (predictions.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.analytics_outlined, size: 60, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  'No hay predicciones disponibles',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadPredictions,
                  child: const Text('Actualizar'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _loadPredictions,
          child: ListView.builder(
            itemCount: predictions.length,
            itemBuilder: (context, index) {
              final prediction = predictions[index];
              return _buildPredictionCard(prediction);
            },
          ),
        );
      },
    );
  }

  Widget _buildPredictionCard(Prediction prediction) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: prediction.getRendimientoColor().withOpacity(0.5),
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PredictionDetailScreen(predictionId: prediction.id),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Predicción ID: ${prediction.id}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Materia ID: ${prediction.materia}',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildPerformanceIndicator(prediction),
                ],
              ),
              const Divider(),
              const SizedBox(height: 8),
              _buildFactorRow(
                'Notas',
                prediction.promedioNotas,
                prediction.promedioNotas >= 70 ? Colors.green : Colors.red,
                Icons.school,
              ),
              const SizedBox(height: 8),
              _buildFactorRow(
                'Asistencia',
                prediction.porcentajeAsistencia,
                prediction.porcentajeAsistencia >= 80 ? Colors.green : Colors.red,
                Icons.calendar_today,
              ),
              const SizedBox(height: 8),
              _buildFactorRow(
                'Participaciones',
                prediction.promedioParticipaciones,
                prediction.promedioParticipaciones >= 5 ? Colors.green : Colors.red,
                Icons.record_voice_over,
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Fecha: ${DateFormat('dd/MM/yyyy').format(prediction.fechaPrediccion)}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.insights, size: 16, color: Colors.blueGrey),
                      const SizedBox(width: 4),
                      Text(
                        'Confianza: ${prediction.confianza}%',
                        style: const TextStyle(fontSize: 12, color: Colors.blueGrey),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPerformanceIndicator(Prediction prediction) {
    final color = prediction.getRendimientoColor();
    final icon = prediction.getRendimientoIcon();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 4),
          Text(
            '${prediction.valorNumerico.toStringAsFixed(1)}%',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFactorRow(String label, double value, Color color, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.blueGrey),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 14),
          ),
        ),
        Container(
          width: 100,
          height: 8,
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.2),
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: value / 100,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${value.toStringAsFixed(1)}%',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  void _showGeneratePredictionDialog() async {
    // Variables para almacenar las selecciones
    int? selectedCourseId;
    int? selectedStudentId;
    int? subjectId;
    bool useML = true; // Por defecto usar modelo avanzado

    // Obtener el provider de cursos y materias
    final courseProvider = Provider.of<CourseProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final subjectProvider = Provider.of<SubjectProvider>(context, listen: false);

    // Cargar la materia del profesor actual si es profesor
    if (authProvider.currentUser?.role == 'PROFESOR') {
      await subjectProvider.loadTeacherSubject(authProvider.currentUser!.id);
      subjectId = subjectProvider.teacherSubject?.id;

      // Si tenemos la materia del profesor, cargar los cursos donde se imparte
      if (subjectId != null) {
        await courseProvider.loadCoursesBySubjectId(subjectId);
      }
    }

    // Si no se pudo obtener la materia del profesor, mostrar un mensaje de error
    if (authProvider.currentUser?.role == 'PROFESOR' && subjectId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se encontró una materia asignada para el profesor')),
        );
      }
      return;
    }

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Generar Nueva Predicción'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (subjectId != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      'Materia: ${subjectProvider.teacherSubject?.nombre ?? 'Cargando...'}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),

                const Text('Selecciona un curso:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Consumer<CourseProvider>(
                  builder: (ctx, courseProvider, _) {
                    if (courseProvider.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (courseProvider.coursesForSubject.isEmpty) {
                      return const Text('No hay cursos disponibles para esta materia');
                    }

                    return DropdownButtonFormField<int>(
                      decoration: const InputDecoration(
                        labelText: 'Curso',
                        border: OutlineInputBorder(),
                      ),
                      value: selectedCourseId,
                      items: courseProvider.coursesForSubject.map((course) {
                        return DropdownMenuItem<int>(
                          value: course['id'],
                          child: Text('${course['nombre']} (${course['nivel']})'),
                        );
                      }).toList(),
                      onChanged: (courseId) {
                        setState(() {
                          selectedCourseId = courseId;
                          selectedStudentId = null; // Resetear estudiante al cambiar el curso
                        });

                        if (courseId != null) {
                          courseProvider.loadStudentsForCourse(courseId);
                        }
                      },
                    );
                  },
                ),

                const SizedBox(height: 16),

                const Text('Selecciona un estudiante:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Consumer<CourseProvider>(
                  builder: (ctx, courseProvider, _) {
                    if (selectedCourseId == null) {
                      return const Text('Primero selecciona un curso');
                    }

                    if (courseProvider.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (courseProvider.studentsInCourse.isEmpty) {
                      return const Text('No hay estudiantes en este curso');
                    }

                    return DropdownButtonFormField<int>(
                      decoration: const InputDecoration(
                        labelText: 'Estudiante',
                        border: OutlineInputBorder(),
                      ),
                      value: selectedStudentId,
                      items: courseProvider.studentsInCourse.map((student) {
                        final fullName = '${student['first_name']} ${student['last_name']}';
                        return DropdownMenuItem<int>(
                          value: student['id'],
                          child: Text(fullName),
                        );
                      }).toList(),
                      onChanged: (studentId) {
                        setState(() {
                          selectedStudentId = studentId;
                        });
                      },
                    );
                  },
                ),

                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Usar modelo avanzado de ML'),
                  subtitle: const Text('Proporciona predicciones más precisas'),
                  value: useML,
                  onChanged: (value) {
                    setState(() {
                      useML = value;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
            TextButton(
              child: const Text('Generar'),
              onPressed: () async {
                if (selectedStudentId != null && subjectId != null) {
                  // Guardar el contexto del Scaffold principal antes de cerrar el diálogo
                  final scaffoldContext = context;

                  // Cerrar el diálogo
                  Navigator.of(ctx).pop();

                  // Generar la predicción
                  final result = await _generatePrediction(selectedStudentId!, subjectId, useML);

                  // Verificar que el widget todavía esté montado y mostrar el mensaje
                  if (result && mounted) {

                    Future.microtask(() {

                      ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                        const SnackBar(content: Text('Predicción generada con éxito')),
                      );

                      // Recargar las predicciones
                      _loadPredictions();
                    });
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Por favor selecciona curso y estudiante')),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _generatePrediction(int estudianteId, int materiaId, bool useML) async {
    final predictionProvider = Provider.of<PredictionProvider>(context, listen: false);

    try {
      final prediction = await predictionProvider.generatePrediction(
        estudianteId,
        materiaId,
        useML: useML,
      );


      if (mounted) {
        _loadPredictions();
      }

      return prediction != null;
    } catch (e) {
      if (mounted) {
        // Solo mostrar error si el widget sigue montado
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al generar predicción: $e')),
        );
      }
      return false;
    }
  }
}
