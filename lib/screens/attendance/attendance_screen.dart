import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../models/attendance.dart';
import '../../providers/auth_provider.dart';
import '../../providers/attendance_provider.dart';
import 'attendance_form_dialog.dart';

class AttendanceScreen extends StatefulWidget {
  static const String routeName = '/attendance';

  const AttendanceScreen({Key? key}) : super(key: key);

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> with TickerProviderStateMixin {
  int? _selectedMateriaId;
  DateTime? _startDate;
  DateTime? _endDate;
  bool? _presenteFilter;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Cargamos los datos al iniciar la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAttendances();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAttendances() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final attendanceProvider = Provider.of<AttendanceProvider>(context, listen: false);

    final user = authProvider.currentUser;

    if (user != null) {
      if (user.role == 'ESTUDIANTE') {
        // Si es estudiante, solo verá sus propias asistencias
        await attendanceProvider.loadAttendances(
          estudianteId: user.id,
          materiaId: _selectedMateriaId,
          fechaInicio: _startDate,
          fechaFin: _endDate,
          presente: _presenteFilter,
        );
      } else {
        // Si es profesor o administrativo, puede filtrar por curso o materia
        await attendanceProvider.loadAttendances(
          materiaId: _selectedMateriaId,
          fechaInicio: _startDate,
          fechaFin: _endDate,
          presente: _presenteFilter,
        );
      }
    }
  }

