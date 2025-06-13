import 'package:flutter/foundation.dart';
import '../api/participation_service.dart';
import '../models/participation.dart';

class ParticipationProvider extends ChangeNotifier {
  final ParticipationService _participationService;

  List<Participation> _participations = [];
  bool _isLoading = false;
  String? _error;

  ParticipationProvider(this._participationService);

  List<Participation> get participations => _participations;
  bool get isLoading => _isLoading;
  String? get error => _error;
  ParticipationService get participationService => _participationService;

  Future<void> loadParticipations({
    int? estudianteId,
    int? materiaId,
    DateTime? fechaInicio,
    DateTime? fechaFin,
    String? tipo,
    int? cursoId,
    DateTime? fecha,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _participations = await _participationService.getParticipations(
        estudianteId: estudianteId,
        materiaId: materiaId,
        fechaInicio: fechaInicio,
        fechaFin: fechaFin,
        tipo: tipo,
        cursoId: cursoId,
        fecha: fecha,
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<ParticipationStatistics?> getStatistics({
    int? estudianteId,
    int? materiaId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final stats = await _participationService.getParticipationStatistics(
        estudianteId: estudianteId,
        materiaId: materiaId,
      );
      _isLoading = false;
      notifyListeners();
      return stats;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<bool> createParticipation(Participation participation) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newParticipation = await _participationService.createParticipation(participation);
      _participations.add(newParticipation);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateParticipation(Participation participation) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedParticipation = await _participationService.updateParticipation(participation);
      final index = _participations.indexWhere((p) => p.id == participation.id);
      if (index != -1) {
        _participations[index] = updatedParticipation;
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteParticipation(int participationId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _participationService.deleteParticipation(participationId);
      _participations.removeWhere((p) => p.id == participationId);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
