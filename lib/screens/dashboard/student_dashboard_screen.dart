import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';


import '../../models/dashboard.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dashboard_provider.dart';

class StudentDashboardScreen extends StatefulWidget {
  static const String routeName = '/dashboard/student';

  final int? studentId;

  const StudentDashboardScreen({
    Key? key,
    this.studentId,
  }) : super(key: key);

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    // Cargar los datos del dashboard al iniciar la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DashboardProvider>(context, listen: false)
          .loadStudentDashboard(studentId: widget.studentId);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.studentId != null
          ? 'Dashboard de Estudiante'
          : 'Mi Dashboard'
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Provider.of<DashboardProvider>(context, listen: false)
                .loadStudentDashboard(studentId: widget.studentId);
            },
            tooltip: 'Actualizar datos',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Resumen'),
            Tab(text: 'Calificaciones'),
            Tab(text: 'Asistencia'),
            Tab(text: 'Predicciones'),
          ],
        ),
      ),
      body: Consumer<DashboardProvider>(
        builder: (context, dashboardProvider, _) {
          if (dashboardProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (dashboardProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error al cargar dashboard',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(dashboardProvider.error!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => dashboardProvider.loadStudentDashboard(
                      studentId: widget.studentId
                    ),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          final dashboard = dashboardProvider.studentDashboard;

          if (dashboard == null) {
            return const Center(
              child: Text('No hay datos disponibles'),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildSummaryTab(dashboard),
              _buildGradesTab(dashboard),
              _buildAttendanceTab(dashboard),
              _buildPredictionsTab(dashboard),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSummaryTab(StudentDashboard dashboard) {
    final studentInfo = dashboard.student;

    // Calcular promedios generales
    double averageGrade = 0;
    if (dashboard.grades.isNotEmpty) {
      int totalComponents = 0;
      double totalGrade = 0;

      for (var course in dashboard.grades) {
        for (var term in course.terms.values) {
          totalGrade += term.totalGrade;
          totalComponents++;
        }
      }

      if (totalComponents > 0) {
        averageGrade = totalGrade / totalComponents;
      }
    }

    // Calcular asistencia promedio
    double attendancePercentage = 0;
    if (dashboard.attendances.isNotEmpty) {
      attendancePercentage = dashboard.attendances
          .map((a) => a.percentage)
          .reduce((a, b) => a + b) / dashboard.attendances.length;
    }

    return RefreshIndicator(
      onRefresh: () => Provider.of<DashboardProvider>(context, listen: false)
          .loadStudentDashboard(studentId: widget.studentId),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStudentInfoCard(studentInfo),
            const SizedBox(height: 20),
            _buildAcademicSummaryCard(averageGrade, attendancePercentage),
            const SizedBox(height: 20),
            _buildRecentPredictionsCard(dashboard.predictions),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentInfoCard(Map<String, dynamic> student) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.blue.shade100,
              child: Text(
                student['nombre_completo'].toString().substring(0, 1).toUpperCase(),
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade800,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    student['nombre_completo'] ?? 'Estudiante',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    student['email'] ?? '',
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'ID: ${student['id']}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAcademicSummaryCard(double averageGrade, double attendancePercentage) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Resumen Académico',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Promedio General',
                    '${averageGrade.toStringAsFixed(1)}',
                    Icons.assessment,
                    averageGrade >= 80 ? Colors.green :
                    averageGrade >= 60 ? Colors.amber : Colors.red,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Asistencia',
                    '${attendancePercentage.toStringAsFixed(1)}%',
                    Icons.calendar_today,
                    attendancePercentage >= 90 ? Colors.green :
                    attendancePercentage >= 75 ? Colors.amber : Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black54,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildRecentPredictionsCard(List<StudentPrediction> predictions) {
    if (predictions.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: Text('No hay predicciones disponibles'),
          ),
        ),
      );
    }

    final latestPredictions = predictions.take(3).toList();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Predicciones Recientes',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Navegar a la tab de predicciones
                    _tabController.animateTo(3);
                  },
                  child: const Text('Ver todas'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...latestPredictions.map((prediction) => _buildPredictionItem(prediction)),
          ],
        ),
      ),
    );
  }

  Widget _buildPredictionItem(StudentPrediction prediction) {
    final levelColors = {
      'Excelente': Colors.green,
      'Bueno': Colors.lightGreen,
      'Regular': Colors.amber,
      'Necesita apoyo': Colors.orange,
      'Crítico': Colors.red,
    };

    final color = levelColors[prediction.performanceLevel] ?? Colors.grey;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: color.withOpacity(0.2),
            child: Text(
              prediction.numericValue.round().toString(),
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  prediction.courseName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Nivel: ${prediction.performanceLevel}',
                  style: TextStyle(
                    color: color,
                    fontSize: 13,
                  ),
                ),
                Text(
                  'Prob. de aprobar: ${prediction.passProb.toStringAsFixed(1)}%',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: color.withOpacity(0.3)),
                ),
                child: Text(
                  prediction.numericValue.toStringAsFixed(1),
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                prediction.predictionDate,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGradesTab(StudentDashboard dashboard) {
    final courses = dashboard.grades;

    if (courses.isEmpty) {
      return const Center(
        child: Text('No hay calificaciones disponibles'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: courses.length,
      itemBuilder: (context, index) {
        final course = courses[index];
        return _buildCourseGradesCard(course);
      },
    );
  }

  Widget _buildCourseGradesCard(CourseGrade course) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ExpansionTile(
        title: Text(
          course.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        childrenPadding: const EdgeInsets.all(16),
        children: [
          ...course.terms.entries.map((entry) {
            final termGrade = entry.value;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Trimestre ${termGrade.term} (${termGrade.year})',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getGradeColor(termGrade.totalGrade),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        termGrade.totalGrade.toStringAsFixed(1),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildComponentsChart(termGrade.components),
                const Divider(height: 24),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildComponentsChart(GradeComponents components) {
    final data = [
      _ComponentData('Ser', components.ser),
      _ComponentData('Saber', components.saber),
      _ComponentData('Hacer', components.hacer),
      _ComponentData('Decidir', components.decidir),
      _ComponentData('Auto', components.autoEvaluation),
    ];

    return SizedBox(
      height: 180,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceEvenly,
          maxY: 100,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              tooltipBgColor: Colors.blueGrey.withOpacity(0.8),
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final component = data[groupIndex];
                return BarTooltipItem(
                  '${component.name}: ${component.value.toStringAsFixed(1)}',
                  const TextStyle(color: Colors.white),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value >= 0 && value < data.length) {
                    return Text(
                      data[value.toInt()].name,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  }
                  return const Text('');
                },
                reservedSize: 28,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value % 20 == 0) {
                    return Text('${value.toInt()}');
                  }
                  return const Text('');
                },
                reservedSize: 28,
              ),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: FlGridData(
            show: true,
            horizontalInterval: 20,
          ),
          borderData: FlBorderData(show: false),
          barGroups: data.asMap().entries.map((entry) {
            final index = entry.key;
            final component = entry.value;
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: component.value,
                  width: 20,
                  color: _getGradeColor(component.value),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(6),
                    topRight: Radius.circular(6),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Color _getGradeColor(double grade) {
    if (grade >= 90) return Colors.green.shade700;
    if (grade >= 80) return Colors.green;
    if (grade >= 70) return Colors.lightGreen;
    if (grade >= 60) return Colors.amber;
    if (grade >= 50) return Colors.orange;
    return Colors.red;
  }

  Widget _buildAttendanceTab(StudentDashboard dashboard) {
    final attendances = dashboard.attendances;

    if (attendances.isEmpty) {
      return const Center(
        child: Text('No hay datos de asistencia disponibles'),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildAttendanceOverviewCard(attendances),
        const SizedBox(height: 20),
        ...attendances.map((attendance) => _buildAttendanceCard(attendance)),
      ],
    );
  }

  Widget _buildAttendanceOverviewCard(List<CourseAttendance> attendances) {
    // Calcular el promedio general de asistencia
    final averageAttendance = attendances.isEmpty
        ? 0.0
        : attendances
              .map((a) => a.percentage)
              .reduce((a, b) => a + b) / attendances.length;

    // Encontrar el curso con mejor y peor asistencia
    if (attendances.isEmpty) {
      return Container();
    }

    final bestAttendance = attendances.reduce(
        (a, b) => a.percentage > b.percentage ? a : b);
    final worstAttendance = attendances.reduce(
        (a, b) => a.percentage < b.percentage ? a : b);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Resumen de Asistencia',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: SizedBox(
                height: 120,
                width: 120,
                child: Stack(
                  children: [
                    Center(
                      child: SizedBox(
                        height: 110,
                        width: 110,
                        child: CircularProgressIndicator(
                          value: averageAttendance / 100,
                          strokeWidth: 12,
                          backgroundColor: Colors.grey.withOpacity(0.2),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _getAttendanceColor(averageAttendance),
                          ),
                        ),
                      ),
                    ),
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${averageAttendance.toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: _getAttendanceColor(averageAttendance),
                            ),
                          ),
                          const Text(
                            'Promedio',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildAttendanceStat(
                    'Mejor Asistencia',
                    bestAttendance.courseName,
                    '${bestAttendance.percentage.toStringAsFixed(1)}%',
                    Icons.emoji_events,
                    Colors.amber,
                  ),
                ),
                Expanded(
                  child: _buildAttendanceStat(
                    'Menor Asistencia',
                    worstAttendance.courseName,
                    '${worstAttendance.percentage.toStringAsFixed(1)}%',
                    Icons.warning,
                    Colors.redAccent,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceStat(
      String title, String course, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        Text(
          course,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildAttendanceCard(CourseAttendance attendance) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(
          attendance.courseName,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            LinearProgressIndicator(
              value: attendance.percentage / 100,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(
                _getAttendanceColor(attendance.percentage),
              ),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 4),
            Text(
              'Presentes: ${attendance.present} de ${attendance.total} clases',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getAttendanceColor(attendance.percentage).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _getAttendanceColor(attendance.percentage).withOpacity(0.5),
            ),
          ),
          child: Text(
            '${attendance.percentage.toStringAsFixed(1)}%',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: _getAttendanceColor(attendance.percentage),
            ),
          ),
        ),
      ),
    );
  }

  Color _getAttendanceColor(double percentage) {
    if (percentage >= 90) return Colors.green;
    if (percentage >= 80) return Colors.lightGreen;
    if (percentage >= 70) return Colors.amber;
    if (percentage >= 60) return Colors.orange;
    return Colors.red;
  }

  Widget _buildPredictionsTab(StudentDashboard dashboard) {
    final predictions = dashboard.predictions;

    if (predictions.isEmpty) {
      return const Center(
        child: Text('No hay predicciones disponibles'),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildPredictionSummaryCard(predictions),
        const SizedBox(height: 20),
        ...predictions.map((prediction) => _buildPredictionCard(prediction)),
      ],
    );
  }

  Widget _buildPredictionSummaryCard(List<StudentPrediction> predictions) {
    // Obtener la probabilidad promedio de aprobar
    final averageProbability = predictions.isEmpty
        ? 0.0
        : predictions
              .map((p) => p.passProb)
              .reduce((a, b) => a + b) / predictions.length;

    // Calcular distribución por nivel de rendimiento
    final Map<String, int> levelCounts = {};
    for (final prediction in predictions) {
      final level = prediction.performanceLevel;
      levelCounts[level] = (levelCounts[level] ?? 0) + 1;
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Resumen de Predicciones',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: SizedBox(
                height: 150,
                width: 150,
                child: Stack(
                  children: [
                    Center(
                      child: SizedBox(
                        height: 140,
                        width: 140,
                        child: CircularProgressIndicator(
                          value: averageProbability / 100,
                          strokeWidth: 14,
                          backgroundColor: Colors.grey.withOpacity(0.2),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _getProbabilityColor(averageProbability),
                          ),
                        ),
                      ),
                    ),
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${averageProbability.toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: _getProbabilityColor(averageProbability),
                            ),
                          ),
                          const Text(
                            'Prob. de aprobar',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Distribución por nivel',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            _buildLevelDistribution(levelCounts, predictions.length),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelDistribution(Map<String, int> levelCounts, int total) {
    final levelOrder = [
      'Crítico',
      'Necesita apoyo',
      'Regular',
      'Bueno',
      'Excelente',
    ];

    final levelColors = {
      'Excelente': Colors.green.shade700,
      'Bueno': Colors.lightGreen,
      'Regular': Colors.amber,
      'Necesita apoyo': Colors.orange,
      'Crítico': Colors.red,
    };

    return Column(
      children: levelOrder
          .where((level) => levelCounts.containsKey(level))
          .map((level) {
        final count = levelCounts[level] ?? 0;
        final percentage = total > 0 ? (count / total) * 100 : 0.0;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: levelColors[level],
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                level,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Text(
                '$count (${percentage.toStringAsFixed(1)}%)',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPredictionCard(StudentPrediction prediction) {
    final levelColors = {
      'Excelente': Colors.green.shade700,
      'Bueno': Colors.lightGreen,
      'Regular': Colors.amber,
      'Necesita apoyo': Colors.orange,
      'Crítico': Colors.red,
    };

    final color = levelColors[prediction.performanceLevel] ?? Colors.grey;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ExpansionTile(
        title: Text(
          prediction.courseName,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Row(
          children: [
            Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color.withOpacity(0.5)),
              ),
              child: Text(
                prediction.performanceLevel,
                style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Text(
              'Nota estimada: ${prediction.numericValue.toStringAsFixed(1)}',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        trailing: CircleAvatar(
          radius: 20,
          backgroundColor: _getProbabilityColor(prediction.passProb).withOpacity(0.2),
          child: Text(
            '${prediction.passProb.round()}%',
            style: TextStyle(
              color: _getProbabilityColor(prediction.passProb),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        childrenPadding: const EdgeInsets.all(16),
        children: [
          const Divider(),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Fecha de predicción:',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                prediction.predictionDate,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildPredictionVariables(prediction.variables),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Probabilidad de aprobar: ${prediction.passProb.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: _getProbabilityColor(prediction.passProb),
                ),
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: prediction.passProb / 100,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(
                  _getProbabilityColor(prediction.passProb),
                ),
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPredictionVariables(PredictionVariables variables) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Variables consideradas:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        _buildVariableItem(
          'Promedio de notas',
          '${variables.gradeAverage.toStringAsFixed(1)}',
          _getGradeColor(variables.gradeAverage),
        ),
        _buildVariableItem(
          'Porcentaje de asistencia',
          '${variables.attendancePercentage.toStringAsFixed(1)}%',
          _getAttendanceColor(variables.attendancePercentage),
        ),
        _buildVariableItem(
          'Promedio de participaciones',
          '${variables.participationAverage.toStringAsFixed(1)}',
          _getParticipationColor(variables.participationAverage),
        ),
      ],
    );
  }

  Widget _buildVariableItem(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[700],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: color.withOpacity(0.5)),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getParticipationColor(double value) {
    if (value >= 4) return Colors.green;
    if (value >= 3) return Colors.lightGreen;
    if (value >= 2) return Colors.amber;
    if (value >= 1) return Colors.orange;
    return Colors.red;
  }

  Color _getProbabilityColor(double probability) {
    if (probability >= 90) return Colors.green.shade700;
    if (probability >= 75) return Colors.green;
    if (probability >= 60) return Colors.amber;
    if (probability >= 40) return Colors.orange;
    return Colors.red;
  }
}

// Clase auxiliar para gráficos de componentes
class _ComponentData {
  final String name;
  final double value;

  _ComponentData(this.name, this.value);
}
