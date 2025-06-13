import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../models/comparison_dashboard.dart';
import '../../providers/dashboard_provider.dart';

class ComparisonDashboardScreen extends StatefulWidget {
  static const String routeName = '/dashboard/comparison';

  const ComparisonDashboardScreen({Key? key}) : super(key: key);

  @override
  State<ComparisonDashboardScreen> createState() => _ComparisonDashboardScreenState();
}

class _ComparisonDashboardScreenState extends State<ComparisonDashboardScreen> {
  int? _selectedStudentId;
  int? _selectedCourseId;

  @override
  void initState() {
    super.initState();
    // Cargar los datos iniciales del dashboard
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDashboard();
    });
  }

  void _loadDashboard() {
    Provider.of<DashboardProvider>(context, listen: false).loadPerformanceDashboard(
      studentId: _selectedStudentId,
      courseId: _selectedCourseId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Comparativo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboard,
            tooltip: 'Actualizar datos',
          ),
        ],
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
                    onPressed: _loadDashboard,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          final dashboard = dashboardProvider.performanceDashboard;

          if (dashboard == null) {
            return const Center(
              child: Text('No hay datos disponibles'),
            );
          }

          return Column(
            children: [
              _buildFilterBar(dashboard),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async => _loadDashboard(),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildAccuracySummaryCard(dashboard),
                        const SizedBox(height: 20),
                        _buildComparisonChart(dashboard),
                        const SizedBox(height: 20),
                        _buildComparisonList(dashboard.comparisons),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterBar(PerformanceDashboard dashboard) {
    // Extraer todos los estudiantes y cursos únicos para los filtros
    final students = <int, String>{};
    final courses = <int, String>{};

    for (final comparison in dashboard.comparisons) {
      students[comparison.studentId] = comparison.studentName;
      courses[comparison.courseId] = comparison.courseName;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.05),
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filtros',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildDropdownFilter<int>(
                  value: _selectedStudentId,
                  items: {...students.map((id, name) => MapEntry(id, name))},
                  onChanged: (value) {
                    setState(() => _selectedStudentId = value);
                    _loadDashboard();
                  },
                  hint: 'Todos los estudiantes',
                  labelText: 'Estudiante',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDropdownFilter<int>(
                  value: _selectedCourseId,
                  items: {...courses.map((id, name) => MapEntry(id, name))},
                  onChanged: (value) {
                    setState(() => _selectedCourseId = value);
                    _loadDashboard();
                  },
                  hint: 'Todas las materias',
                  labelText: 'Materia',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownFilter<T>({
    required T? value,
    required Map<T, String> items,
    required ValueChanged<T?> onChanged,
    required String hint,
    required String labelText,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        labelText: labelText,
        isDense: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      items: [
        DropdownMenuItem<T>(
          value: null,
          child: Text(hint),
        ),
        ...items.entries.map(
          (entry) => DropdownMenuItem<T>(
            value: entry.key,
            child: Text(
              entry.value,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
      onChanged: onChanged,
    );
  }

  Widget _buildAccuracySummaryCard(PerformanceDashboard dashboard) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Precisión del Modelo de Predicción',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildAccuracyIndicator(dashboard.modelAccuracy),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAccuracyStat(
                      'Total de predicciones',
                      dashboard.totalPredictions.toString(),
                      Icons.analytics,
                      Colors.blue,
                    ),
                    const SizedBox(height: 16),
                    _buildAccuracyStat(
                      'Margen de error promedio',
                      '±${_calculateAverageError(dashboard.comparisons).toStringAsFixed(1)}',
                      Icons.error_outline,
                      Colors.orange,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  double _calculateAverageError(List<PerformanceComparison> comparisons) {
    if (comparisons.isEmpty) return 0;
    return comparisons
        .map((c) => c.difference.abs())
        .reduce((a, b) => a + b) / comparisons.length;
  }

  Widget _buildAccuracyIndicator(double accuracy) {
    return SizedBox(
      height: 150,
      width: 150,
      child: Stack(
        children: [
          Center(
            child: SizedBox(
              height: 140,
              width: 140,
              child: CircularProgressIndicator(
                value: accuracy / 100,
                strokeWidth: 14,
                backgroundColor: Colors.grey.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(
                  _getAccuracyColor(accuracy),
                ),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${accuracy.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: _getAccuracyColor(accuracy),
                  ),
                ),
                const Text(
                  'Precisión',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccuracyStat(
      String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildComparisonChart(PerformanceDashboard dashboard) {
    // Si hay demasiados datos, limitar a los 10 más recientes para mejor visualización
    final comparisons = dashboard.comparisons.length > 10
        ? dashboard.comparisons.sublist(0, 10)
        : dashboard.comparisons;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Comparación de Predicciones vs. Notas Reales',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      tooltipBgColor: Colors.blueGrey.withOpacity(0.8),
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final comparison = comparisons[groupIndex];
                        String title;
                        if (rodIndex == 0) {
                          title = 'Predicción: ${comparison.predictedGrade.toStringAsFixed(1)}';
                        } else {
                          title = 'Real: ${comparison.actualGrade.toStringAsFixed(1)}';
                        }
                        return BarTooltipItem(
                          '${comparison.studentName}\n${comparison.courseName}\n$title',
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
                          if (value >= 0 && value < comparisons.length) {
                            final comparison = comparisons[value.toInt()];
                            String title = comparison.courseName.split(' ').first;
                            if (title.length > 6) title = title.substring(0, 6);
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                title,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          }
                          return const Text('');
                        },
                        reservedSize: 36,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(value.toInt().toString());
                        },
                        reservedSize: 30,
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
                    horizontalInterval: 10,
                  ),
                  borderData: FlBorderData(show: false),
                  maxY: 100,
                  groupsSpace: 20,
                  barGroups: comparisons.asMap().entries.map(
                    (entry) {
                      final index = entry.key;
                      final comparison = entry.value;
                      return BarChartGroupData(
                        x: index,
                        barsSpace: 4,
                        barRods: [
                          BarChartRodData(
                            toY: comparison.predictedGrade,
                            width: 12,
                            color: Colors.blue.withOpacity(0.7),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(4),
                              topRight: Radius.circular(4),
                            ),
                          ),
                          BarChartRodData(
                            toY: comparison.actualGrade,
                            width: 12,
                            color: Colors.green.withOpacity(0.7),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(4),
                              topRight: Radius.circular(4),
                            ),
                          ),
                        ],
                      );
                    },
                  ).toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildChartLegendItem('Predicción', Colors.blue),
                const SizedBox(width: 24),
                _buildChartLegendItem('Nota Real', Colors.green),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color.withOpacity(0.7),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildComparisonList(List<PerformanceComparison> comparisons) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Detalle de Comparaciones',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...comparisons.map((comparison) => _buildComparisonItem(comparison)),
      ],
    );
  }

  Widget _buildComparisonItem(PerformanceComparison comparison) {
    final differenceColor = comparison.difference > 0
        ? Colors.green
        : comparison.difference < 0
            ? Colors.red
            : Colors.grey;
    final differenceIcon = comparison.difference > 0
        ? Icons.arrow_upward
        : comparison.difference < 0
            ? Icons.arrow_downward
            : Icons.horizontal_rule;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
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
                        comparison.studentName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        comparison.courseName,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getLevelColor(comparison.predictedLevel),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    comparison.predictedLevel,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildGradeColumn('Predicción', comparison.predictedGrade, Colors.blue),
                _buildGradeColumn('Nota Real', comparison.actualGrade, Colors.green),
                Column(
                  children: [
                    const Text(
                      'Diferencia',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          differenceIcon,
                          size: 16,
                          color: differenceColor,
                        ),
                        Text(
                          comparison.difference.abs().toStringAsFixed(1),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: differenceColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: differenceColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: differenceColor.withOpacity(0.3)),
                      ),
                      child: Text(
                        _getDifferenceLabel(comparison.difference.abs()),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: differenceColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGradeColumn(String label, double grade, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(
              color: color.withOpacity(0.7),
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              grade.toStringAsFixed(1),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _getDifferenceLabel(double difference) {
    if (difference < 3) return 'Muy precisa';
    if (difference < 6) return 'Aceptable';
    if (difference < 10) return 'Imprecisa';
    return 'Muy imprecisa';
  }

  Color _getAccuracyColor(double accuracy) {
    if (accuracy >= 90) return Colors.green;
    if (accuracy >= 80) return Colors.lightGreen;
    if (accuracy >= 70) return Colors.amber;
    if (accuracy >= 60) return Colors.orange;
    return Colors.red;
  }

  Color _getLevelColor(String level) {
    const levelColors = {
      'Excelente': Color(0xFF388E3C),
      'Bueno': Color(0xFF8BC34A),
      'Regular': Color(0xFFFFC107),
      'Necesita apoyo': Color(0xFFFF9800),
      'Crítico': Color(0xFFF44336),
    };

    return levelColors[level] ?? Colors.grey;
  }
}
