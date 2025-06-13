import '../api/api_client.dart';
import '../models/prediction.dart';

/// Servicio para gestionar las predicciones académicas
class PredictionService {
  final ApiClient _apiClient;

  PredictionService(this._apiClient);

  /// Obtiene las predicciones del usuario actual
  ///
  /// Para estudiantes, solo sus propias predicciones
  /// Para profesores, predicciones de sus materias
  /// Para administrativos, todas las predicciones
  Future<List<Prediction>> getPredictions({
    int? estudianteId,
    int? materiaId,
    int? cursoId,
  }) async {
    try {
      Map<String, dynamic>? queryParams;

      if (estudianteId != null || materiaId != null || cursoId != null) {
        queryParams = {};
        if (estudianteId != null) queryParams['estudiante'] = estudianteId;
        if (materiaId != null) queryParams['materia'] = materiaId;
        if (cursoId != null) queryParams['curso'] = cursoId;
      }

      final response = await _apiClient.get(
        'predicciones/',
        queryParameters: queryParams
      );

      final List<dynamic> predictionsData = response.data;
      return predictionsData
          .map((json) => Prediction.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener predicciones: $e');
    }
  }

  /// Obtiene el detalle de una predicción específica
  Future<Prediction> getPredictionDetail(int predictionId) async {
    try {
      final response = await _apiClient.get('predicciones/$predictionId/');
      return Prediction.fromJson(response.data);
    } catch (e) {
      throw Exception('Error al obtener detalle de predicción: $e');
    }
  }

  /// Genera una nueva predicción utilizando el algoritmo estándar
  Future<Prediction> generatePrediction(int estudianteId, int materiaId) async {
    try {
      final response = await _apiClient.post('predicciones/generar_prediccion/', data: {
        'estudiante': estudianteId,
        'materia': materiaId,
      });
      return Prediction.fromJson(response.data);
    } catch (e) {
      throw Exception('Error al generar predicción: $e');
    }
  }

  /// Genera una nueva predicción utilizando el algoritmo avanzado de machine learning
  Future<Prediction> generateMLPrediction(int estudianteId, int materiaId) async {
    try {
      final response = await _apiClient.post('predicciones/generar_prediccion_ml/', data: {
        'estudiante': estudianteId,
        'materia': materiaId,
      });
      return Prediction.fromJson(response.data);
    } catch (e) {
      throw Exception('Error al generar predicción con ML: $e');
    }
  }

  /// Obtiene las recomendaciones basadas en una predicción específica
  Future<List<PredictionRecommendation>> getRecommendations(int predictionId) async {
    try {
      final response = await _apiClient.get('predicciones/$predictionId/recomendaciones/');

      // Imprimir la respuesta para depuración
      print('Respuesta de recomendaciones: ${response.data}');

      // Verificar si la respuesta contiene directamente 'recomendaciones'
      List<dynamic>? recommendationsData;

      if (response.data is Map && response.data['recomendaciones'] != null) {
        recommendationsData = response.data['recomendaciones'] as List<dynamic>;
      } else if (response.data is Map && response.data.containsKey('categoria') && response.data.containsKey('mensaje')) {
        // Si la respuesta es un solo objeto, lo convertimos en lista
        recommendationsData = [response.data];
      } else if (response.data is List) {
        // Si la respuesta ya es una lista
        recommendationsData = response.data;
      } else {
        // Caso específico para el formato observado en los logs
        final recommendations = <Map<String, dynamic>>[];
        if (response.data is Map) {
          // Extraer las recomendaciones del formato actual
          final data = response.data as Map<String, dynamic>;
          if (data.containsKey('recomendaciones') && data['recomendaciones'] is List) {
            recommendationsData = data['recomendaciones'] as List<dynamic>;
          } else {
            // Intentar procesar el formato visto en los logs donde cada recomendación
            // tiene categoría y mensaje
            data.forEach((key, value) {
              if (key == 'prediccion_id' || key == 'estudiante' || key == 'materia' ||
                  key == 'nivel_rendimiento' || key == 'valor_numerico') {
                // Ignorar campos que no son recomendaciones
                return;
              }
              if (value is List) {
                for (var item in value) {
                  if (item is Map<String, dynamic>) {
                    recommendations.add(item);
                  }
                }
              }
            });

            if (data.containsKey('recomendaciones') && data['recomendaciones'] is List) {
              final recomList = data['recomendaciones'] as List;
              for (var item in recomList) {
                if (item is Map<String, dynamic>) {
                  recommendations.add({
                    'titulo': item['categoria'] ?? 'Sin título',
                    'descripcion': item['mensaje'] ?? '',
                    'tipo': item['categoria'] ?? 'GENERAL',
                    'prioridad': 3, // Prioridad media por defecto
                  });
                }
              }
            }

            return recommendations.map((json) => PredictionRecommendation.fromJson(json)).toList();
          }
        }
      }

      if (recommendationsData == null || recommendationsData.isEmpty) {
        return [];
      }

      // Convertir cada ítem al formato esperado por PredictionRecommendation
      return recommendationsData.map((item) {
        // Asegurar que tengamos los campos necesarios con valores por defecto
        final Map<String, dynamic> formattedItem = {
          'titulo': item['categoria'] ?? item['titulo'] ?? 'Sin título',
          'descripcion': item['mensaje'] ?? item['descripcion'] ?? '',
          'tipo': item['categoria'] ?? 'GENERAL',
          'prioridad': item['prioridad'] ?? 3, // Prioridad media por defecto
        };

        return PredictionRecommendation.fromJson(formattedItem);
      }).toList();
    } catch (e) {
      print('Error detallado al obtener recomendaciones: $e');
      throw Exception('Error al obtener recomendaciones: $e');
    }
  }

  /// Obtiene la lista de estudiantes en riesgo académico
  Future<List<StudentAtRisk>> getStudentsAtRisk({
    int? cursoId,
    int? materiaId,
  }) async {
    try {
      Map<String, dynamic>? queryParams;

      if (cursoId != null || materiaId != null) {
        queryParams = {};
        if (cursoId != null) queryParams['curso'] = cursoId;
        if (materiaId != null) queryParams['materia'] = materiaId;
      }

      final response = await _apiClient.get(
        'predicciones/estudiantes_en_riesgo/',
        queryParameters: queryParams,
        options: {
          'receiveTimeout': const Duration(seconds: 30),
        },
      );

      // Verificar si la respuesta tiene la estructura esperada
      if (response.data == null) {
        print('Error: La respuesta no contiene datos');
        return [];
      }

      print('Respuesta recibida: ${response.data}');

      // Extraer la lista de estudiantes en riesgo
      if (response.data is Map<String, dynamic> && response.data.containsKey('estudiantes')) {
        final List<dynamic> studentsData = response.data['estudiantes'];
        return studentsData
            .map((json) => StudentAtRisk.fromJson(json))
            .toList();
      } else {
        print('Error: La estructura de la respuesta no es la esperada');
        return [];
      }
    } catch (e) {
      print('Error detallado al obtener estudiantes en riesgo: $e');
      throw Exception('Error al obtener estudiantes en riesgo: $e');
    }
  }

  /// Obtiene notificaciones relacionadas con predicciones
  Future<Map<String, dynamic>> getPredictionNotifications() async {
    try {
      final response = await _apiClient.get('predicciones/notificaciones/');
      return response.data;
    } catch (e) {
      throw Exception('Error al obtener notificaciones de predicciones: $e');
    }
  }
}