  Future<void> _showFilterDialog() async {
    DateTime? tempStartDate = _startDate;
    DateTime? tempEndDate = _endDate;
    bool? tempPresente = _presenteFilter;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: const Text('Filtrar Asistencias'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Filtro por fecha de inicio
                ListTile(
                  title: Text(tempStartDate == null
                    ? 'Fecha de inicio: No seleccionada'
                    : 'Fecha de inicio: ${DateFormat('dd/MM/yyyy').format(tempStartDate!)}'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: tempStartDate ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (date != null) {
                      setStateDialog(() {
                        tempStartDate = date;
                      });
                    }
                  },
                ),

                // Filtro por fecha de fin
                ListTile(
                  title: Text(tempEndDate == null
                    ? 'Fecha de fin: No seleccionada'
                    : 'Fecha de fin: ${DateFormat('dd/MM/yyyy').format(tempEndDate!)}'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: tempEndDate ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (date != null) {
                      setStateDialog(() {
                        tempEndDate = date;
                      });
                    }
                  },
                ),

                // Filtro por asistencia (presente/ausente)
                DropdownButtonFormField<bool?>(
                  value: tempPresente,
                  decoration: const InputDecoration(
                    labelText: 'Estado de Asistencia',
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: null,
                      child: Text('Todos'),
                    ),
                    DropdownMenuItem(
                      value: true,
                      child: Text('Presente'),
                    ),
                    DropdownMenuItem(
                      value: false,
                      child: Text('Ausente'),
                    ),
                  ],
                  onChanged: (value) {
                    setStateDialog(() {
                      tempPresente = value;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
            TextButton(
              child: const Text('Limpiar'),
              onPressed: () {
                setStateDialog(() {
                  tempStartDate = null;
                  tempEndDate = null;
                  tempPresente = null;
                });
              },
            ),
            TextButton(
              child: const Text('Aplicar'),
              onPressed: () {
                setState(() {
                  _startDate = tempStartDate;
                  _endDate = tempEndDate;
                  _presenteFilter = tempPresente;
                });
                Navigator.of(ctx).pop();
                _loadAttendances();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddAttendanceDialog() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.currentUser?.role != 'PROFESOR' && authProvider.currentUser?.role != 'ADMINISTRATIVO') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Solo los profesores pueden registrar asistencias')),
      );
      return;
    }

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => const AttendanceFormDialog(),
    );

    if (result == true) {
      _loadAttendances();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Asistencias'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Listado'),
            Tab(text: 'Estadísticas'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab de listado de asistencias
          _buildAttendancesList(),

          // Tab de estadísticas
          _buildStatisticsTab(),
        ],
      ),
      floatingActionButton: Consumer<AuthProvider>(
        builder: (ctx, authProvider, _) {
          // Solo mostrar el botón si es profesor o administrativo
          if (authProvider.currentUser?.role == 'PROFESOR' || authProvider.currentUser?.role == 'ADMINISTRATIVO') {
            return FloatingActionButton(
              onPressed: _showAddAttendanceDialog,
              child: const Icon(Icons.add),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildAttendancesList() {
    return Consumer<AttendanceProvider>(
      builder: (ctx, attendanceProvider, _) {
        if (attendanceProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (attendanceProvider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 60, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Error al cargar asistencias',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(attendanceProvider.error!),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadAttendances,
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          );
        }

        final attendances = attendanceProvider.attendances;

        if (attendances.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.calendar_today_outlined, size: 60, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  'No hay asistencias registradas',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadAttendances,
                  child: const Text('Actualizar'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _loadAttendances,
          child: ListView.builder(
            itemCount: attendances.length,
            itemBuilder: (context, index) {
              final attendance = attendances[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: attendance.presente ? Colors.green : Colors.red,
                    child: Icon(
                      attendance.presente ? Icons.check : Icons.close,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(attendance.presente ? 'Presente' : 'Ausente'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Fecha: ${DateFormat('dd/MM/yyyy').format(attendance.fecha)}'),
                      if (attendance.justificacion != null && attendance.justificacion!.isNotEmpty)
                        Text('Justificación: ${attendance.justificacion}'),
                    ],
                  ),
                  trailing: Consumer<AuthProvider>(
                    builder: (ctx, authProvider, _) {
                      if (authProvider.currentUser?.role == 'PROFESOR' || authProvider.currentUser?.role == 'ADMINISTRATIVO') {
                        return IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Eliminar asistencia'),
                                content: const Text('¿Está seguro de eliminar este registro de asistencia?'),
                                actions: [
                                  TextButton(
                                    child: const Text('Cancelar'),
                                    onPressed: () => Navigator.of(ctx).pop(false),
                                  ),
                                  TextButton(
                                    child: const Text('Eliminar'),
                                    onPressed: () => Navigator.of(ctx).pop(true),
                                  ),
                                ],
                              ),
                            );

                            if (confirm == true) {
                              await attendanceProvider.deleteAttendance(attendance.id);
                              _loadAttendances();
                            }
                          },
                        );
                      }
                      return const SizedBox.shrink(); // Widget vacío en lugar de null
                    },
                  ),
                  onTap: () {
                    // Mostrar detalles de la asistencia
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Detalles de Asistencia'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Estado: ${attendance.presente ? 'Presente' : 'Ausente'}'),
                            Text('Fecha: ${DateFormat('dd/MM/yyyy').format(attendance.fecha)}'),
                            if (attendance.justificacion != null && attendance.justificacion!.isNotEmpty) ...[
                              const SizedBox(height: 10),
                              const Text('Justificación:', style: TextStyle(fontWeight: FontWeight.bold)),
                              Text(attendance.justificacion!),
                            ],
                          ],
                        ),
                        actions: [
                          TextButton(
                            child: const Text('Cerrar'),
                            onPressed: () => Navigator.of(ctx).pop(),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildStatisticsTab() {
    return FutureBuilder<AttendanceStatistics?>(
      future: Provider.of<AttendanceProvider>(context, listen: false).getStatistics(
        estudianteId: Provider.of<AuthProvider>(context, listen: false).currentUser?.role == 'ESTUDIANTE'
            ? Provider.of<AuthProvider>(context, listen: false).currentUser?.id
            : null,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 60, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Error al cargar estadísticas',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(snapshot.error.toString()),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {}); // Trigger rebuild
                  },
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          );
        }

        final stats = snapshot.data;

        if (stats == null) {
          return const Center(
            child: Text('No hay estadísticas disponibles'),
          );
        }

        // Calcular el porcentaje para el gráfico circular
        final asistenciaPct = stats.porcentajeAsistencia / 100;
        final faltasPct = 1 - asistenciaPct;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Estadísticas de Asistencia',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const Divider(),
                      Text('Total de clases: ${stats.totalClases}'),
                      Text('Asistencias: ${stats.asistencias}'),
                      Text('Faltas: ${stats.faltas}'),
                      const SizedBox(height: 10),
                      LinearProgressIndicator(
                        value: asistenciaPct,
                        backgroundColor: Colors.red.shade100,
                        color: Colors.green,
                        minHeight: 10,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Porcentaje de asistencia: ${stats.porcentajeAsistencia.toStringAsFixed(2)}%',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Resumen',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Indicador de Asistencias
                          Column(
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.green.shade700, width: 3),
                                ),
                                child: Center(
                                  child: Text(
                                    '${stats.asistencias}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 24,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text('Asistencias'),
                            ],
                          ),

                          // Indicador de Faltas
                          Column(
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.red.shade700, width: 3),
                                ),
                                child: Center(
                                  child: Text(
                                    '${stats.faltas}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 24,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text('Faltas'),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
