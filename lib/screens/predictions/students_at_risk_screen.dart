import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/prediction.dart';
import '../../providers/prediction_provider.dart';
import 'prediction_detail_screen.dart';

class StudentsAtRiskScreen extends StatefulWidget {
  static const String routeName = '/students-at-risk';

  const StudentsAtRiskScreen({Key? key}) : super(key: key);

  @override
  State<StudentsAtRiskScreen> createState() => _StudentsAtRiskScreenState();
}

class _StudentsAtRiskScreenState extends State<StudentsAtRiskScreen> {
  int? _selectedCursoId;
  int? _selectedMateriaId;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadStudentsAtRisk();
    });
  }

  Future<void> _loadStudentsAtRisk() async {
    final predictionProvider = Provider.of<PredictionProvider>(context, listen: false);
    await predictionProvider.loadStudentsAtRisk(
      cursoId: _selectedCursoId,
      materiaId: _selectedMateriaId,
    );
  }

  Future<void> _showFilterDialog() async {
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Filtrar Estudiantes'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
            const SizedBox(height: 16),
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
                _selectedCursoId = null;
                _selectedMateriaId = null;
              });
              Navigator.of(ctx).pop();
              _loadStudentsAtRisk();
            },
          ),
          TextButton(
            child: const Text('Aplicar'),
            onPressed: () {
              Navigator.of(ctx).pop();
              _loadStudentsAtRisk();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Estudiantes en Riesgo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: _buildStudentsList(),
    );
  }

  Widget _buildStudentsList() {
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
                  'Error al cargar estudiantes en riesgo',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(predictionProvider.error!),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadStudentsAtRisk,
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          );
        }

        final students = predictionProvider.studentsAtRisk;

        if (students.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle, size: 60, color: Colors.green),
                const SizedBox(height: 16),
                Text(
                  'No se encontraron estudiantes en riesgo',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                const Text(
                  '¡Excelente! Los estudiantes parecen estar en buen camino académico.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadStudentsAtRisk,
                  child: const Text('Actualizar'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _loadStudentsAtRisk,
          child: ListView.builder(
            itemCount: students.length,
            itemBuilder: (context, index) {
              final student = students[index];
              return _buildStudentAtRiskCard(student);
            },
            padding: const EdgeInsets.all(16),
          ),
        );
      },
    );
  }

  Widget _buildStudentAtRiskCard(StudentAtRisk student) {
    // Determinar color según nivel de riesgo de la primera materia (si hay alguna)
    Color riskColor;
    String nivelRiesgo = "DESCONOCIDO";
    double valorPredicho = 0.0;

    // Verificar si el estudiante tiene materias en riesgo
    if (student.materiasRiesgo.isNotEmpty) {
      // Tomar la primera materia en riesgo para mostrar su nivel de rendimiento
      final primeraMateriaEnRiesgo = student.materiasRiesgo.first;
      nivelRiesgo = primeraMateriaEnRiesgo.nivelRendimiento;
      valorPredicho = primeraMateriaEnRiesgo.valorPredicho;

      switch (nivelRiesgo) {
        case 'BAJO':
          riskColor = Colors.red;
          break;
        case 'MEDIO':
          riskColor = Colors.orange;
          break;
        case 'ALTO':
          riskColor = Colors.yellow;
          break;
        default:
          riskColor = Colors.grey;
      }
    } else {
      riskColor = Colors.grey;
    }

    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: riskColor, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: BoxDecoration(
              color: riskColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  student.nombre,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Chip(
                  label: Text(
                    'Riesgo $nivelRiesgo',
                    style: TextStyle(
                      color: riskColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  backgroundColor: riskColor.withOpacity(0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.trending_down, color: Colors.red),
                    const SizedBox(width: 8),
                    Text(
                      'Predicción: ${valorPredicho.toStringAsFixed(1)}%',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Curso: ${student.curso}',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Materias en riesgo:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...student.materiasRiesgo.map((materia) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    children: [
                      Icon(Icons.warning, size: 16, color: materia.getRendimientoColor()),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${materia.materiaNombre} - ${materia.valorPredicho.toStringAsFixed(1)}% (${materia.nivelRendimiento})',
                          style: TextStyle(
                            color: materia.getRendimientoColor(),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    OutlinedButton.icon(
                      icon: const Icon(Icons.mail),
                      label: const Text('Contactar'),
                      onPressed: () {
                        // Implementar funcionalidad para contactar al estudiante
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Funcionalidad de contacto no implementada')),
                        );
                      },
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.psychology),
                      label: const Text('Generar Predicción'),
                      onPressed: () async {
                        _showGeneratePredictionDialog(student.estudianteId);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showGeneratePredictionDialog(int estudianteId) async {
    int? materiaId;
    bool useML = true; // Por defecto usar modelo avanzado

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Generar Nueva Predicción'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'ID de la Materia'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  if (value.isNotEmpty) {
                    materiaId = int.tryParse(value);
                  } else {
                    materiaId = null;
                  }
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
          actions: [
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
            TextButton(
              child: const Text('Generar'),
              onPressed: () async {
                if (materiaId != null) {
                  Navigator.of(ctx).pop();
                  final predictionProvider = Provider.of<PredictionProvider>(context, listen: false);

                  try {
                    final prediction = await predictionProvider.generatePrediction(
                      estudianteId,
                      materiaId!,
                      useML: useML,
                    );

                    if (prediction != null && mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Predicción generada con éxito')),
                      );

                      // Navegar al detalle de la predicción
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PredictionDetailScreen(predictionId: prediction.id),
                        ),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error al generar predicción: $e')),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Por favor ingresa ID de materia')),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
