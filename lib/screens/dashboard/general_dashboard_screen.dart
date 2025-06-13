import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../models/dashboard_general.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dashboard_provider.dart';

class GeneralDashboardScreen extends StatefulWidget {
  static const String routeName = '/dashboard/general';

  const GeneralDashboardScreen({Key? key}) : super(key: key);

  @override
  State<GeneralDashboardScreen> createState() => _GeneralDashboardScreenState();
}

class _GeneralDashboardScreenState extends State<GeneralDashboardScreen> {
  @override
  void initState() {
    super.initState();

    // Cargar los datos del dashboard al iniciar la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DashboardProvider>(context, listen: false).loadGeneralDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard General'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Provider.of<DashboardProvider>(context, listen: false)
                .loadGeneralDashboard();
            },
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
                    onPressed: () => dashboardProvider.loadGeneralDashboard(),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          final dashboard = dashboardProvider.generalDashboard;

          if (dashboard == null) {
            return const Center(
              child: Text('No hay datos disponibles'),
            );
          }

          return RefreshIndicator(
            onRefresh: () => dashboardProvider.loadGeneralDashboard(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildGeneralStatsCards(dashboard),
                  const SizedBox(height: 20),
                  _buildAveragesSection(dashboard),
                  const SizedBox(height: 20),
                  _buildPredictionsDistribution(dashboard.predictionsDistribution),
                  const SizedBox(height: 20),
                  _buildCoursesPerformanceSection(dashboard.coursesStats),
                  const SizedBox(height: 20),
                  _buildTermsPerformanceSection(dashboard.termsStats),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGeneralStatsCards(GeneralDashboard dashboard) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Estadísticas Generales',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          childAspectRatio: 1.5,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildStatCard(
              'Estudiantes',
              dashboard.totalStudents.toString(),
              Icons.people,
              Colors.blue,
            ),
            _buildStatCard(
              'Materias',
              dashboard.totalCourses.toString(),
              Icons.book,
              Colors.purple,
            ),
            _buildStatCard(
              'Promedio General',
              '${dashboard.generalAverage.toStringAsFixed(1)}',
              Icons.assessment,
              Colors.orange,
            ),
            _buildStatCard(
              'Asistencia',
              '${dashboard.attendanceAverage.toStringAsFixed(1)}%',
              Icons.check_circle,
              Colors.green,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(0.7),
              color.withOpacity(0.9),
            ],
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAveragesSection(GeneralDashboard dashboard) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Promedios Institucionales',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildProgressIndicator(
                  'Asistencia',
                  dashboard.attendanceAverage / 100,
                  '${dashboard.attendanceAverage.toStringAsFixed(1)}%',
                  Colors.green,
                ),
                const SizedBox(height: 16),
                _buildProgressIndicator(
                  'Rendimiento Académico',
                  dashboard.generalAverage / 100,
                  '${dashboard.generalAverage.toStringAsFixed(1)}%',
                  Colors.blue,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressIndicator(
      String label, double value, String text, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            Text(
              text,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: value,
            backgroundColor: color.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildPredictionsDistribution(List<PredictionDistribution> predictions) {
    final Map<String, Color> levelColors = {
      'Excelente': Colors.green.shade700,
      'Bueno': Colors.lightGreen,
      'Regular': Colors.amber,
      'Necesita apoyo': Colors.orange,
      'Crítico': Colors.red,
    };

    // Calcular el total para los porcentajes
    final int total = predictions.fold(0, (sum, item) => sum + item.count);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Distribución de Predicciones',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                SizedBox(
                  height: 200,
                  child: PieChart(
                    PieChartData(
                      sections: predictions.map((prediction) {
                        final double percentage = total > 0
                          ? (prediction.count / total) * 100
                          : 0;

                        return PieChartSectionData(
                          color: levelColors[prediction.levelName] ?? Colors.grey,
                          value: prediction.count.toDouble(),
                          title: '${percentage.toStringAsFixed(1)}%',
                          radius: 80,
                          titleStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        );
                      }).toList(),
                      centerSpaceRadius: 40,
                      sectionsSpace: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: predictions.map((prediction) {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: levelColors[prediction.levelName] ?? Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${prediction.levelName} (${prediction.count})',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCoursesPerformanceSection(List<CourseStats> courses) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rendimiento por Curso',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                SizedBox(
                  height: 250,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: 100,
                      barTouchData: BarTouchData(
                        enabled: true,
                        touchTooltipData: BarTouchTooltipData(
                          tooltipBgColor: Colors.blueGrey.withOpacity(0.8),
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            final course = courses[groupIndex];
                            return BarTooltipItem(
                              '${course.name}\nPromedio: ${course.averageGrade.toStringAsFixed(1)}',
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
                              if (value >= 0 && value < courses.length) {
                                return Text(
                                  courses[value.toInt()].name.split(' ').last,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              }
                              return const Text('');
                            },
                            reservedSize: 30,
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
                        horizontalInterval: 20,
                      ),
                      borderData: FlBorderData(
                        show: false,
                      ),
                      barGroups: courses.asMap().entries.map((entry) {
                        final index = entry.key;
                        final course = entry.value;
                        return BarChartGroupData(
                          x: index,
                          barRods: [
                            BarChartRodData(
                              toY: course.averageGrade,
                              width: 20,
                              color: Colors.blue.withOpacity(0.8),
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
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTermsPerformanceSection(List<TermStats> terms) {
    if (terms.isEmpty) {
      return Container();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rendimiento por Trimestre',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                SizedBox(
                  height: 250,
                  child: LineChart(
                    LineChartData(
                      minX: 0,
                      maxX: (terms.length - 1).toDouble(),
                      minY: 0,
                      maxY: 100,
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: true,
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            getTitlesWidget: (value, meta) {
                              if (value >= 0 && value < terms.length) {
                                return Text(
                                  'T${terms[value.toInt()].term}',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                );
                              }
                              return const Text('');
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            getTitlesWidget: (value, meta) {
                              if (value % 20 == 0) {
                                return Text('${value.toInt()}%');
                              }
                              return const Text('');
                            },
                          ),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      borderData: FlBorderData(
                        show: true,
                        border: Border.all(color: Colors.black12),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          spots: terms.asMap().entries.map((entry) {
                            final index = entry.key;
                            final term = entry.value;
                            return FlSpot(index.toDouble(), term.average);
                          }).toList(),
                          isCurved: true,
                          color: Colors.blue,
                          barWidth: 4,
                          isStrokeCapRound: true,
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, percent, barData, index) {
                              return FlDotCirclePainter(
                                radius: 6,
                                color: Colors.white,
                                strokeWidth: 2,
                                strokeColor: Colors.blue,
                              );
                            },
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            color: Colors.blue.withOpacity(0.2),
                          ),
                        ),
                      ],
                      lineTouchData: LineTouchData(
                        touchTooltipData: LineTouchTooltipData(
                          tooltipBgColor: Colors.blueGrey.withOpacity(0.8),
                          getTooltipItems: (List<LineBarSpot> touchedSpots) {
                            return touchedSpots.map((spot) {
                              final term = terms[spot.x.toInt()];
                              return LineTooltipItem(
                                'Trimestre ${term.term}\nPromedio: ${term.average.toStringAsFixed(1)}%\nEstudiantes: ${term.students}',
                                const TextStyle(color: Colors.white),
                              );
                            }).toList();
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildTermStatsCard(
                      'Estudiantes Promedio',
                      terms.fold(0, (sum, term) => sum + term.students) ~/ terms.length,
                      Icons.people,
                      Colors.indigo,
                    ),
                    _buildTermStatsCard(
                      'Mejor Trimestre',
                      terms.reduce((a, b) => a.average > b.average ? a : b).term,
                      Icons.emoji_events,
                      Colors.amber,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTermStatsCard(String title, num value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                '$value',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
