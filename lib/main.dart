import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'api/api_client.dart';
import 'api/auth_service.dart';
import 'api/grade_service.dart';
import 'api/participation_service.dart';
import 'api/attendance_service.dart';
import 'api/prediction_service.dart';
import 'api/dashboard_service.dart';
import 'api/subject_service.dart'; // Importar el servicio de materias
import 'api/course_service.dart'; // Importar el servicio de cursos
import 'providers/auth_provider.dart';
import 'providers/grade_provider.dart';
import 'providers/participation_provider.dart';
import 'providers/attendance_provider.dart';
import 'providers/prediction_provider.dart';
import 'providers/dashboard_provider.dart';
import 'providers/subject_provider.dart'; // Importar el provider de materias
import 'providers/course_provider.dart'; // Importar el provider de cursos
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/grades/teacher_grades_screen.dart';

void main() {
  // Asegurar que Flutter esté inicializado
  WidgetsFlutterBinding.ensureInitialized();

  // Crear instancias de servicios que serán utilizados en la aplicación
  final apiClient = ApiClient();
  final authService = AuthService(apiClient);
  final gradeService = GradeService(apiClient);
  final participationService = ParticipationService(apiClient);
  final attendanceService = AttendanceService(apiClient);
  final predictionService = PredictionService(apiClient);
  final dashboardService = DashboardService(apiClient);
  final subjectService = SubjectService(apiClient); // Crear instancia del servicio de materias
  final courseService = CourseService(apiClient); // Crear instancia del servicio de cursos

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(authService)),
        ChangeNotifierProvider(create: (_) => GradeProvider(gradeService)),
        ChangeNotifierProvider(create: (_) => ParticipationProvider(participationService)),
        ChangeNotifierProvider(create: (_) => AttendanceProvider(attendanceService)),
        ChangeNotifierProvider(create: (_) => PredictionProvider(predictionService)),
        ChangeNotifierProvider(create: (_) => DashboardProvider(dashboardService)),
        ChangeNotifierProvider(create: (_) => SubjectProvider(subjectService)),
        ChangeNotifierProvider(create: (_) => CourseProvider(courseService)), // Agregar provider de cursos
      ],
      child: const AulaInteligenteApp(),
    ),
  );
}

class AulaInteligenteApp extends StatelessWidget {
  const AulaInteligenteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aula Inteligente',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          primary: Colors.blue,
          secondary: Colors.amber,
        ),
        useMaterial3: true,
        // Personalizar otros aspectos del tema
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.blue),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.red),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
      // Definir las rutas de la aplicación
      routes: {
        '/': (context) => Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                // Mostrar indicador de carga mientras se inicializa la autenticación
                if (authProvider.isLoading) {
                  return const Scaffold(
                    body: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                // Redirigir según el estado de autenticación
                if (authProvider.isAuthenticated) {
                  return const HomeScreen();
                } else {
                  return const LoginScreen();
                }
              },
            ),
        TeacherGradesScreen.routeName: (context) => const TeacherGradesScreen(),
      },
    );
  }
}
