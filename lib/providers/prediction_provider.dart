import 'package:flutter/foundation.dart';

import '../api/prediction_service.dart';
import '../models/prediction.dart';

class PredictionProvider with ChangeNotifier {
  final PredictionService _predictionService;

  List<Prediction> _predictions = [];
  Prediction? _currentPrediction;
  List<PredictionRecommendation> _recommendations = [];
  List<StudentAtRisk> _studentsAtRisk = [];

  bool _isLoading = false;
  String? _error;

  PredictionProvider(this._predictionService);

  // Getters
  List<Prediction> get predictions => _predictions;
  Prediction? get currentPrediction => _currentPrediction;
  List<PredictionRecommendation> get recommendations => _recommendations;
  List<StudentAtRisk> get studentsAtRisk => _studentsAtRisk;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Carga las predicciones según los filtros aplicados
  Future<void> loadPredictions({
    int? estudianteId,
    int? materiaId,
    int? cursoId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _predictions = await _predictionService.getPredictions(
        estudianteId: estudianteId,
        materiaId: materiaId,
        cursoId: cursoId,
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Carga el detalle de una predicción específica
  Future<void> loadPredictionDetail(int predictionId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentPrediction = await _predictionService.getPredictionDetail(predictionId);
      // Cargar recomendaciones una vez que tenemos el detalle
      await loadRecommendations(predictionId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Genera una nueva predicción para un estudiante en una materia
  Future<Prediction?> generatePrediction(int estudianteId, int materiaId, {bool useML = false}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      Prediction prediction;

      if (useML) {
        prediction = await _predictionService.generateMLPrediction(estudianteId, materiaId);
      } else {
        prediction = await _predictionService.generatePrediction(estudianteId, materiaId);
      }

      // Agregar la nueva predicción a la lista y establecerla como actual
      _predictions.add(prediction);
      _currentPrediction = prediction;

      _isLoading = false;
      notifyListeners();
      return prediction;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  /// Carga recomendaciones para una predicción
  Future<void> loadRecommendations(int predictionId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _recommendations = await _predictionService.getRecommendations(predictionId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Carga la lista de estudiantes en riesgo académico
  Future<void> loadStudentsAtRisk({int? cursoId, int? materiaId}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _studentsAtRisk = await _predictionService.getStudentsAtRisk(
        cursoId: cursoId,
        materiaId: materiaId,
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Limpia la predicción actual y sus recomendaciones
  void clearCurrentPrediction() {
    _currentPrediction = null;
    _recommendations = [];
    notifyListeners();
  }
}
