
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/subject_provider.dart';
import '../../api/api_client.dart';
import '../../models/subject.dart';

class TeacherAttendanceScreen extends StatefulWidget {
  static const routeName = '/teacher-attendance';

  const TeacherAttendanceScreen({Key? key}) : super(key: key);

  @override
  State<TeacherAttendanceScreen> createState() => _TeacherAttendanceScreenState();
}

class _TeacherAttendanceScreenState extends State<TeacherAttendanceScreen> {
  int? _selectedCourseId;
  bool _isLoading = false;
  // Definir un mapa para almacenar los datos de asistencia
  List<Map<String, dynamic>> _attendances = [];
  // Fecha seleccionada para mostrar asistencias
  DateTime _selectedDate = DateTime.now();
  // Instancia directa del ApiClient
  final ApiClient _apiClient = ApiClient();

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

  // Esta función carga las asistencias desde la API
  Future<void> _loadAttendancesForCourse() async {
    if (_selectedCourseId == null) return;

    setState(() {
      _isLoading = true;
    });

    final subjectProvider = Provider.of<SubjectProvider>(context, listen: false);
    final materiaId = subjectProvider.teacherSubject?.id;

    if (materiaId == null) {
      setState(() {
        _isLoading = false;
        _attendances = [];
      });
      return;
    }

    try {
      // Formatear la fecha a ISO String (YYYY-MM-DD)
      final fechaFormatted = "${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}";

      // Mostrar los parámetros de la consulta para depuración
      print('Consultando asistencias con: materia=$materiaId, curso=$_selectedCourseId, fecha=$fechaFormatted');

      // Realizar la petición a la API con los parámetros adecuados
      final response = await _apiClient.get(
        'asistencias/',
        queryParameters: {
          'materia': materiaId,
          'curso': _selectedCourseId,
          'fecha': fechaFormatted
        }
      );

      // Mostrar la respuesta completa para depuración
      print('Respuesta completa: ${response.data}');

      // Actualizar el estado con los datos recibidos
      setState(() {
        _isLoading = false;
        if (response.data != null && response.data['results'] != null) {
          final List<dynamic> results = response.data['results'];
          print('Cantidad de resultados: ${results.length}');

          if (results.isEmpty) {
            _attendances = [];
            print('No se encontraron registros de asistencia para la fecha seleccionada');
          } else {
            _attendances = results.map<Map<String, dynamic>>((data) {
              return {
                'id': data['id'],
                'estudiante': data['estudiante_nombre'] ?? 'Estudiante ${data['estudiante']}',
                'fecha': data['fecha'],
                'hora_llegada': data['hora_llegada'] ?? '08:00', // Valor por defecto si no está presente
                'estado': data['presente']
                    ? 'Presente'
                    : (data['justificacion'] != null && data['justificacion'].isNotEmpty
                        ? 'Justificado' : 'Ausente'),
                'observacion': data['justificacion'] ?? '',
              };
            }).toList();
          }
        } else {
          _attendances = [];
          print('Respuesta inválida o sin datos');
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _attendances = [];
      });
      print('Error al cargar asistencias: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar asistencias: $e')),
      );
    }
  }

  // Función auxiliar para generar estados aleatorios de asistencia
  String _getRandomAttendanceStatus() {
    final statuses = ['Presente', 'Ausente', 'Justificado', 'Tardanza'];
    return statuses[(DateTime.now().millisecond % 4)];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Asistencias'),
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
          _buildDateSelector(),
          const SizedBox(height: 20),
          _buildCourseSelector(),
          const SizedBox(height: 20),
          if (_selectedCourseId != null)
            _buildAttendanceList(),
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

  Widget _buildDateSelector() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Fecha de asistencia:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                  style: const TextStyle(fontSize: 16),
                ),
                const Spacer(),
                TextButton.icon(
                  icon: const Icon(Icons.calendar_today),
                  label: const Text('Seleccionar fecha'),
                  onPressed: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime(2024),
                      lastDate: DateTime(2026),
                    );
                    if (picked != null && picked != _selectedDate) {
                      setState(() {
                        _selectedDate = picked;
                      });
                      if (_selectedCourseId != null) {
                        _loadAttendancesForCourse();
                      }
                    }
                  },
                ),
              ],
            ),
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
            _loadAttendancesForCourse();
          },
        ),
      ),
    );
  }

  Widget _buildAttendanceList() {
    if (_isLoading) {
      return const Expanded(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_attendances.isEmpty) {
      return const Expanded(
        child: Center(child: Text('No hay registros de asistencia para esta fecha')),
      );
    }

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Asistencias del ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildAttendanceTable(),
        ],
      ),
    );
  }

  Widget _buildAttendanceTable() {
    return Expanded(
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: 20,
            horizontalMargin: 12,
            headingRowColor: MaterialStateProperty.all(
              Theme.of(context).colorScheme.primary.withOpacity(0.1),
            ),
            columns: const [
              DataColumn(label: Text('Estudiante')),
              DataColumn(label: Text('Estado')),
              DataColumn(label: Text('Hora de llegada')),
              DataColumn(label: Text('Observación')),
            ],
            rows: _attendances.map<DataRow>((attendance) {
              return DataRow(
                cells: [
                  DataCell(Text(attendance['estudiante'])),
                  DataCell(
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getColorForAttendanceStatus(attendance['estado']),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        attendance['estado'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  DataCell(Text(attendance['estado'] == 'Ausente' ? '-' : attendance['hora_llegada'])),
                  DataCell(Text(attendance['observacion'] ?? '')),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Color _getColorForAttendanceStatus(String status) {
    switch (status) {
      case 'Presente':
        return Colors.green;
      case 'Ausente':
        return Colors.red;
      case 'Justificado':
        return Colors.amber;
      case 'Tardanza':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
