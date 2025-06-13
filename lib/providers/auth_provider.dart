import 'package:flutter/foundation.dart';
import '../api/auth_service.dart';
import '../api/api_client.dart';
import '../models/user.dart';

/// Provider que maneja el estado de autenticación de la aplicación
///
/// Mantiene información sobre el usuario actual y proporciona
/// métodos para iniciar sesión, registrarse y cerrar sesión.
class AuthProvider with ChangeNotifier {
  final AuthService _authService;
  User? _currentUser;
  bool _loading = false;
  String? _error;

  /// Constructor que recibe una instancia de AuthService
  AuthProvider(this._authService) {
    _initializeAuth();
  }

  /// Inicializa el estado de autenticación al inicio de la aplicación
  Future<void> _initializeAuth() async {
    _loading = true;
    notifyListeners();

    try {
      // Verificar si hay un token guardado
      final isLoggedIn = await _authService.isLoggedIn();

      if (isLoggedIn) {
        // Obtener datos del usuario
        final userData = await _authService.getCurrentUser();
        if (userData != null) {
          _currentUser = User.fromJson(userData);

          // Opcionalmente, puedes refrescar los datos del usuario desde el backend
          final profileData = await _authService.getUserProfile();
          if (profileData != null) {
            _currentUser = User.fromJson(profileData);
          }
        } else {
          await _authService.logout(); // Limpiar datos inválidos
        }
      }
    } catch (e) {
      _error = "Error al inicializar autenticación";
      print(_error);
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Realiza el inicio de sesión
  Future<bool> login(String username, String password) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _authService.login(username, password);

      if (success) {
        // Obtener los datos del usuario después del login exitoso
        final userData = await _authService.getCurrentUser();
        if (userData != null) {
          _currentUser = User.fromJson(userData);
        }
      } else {
        _error = "Credenciales inválidas";
      }

      return success;
    } catch (e) {
      _error = "Error durante el inicio de sesión";
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Registra un nuevo usuario
  Future<bool> register({
    required String username,
    required String email,
    required String firstName,
    required String lastName,
    required String password,
    required String password2,
    required String role,
    int? courseId,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _authService.register(
        username: username,
        email: email,
        firstName: firstName,
        lastName: lastName,
        password: password,
        password2: password2,
        role: role,
        courseId: courseId,
      );

      if (!success) {
        _error = "Error al registrar usuario";
      }

      return success;
    } catch (e) {
      _error = "Error durante el registro";
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Cierra la sesión del usuario actual
  Future<void> logout() async {
    _loading = true;
    notifyListeners();

    try {
      await _authService.logout();
      _currentUser = null;
    } catch (e) {
      _error = "Error al cerrar sesión";
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Actualiza el perfil del usuario actual
  Future<bool> updateProfile(Map<String, dynamic> userData) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _authService.updateProfile(userData);

      if (success) {
        final updatedProfile = await _authService.getUserProfile();
        if (updatedProfile != null) {
          _currentUser = User.fromJson(updatedProfile);
        }
      } else {
        _error = "No se pudo actualizar el perfil";
      }

      return success;
    } catch (e) {
      _error = "Error al actualizar perfil";
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // Getters para acceder al estado
  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _loading;
  String? get error => _error;
  ApiClient get apiClient => _authService.apiClient;
}
