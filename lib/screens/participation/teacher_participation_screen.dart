
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/subject_provider.dart';
import '../../providers/participation_provider.dart';
import '../../models/subject.dart';


class TeacherParticipationScreen extends StatefulWidget {
  static const routeName = '/teacher-participation';

  const TeacherParticipationScreen({Key? key}) : super(key: key);

  @override
  State<TeacherParticipationScreen> createState() => _TeacherParticipationScreenState();
}

class _TeacherParticipationScreenState extends State<TeacherParticipationScreen> {
  int? _selectedCourseId;
  bool _isLoading = false;
  List<dynamic> _participations = [];
  bool _hasMorePages = false;
  String? _nextPageUrl;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
    });

    // Cargar la materia del profesor
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final subjectProvider = Provider.of<SubjectProvider>(context, listen: false);

    await subjectProvider.loadTeacherSubject(authProvider.currentUser!.id);

    setState(() {
      _isLoading = false;
    });
  }

  // Esta función carga las participaciones desde la API
  Future<void> _loadParticipationsForCourse() async {
    if (_selectedCourseId == null) return;

    setState(() {
      _isLoading = true;
    });

    final subjectProvider = Provider.of<SubjectProvider>(context, listen: false);
    final materiaId = subjectProvider.teacherSubject?.id;

    if (materiaId == null) {
      setState(() {
        _isLoading = false;
        _participations = [];
      });
      return;
    }

    try {
      // Realizar la petición a la API con los parámetros adecuados
      final response = await Provider.of<ParticipationProvider>(context, listen: false)
          .participationService.apiClient.get(
            'participaciones/',
            queryParameters: {
              'materia': materiaId,
              'curso': _selectedCourseId
            }
          );

      // Actualizar el estado con los datos recibidos
      setState(() {
        _isLoading = false;
        if (response.data != null && response.data['results'] != null) {
          _participations = response.data['results'];
          _hasMorePages = response.data['next'] != null;
          _nextPageUrl = response.data['next'];
        } else {
          _participations = [];
          _hasMorePages = false;
          _nextPageUrl = null;
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _participations = [];
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar participaciones: $e')),
      );
    }
  }

  Future<void> _loadMoreParticipations() async {
    if (_nextPageUrl == null || _isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Extraer la URL completa y hacer la petición
      final response = await Provider.of<ParticipationProvider>(context, listen: false)
          .participationService.apiClient.getFullUrl(_nextPageUrl!);

      setState(() {
        _isLoading = false;
        if (response.data != null && response.data['results'] != null) {
          _participations.addAll(response.data['results']);
          _hasMorePages = response.data['next'] != null;
          _nextPageUrl = response.data['next'];
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar más participaciones: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Participaciones'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildBody(),
    );
  }

  Widget _buildBody() {
    final subjectProvider = Provider.of<SubjectProvider>(context);

    if (subjectProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (subjectProvider.error != null) {
      return Center(child: Text('Error: ${subjectProvider.error}'));
    }

    if (subjectProvider.teacherSubject == null) {
      return const Center(
        child: Text('No tienes una materia asignada como profesor.'),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSubjectInfo(subjectProvider.teacherSubject!),
          const SizedBox(height: 20),
          _buildCourseSelector(),
          const SizedBox(height: 20),
          if (_selectedCourseId != null)
            _buildParticipationsList(),
        ],
      ),
    );
  }

  Widget _buildSubjectInfo(Subject subject) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Materia: ${subject.nombre}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Código: ${subject.codigo}'),
            const SizedBox(height: 4),
            Text('Créditos: ${subject.creditos}'),
            const SizedBox(height: 4),
            Text('Descripción: ${subject.descripcion}'),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseSelector() {
    // Todos los cursos disponibles en el sistema
    final allCourses = [
      {'id': 1, 'nombre': '1ro Primaria', 'nivel': 'PRIMARIA', 'materias': [11, 12, 13, 14, 15]},
      {'id': 2, 'nombre': '2do Primaria', 'nivel': 'PRIMARIA', 'materias': [11, 12, 13, 14, 15]},
      {'id': 3, 'nombre': '3ro Primaria', 'nivel': 'PRIMARIA', 'materias': [11, 12, 13, 14, 15]},
      {'id': 4, 'nombre': '4to Primaria', 'nivel': 'PRIMARIA', 'materias': [11, 12, 13, 14, 15]},
      {'id': 5, 'nombre': '5to Primaria', 'nivel': 'PRIMARIA', 'materias': [11, 12, 13, 14, 15]},
      {'id': 6, 'nombre': '6to Primaria', 'nivel': 'PRIMARIA', 'materias': [11, 12, 13, 14, 15]},
      {'id': 7, 'nombre': '1ro Secundaria', 'nivel': 'SECUNDARIA', 'materias': [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]},
      {'id': 8, 'nombre': '2do Secundaria', 'nivel': 'SECUNDARIA', 'materias': [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]},
      {'id': 9, 'nombre': '3ro Secundaria', 'nivel': 'SECUNDARIA', 'materias': [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]},
      {'id': 10, 'nombre': '4to Secundaria', 'nivel': 'SECUNDARIA', 'materias': [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]},
      {'id': 11, 'nombre': '5to Secundaria', 'nivel': 'SECUNDARIA', 'materias': [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]},
      {'id': 12, 'nombre': '6to Secundaria', 'nivel': 'SECUNDARIA', 'materias': [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]},
    ];

    // Obtener la materia del profesor
    final subjectProvider = Provider.of<SubjectProvider>(context);
    final Subject? teacherSubject = subjectProvider.teacherSubject;

    if (teacherSubject == null) {
      return const Card(
        elevation: 2,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('No hay materia asignada para filtrar cursos'),
        ),
      );
    }

    // Filtrar los cursos para mostrar solo aquellos donde se imparte la materia del profesor
    final filteredCourses = allCourses.where((course) {
      final List<dynamic> materias = course['materias'] as List<dynamic>;
      return materias.contains(teacherSubject.id);
    }).toList();

    if (filteredCourses.isEmpty) {
      return const Card(
        elevation: 2,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('No hay cursos asignados a tu materia'),
        ),
      );
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: DropdownButtonFormField<int>(
          decoration: const InputDecoration(
            labelText: 'Curso',
            border: InputBorder.none,
          ),
          value: _selectedCourseId,
          items: filteredCourses.map((course) {
            return DropdownMenuItem<int>(
              value: course['id'] as int,
              child: Text('${course['nombre']} (${course['nivel']})'),
            );
          }).toList(),
          onChanged: (courseId) {
            setState(() {
              _selectedCourseId = courseId;
            });
            _loadParticipationsForCourse();
          },
        ),
      ),
    );
  }

  Widget _buildParticipationsList() {
    if (_isLoading) {
      return const Expanded(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_participations.isEmpty) {
      return const Expanded(
        child: Center(child: Text('No hay participaciones registradas para este curso')),
      );
    }

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Participaciones registradas',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: _participations.length + (_hasMorePages ? 1 : 0),
              itemBuilder: (context, index) {
                // Si estamos en el último elemento y hay más páginas, mostrar botón de cargar más
                if (index == _participations.length && _hasMorePages) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: ElevatedButton(
                        onPressed: _loadMoreParticipations,
                        child: const Text('Cargar más participaciones'),
                      ),
                    ),
                  );
                }

                // Si es un elemento normal, mostrar datos de participación
                final participation = _participations[index];
                final estudianteDetail = participation['estudiante_detail'];
                final nombre = estudianteDetail != null
                    ? "${estudianteDetail['first_name']} ${estudianteDetail['last_name']}"
                    : "Estudiante ID: ${participation['estudiante']}";

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  child: ListTile(
                    title: Text(nombre),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Fecha: ${participation['fecha']}'),
                        Text('Tipo: ${participation['tipo']}'),
                        Text('Descripción: ${participation['descripcion']}'),
                      ],
                    ),
                    trailing: Chip(
                      label: Text('${participation['valor']}/10'),
                      backgroundColor: _getColorForValoracion(participation['valor']),
                    ),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Color _getColorForValoracion(int valor) {
    if (valor >= 9) {
      return Colors.green.shade100;
    } else if (valor >= 7) {
      return Colors.lightGreen.shade100;
    } else if (valor >= 6) {
      return Colors.blue.shade100;
    } else if (valor >= 5) {
      return Colors.amber.shade100;
    } else {
      return Colors.red.shade100;
    }
  }
}
