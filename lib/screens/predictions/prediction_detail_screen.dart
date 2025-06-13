import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../models/prediction.dart';
import '../../providers/prediction_provider.dart';

class PredictionDetailScreen extends StatefulWidget {
  final int predictionId;

  const PredictionDetailScreen({
    Key? key,
    required this.predictionId,
  }) : super(key: key);

  @override
  State<PredictionDetailScreen> createState() => _PredictionDetailScreenState();
}

class _PredictionDetailScreenState extends State<PredictionDetailScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPredictionDetail();
    });
  }

  Future<void> _loadPredictionDetail() async {
    final predictionProvider = Provider.of<PredictionProvider>(context, listen: false);
    await predictionProvider.loadPredictionDetail(widget.predictionId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de Predicción'),
      ),
      body: Consumer<PredictionProvider>(
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
                    'Error al cargar detalle de predicción',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(predictionProvider.error!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadPredictionDetail,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          final prediction = predictionProvider.currentPrediction;
          if (prediction == null) {
            return const Center(
              child: Text('No se encontró la predicción'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPredictionHeader(prediction),
                const SizedBox(height: 24),
                _buildFactorSection(prediction),
                const SizedBox(height: 24),
                _buildRecommendationsSection(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPredictionHeader(Prediction prediction) {
    final nivelColor = prediction.getRendimientoColor();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              nivelColor.withOpacity(0.7),
              nivelColor.withOpacity(0.3),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Predicción #${prediction.id}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    DateFormat('dd/MM/yyyy').format(prediction.fechaPrediccion),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: SizedBox(
                    width: 80,
                    height: 80,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: prediction.valorNumerico / 100,
                          backgroundColor: Colors.grey.withOpacity(0.2),
                          valueColor: AlwaysStoppedAnimation<Color>(nivelColor),
                          strokeWidth: 8,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${prediction.valorNumerico.toStringAsFixed(1)}%',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: nivelColor,
                              ),
                            ),
                            Text(
                              prediction.nivelRendimiento,
                              style: TextStyle(
                                fontSize: 12,
                                color: nivelColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.psychology, color: Colors.white70),
                const SizedBox(width: 8),
                Text(
                  'Confianza: ${prediction.confianza}%',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFactorSection(Prediction prediction) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Factores de Rendimiento',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildFactorIndicator(
              'Rendimiento Académico',
              prediction.promedioNotas,
              Icons.school,
              Colors.blue,
            ),
            const SizedBox(height: 16),
            _buildFactorIndicator(
              'Asistencia a Clases',
              prediction.porcentajeAsistencia,
              Icons.calendar_today,
              Colors.green,
            ),
            const SizedBox(height: 16),
            _buildFactorIndicator(
              'Participación en Clase',
              prediction.promedioParticipaciones * 10, // Convertir a escala de 100
              Icons.record_voice_over,
              Colors.orange,
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Estudiante ID:',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                Text('${prediction.estudiante}'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Materia ID:',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                Text('${prediction.materia}'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFactorIndicator(String title, double value, IconData icon, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            const Spacer(),
            Text(
              '${value.toStringAsFixed(1)}%',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: value / 100,
          backgroundColor: Colors.grey.shade200,
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  Widget _buildRecommendationsSection() {
    return Consumer<PredictionProvider>(
      builder: (ctx, predictionProvider, _) {
        final recommendations = predictionProvider.recommendations;

        if (recommendations.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'No hay recomendaciones disponibles para esta predicción',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb, color: Colors.amber),
                  const SizedBox(width: 8),
                  Text(
                    'Recomendaciones',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ...recommendations.map((recommendation) => _buildRecommendationCard(recommendation)),
          ],
        );
      },
    );
  }

  Widget _buildRecommendationCard(PredictionRecommendation recommendation) {
    final color = recommendation.getTipoColor();
    final icon = recommendation.getTipoIcon();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withOpacity(0.3), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    recommendation.titulo,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getPriorityColor(recommendation.prioridad).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _getPriorityColor(recommendation.prioridad),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    _getPriorityText(recommendation.prioridad),
                    style: TextStyle(
                      fontSize: 12,
                      color: _getPriorityColor(recommendation.prioridad),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              recommendation.descripcion,
              style: const TextStyle(fontSize: 14, height: 1.4),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.bottomRight,
              child: Chip(
                label: Text(
                  recommendation.tipo,
                  style: TextStyle(
                    fontSize: 12,
                    color: color,
                  ),
                ),
                backgroundColor: color.withOpacity(0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getPriorityText(int priority) {
    switch (priority) {
      case 1:
        return 'ALTA';
      case 2:
        return 'MEDIA-ALTA';
      case 3:
        return 'MEDIA';
      case 4:
        return 'MEDIA-BAJA';
      case 5:
        return 'BAJA';
      default:
        return 'DESCONOCIDA';
    }
  }

  Color _getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return Colors.red;
      case 2:
        return Colors.deepOrange;
      case 3:
        return Colors.amber;
      case 4:
        return Colors.lightGreen;
      case 5:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
