
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/user.dart';
import '../../providers/auth_provider.dart';
import '../participation/teacher_participation_screen.dart';
import '../attendance/teacher_attendance_screen.dart';
import '../attendance/attendance_screen.dart';
import '../predictions/predictions_screen.dart';
import '../dashboard/general_dashboard_screen.dart';
import '../dashboard/student_dashboard_screen.dart';
import '../dashboard/comparison_dashboard_screen.dart';
import '../grades/teacher_grades_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final User? currentUser = authProvider.currentUser;

    if (currentUser == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Determinar qué opciones están disponibles según el rol del usuario
    final bool isStudent = currentUser.role == 'ESTUDIANTE';
    final bool isTeacher = currentUser.role == 'PROFESOR';
    final bool isAdmin = currentUser.role == 'ADMINISTRATIVO';

    // Construir la lista de páginas basada en el rol del usuario
    final List<Widget> pages = [
      // Dashboard - El primero depende del rol
      currentUser.role == 'ESTUDIANTE'
          ? const StudentDashboardScreen()
          : currentUser.role == 'PROFESOR'
              ? const ComparisonDashboardScreen()
              : const GeneralDashboardScreen(),
      // Si es estudiante, solo mostrar las páginas relevantes
      if (!isStudent && !isTeacher) const AttendanceScreen(),
      if (!isStudent) const PredictionsScreen(),
      const _ProfilePage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Aula Inteligente'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // Navegación a la pantalla de notificaciones (a implementar)
            },
            tooltip: 'Notificaciones',
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.blue,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 40,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    currentUser.fullName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    currentUser.role,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              onTap: () {
                setState(() {
                  _selectedIndex = 0;
                });
                Navigator.pop(context);
              },
            ),
            if (!isStudent) ...[
              // Opciones específicas para profesores
              if (isTeacher) ...[
                ListTile(
                  leading: const Icon(Icons.assignment),
                  title: const Text('Mis Notas'),
                  onTap: () {
                    // Navegar a la pantalla de gestión de notas para profesores
                    Navigator.pop(context); // Cerrar el drawer primero
                    Navigator.pushNamed(context, TeacherGradesScreen.routeName);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.question_answer),
                  title: const Text('Mis Participaciones'),
                  onTap: () {
                    // Navegar a la pantalla de participaciones para profesores
                    Navigator.pop(context); // Cerrar el drawer primero
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TeacherParticipationScreen(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: const Text('Mis Asistencias'),
                  onTap: () {
                    // Navegar a la pantalla de asistencias para profesores
                    Navigator.pop(context); // Cerrar el drawer primero
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TeacherAttendanceScreen(),
                      ),
                    );
                  },
                ),
              ],
              // Opciones para administradores
              if (!isTeacher) ...[
                ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: const Text('Asistencias'),
                  onTap: () {
                    setState(() {
                      _selectedIndex = 1; // Ajustar índice
                    });
                    Navigator.pop(context);
                  },
                ),
              ],
              ListTile(
                leading: const Icon(Icons.psychology),
                title: const Text('Predicciones'),
                onTap: () {
                  setState(() {
                    _selectedIndex = isTeacher ? 1 : 2; // Ajustar índice
                  });
                  Navigator.pop(context);
                },
              ),
            ],
            const Divider(),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Perfil'),
              onTap: () {
                setState(() {
                  _selectedIndex = isStudent ? 1 : (isTeacher ? 2 : 3); // Ajustar índice
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Cerrar Sesión'),
              onTap: () {
                authProvider.logout();
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            // Para estudiantes, mapear los índices 0 y 1 a dashboard y perfil
            if (isStudent) {
              _selectedIndex = index == 0 ? 0 : 1;
            } else if (isTeacher) {
              // Para profesores, solo dashboard, predicciones y perfil
              _selectedIndex = index;
            } else {
              _selectedIndex = index;
            }
          });
        },
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          if (!isStudent && !isTeacher)
            const BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today),
              label: 'Asistencia',
            ),
          if (!isStudent)
            const BottomNavigationBarItem(
              icon: Icon(Icons.psychology),
              label: 'Predicciones',
            ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}

class _ProfilePage extends StatelessWidget {
  const _ProfilePage();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 60,
              backgroundColor: Colors.blue,
              child: Icon(
                Icons.person,
                size: 80,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              user.fullName,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              user.email,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Rol: ${user.role}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (user.isStudent && user.courseId != null)
              Text(
                'Curso ID: ${user.courseId}',
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                // Aquí iría la lógica para editar el perfil
              },
              child: const Text('Editar Perfil'),
            ),
          ],
        ),
      ),
    );
  }
}
