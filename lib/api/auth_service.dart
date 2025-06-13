import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_client.dart';

/// Servicio para manejar la autenticación de usuarios
///
/// Se encarga del login, registro, cierre de sesión y verificación
/// del estado de autenticación del usuario.
class AuthService {
  final ApiClient _apiClient;
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  /// Constructor que recibe una instancia de ApiClient
  AuthService(this._apiClient);

  /// Getter para acceder al ApiClient desde otras clases
  ApiClient get apiClient => _apiClient;

  /// Realiza el inicio de sesión del usuario
  ///
  /// Retorna true si el login fue exitoso, false en caso contrario
  Future<bool> login(String username, String password) async {
    try {
      final response = await _apiClient.post('usuarios/login/', data: {
        'username': username,
        'password': password,
      });

      if (response.statusCode == 200) {
        // Guardar tokens de autenticación
        await _secureStorage.write(
          key: 'access_token',
          value: response.data['access'],
        );
        await _secureStorage.write(
          key: 'refresh_token',
          value: response.data['refresh'],
        );

        // Guardar información del usuario
        await _secureStorage.write(
          key: 'user_data',
          value: jsonEncode(response.data['user']),
        );
        return true;
      }
      return false;
    } catch (e) {
      print('Error en login: $e');
      return false;
    }
  }

  /// Registra un nuevo usuario en el sistema
  ///
  /// Los campos requeridos dependen del rol del usuario
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
    try {
      final Map<String, dynamic> data = {
        'username': username,
        'email': email,
        'first_name': firstName,
        'last_name': lastName,
        'role': role,
        'password': password,
        'password2': password2,
      };

      // El curso solo es requerido para estudiantes
      if (role == 'ESTUDIANTE' && courseId != null) {
        data['curso'] = courseId;
      }

      final response = await _apiClient.post('usuarios/registro/', data: data);

      return response.statusCode == 201;
    } catch (e) {
      print('Error en registro: $e');
      return false;
    }
  }

  /// Cierra la sesión del usuario actual
  ///
  /// Elimina todos los datos almacenados localmente
  Future<void> logout() async {
    await _secureStorage.deleteAll();
  }

  /// Verifica si el usuario está autenticado
  ///
  /// Retorna true si hay un token de acceso almacenado
  Future<bool> isLoggedIn() async {
    final token = await _secureStorage.read(key: 'access_token');
    return token != null;
  }

  /// Obtiene los datos del usuario actual
  ///
  /// Retorna null si no hay datos del usuario
  Future<Map<String, dynamic>?> getCurrentUser() async {
    final userData = await _secureStorage.read(key: 'user_data');
    if (userData != null) {
      return jsonDecode(userData);
    }
    return null;
  }

  /// Obtiene el perfil detallado del usuario actual desde el backend
  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final response = await _apiClient.get('usuarios/perfil/');
      if (response.statusCode == 200) {
        return response.data;
      }
      return null;
    } catch (e) {
      print('Error al obtener perfil: $e');
      return null;
    }
  }

  /// Actualiza el perfil del usuario actual
  Future<bool> updateProfile(Map<String, dynamic> userData) async {
    try {
      final response = await _apiClient.put('usuarios/perfil/', data: userData);
      return response.statusCode == 200;
    } catch (e) {
      print('Error al actualizar perfil: $e');
      return false;
    }
  }
}
