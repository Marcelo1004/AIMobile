import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../models/participation.dart';
import '../../providers/auth_provider.dart';
import '../../providers/participation_provider.dart';
import 'participation_form_dialog.dart';

class ParticipationScreen extends StatefulWidget {
  static const String routeName = '/participations';

  const ParticipationScreen({Key? key}) : super(key: key);

  @override
  State<ParticipationScreen> createState() => _ParticipationScreenState();
}

class _ParticipationScreenState extends State<ParticipationScreen> with TickerProviderStateMixin {
  int? _selectedMateriaId;
  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedTipo;
  late TabController _tabController;

  final List<String> _tiposParticipacion = ['TODAS', 'VOLUNTARIA', 'SOLICITADA', 'DEBATE', 'PROYECTO', 'EXPOSICIÓN'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Cargamos los datos al iniciar la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadParticipations();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadParticipations() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final participationProvider = Provider.of<ParticipationProvider>(context, listen: false);

    final user = authProvider.currentUser;

    if (user != null) {
      if (user.role == 'ESTUDIANTE') {
        // Si es estudiante, solo verá sus propias participaciones
        await participationProvider.loadParticipations(
          estudianteId: user.id,
          materiaId: _selectedMateriaId,
          fechaInicio: _startDate,
          fechaFin: _endDate,
          tipo: _selectedTipo == 'TODAS' ? null : _selectedTipo,
        );
      } else {
        // Si es profesor o administrativo, puede filtrar por curso o materia
        await participationProvider.loadParticipations(
          materiaId: _selectedMateriaId,
          fechaInicio: _startDate,
          fechaFin: _endDate,
          tipo: _selectedTipo == 'TODAS' ? null : _selectedTipo,
        );
      }
    }
  }

  Future<void> _showFilterDialog() async {
    DateTime? tempStartDate = _startDate;
    DateTime? tempEndDate = _endDate;
    String? tempTipo = _selectedTipo;

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Filtrar Participaciones'),
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
                    tempStartDate = date;
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
                    tempEndDate = date;
                  }
                },
              ),

              // Filtro por tipo de participación
              DropdownButtonFormField<String>(
                value: tempTipo ?? 'TODAS',
                decoration: const InputDecoration(
                  labelText: 'Tipo de Participación',
                ),
                items: _tiposParticipacion.map((tipo) =>
                  DropdownMenuItem(
                    value: tipo,
                    child: Text(tipo),
                  )
                ).toList(),
                onChanged: (value) {
                  tempTipo = value;
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
              tempStartDate = null;
              tempEndDate = null;
              tempTipo = 'TODAS';
              Navigator.of(ctx).pop();
            },
          ),
          TextButton(
            child: const Text('Aplicar'),
            onPressed: () {
              setState(() {
                _startDate = tempStartDate;
                _endDate = tempEndDate;
                _selectedTipo = tempTipo;
              });
              Navigator.of(ctx).pop();
              _loadParticipations();
            },
          ),
        ],
      ),
    );
  }

  void _showAddParticipationDialog() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.currentUser?.role != 'PROFESOR' && authProvider.currentUser?.role != 'ADMINISTRATIVO') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Solo los profesores pueden registrar participaciones')),
      );
      return;
    }

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => const ParticipationFormDialog(),
    );

    if (result == true) {
      _loadParticipations();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Participaciones'),
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
          // Tab de listado de participaciones
          _buildParticipationsList(),

          // Tab de estadísticas
          _buildStatisticsTab(),
        ],
      ),
      floatingActionButton: Consumer<AuthProvider>(
        builder: (ctx, authProvider, _) {
          // Solo mostrar el botón si es profesor o administrativo
          if (authProvider.currentUser?.role == 'PROFESOR' || authProvider.currentUser?.role == 'ADMINISTRATIVO') {
            return FloatingActionButton(
              onPressed: _showAddParticipationDialog,
              child: const Icon(Icons.add),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildParticipationsList() {
    return Consumer<ParticipationProvider>(
      builder: (ctx, participationProvider, _) {
        if (participationProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (participationProvider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 60, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Error al cargar participaciones',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(participationProvider.error!),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadParticipations,
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          );
        }

        final participations = participationProvider.participations;

        if (participations.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.question_answer_outlined, size: 60, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  'No hay participaciones registradas',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadParticipations,
                  child: const Text('Actualizar'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _loadParticipations,
          child: ListView.builder(
            itemCount: participations.length,
            itemBuilder: (context, index) {
              final participation = participations[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getParticipationColor(participation.tipo),
                    child: Text(
                      participation.tipo.substring(0, 1),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text('Valor: ${participation.valor}/10'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tipo: ${participation.tipo}'),
                      Text('Fecha: ${DateFormat('dd/MM/yyyy').format(participation.fecha)}'),
                      Text('Descripción: ${participation.descripcion}'),
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
                                title: const Text('Eliminar participación'),
                                content: const Text('¿Está seguro de eliminar esta participación?'),
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
                              await participationProvider.deleteParticipation(participation.id);
                              _loadParticipations();
                            }
                          },
                        );
                      }
                      return const SizedBox.shrink(); // Widget vacío en lugar de null
                    },
                  ),
                  onTap: () {
                    // Mostrar detalles de la participación
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Detalles de Participación'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Tipo: ${participation.tipo}'),
                            Text('Fecha: ${DateFormat('dd/MM/yyyy').format(participation.fecha)}'),
                            Text('Valor: ${participation.valor}/10'),
                            const SizedBox(height: 10),
                            const Text('Descripción:', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(participation.descripcion),
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
    return FutureBuilder<ParticipationStatistics?>(
      future: Provider.of<ParticipationProvider>(context, listen: false).getStatistics(
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
                        'Estadísticas Generales',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const Divider(),
                      Text('Total de participaciones: ${stats.totalParticipaciones}'),
                      Text('Promedio de valor: ${stats.promedioValor.toStringAsFixed(2)}/10'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Participaciones por Tipo',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 10),
              Card(
                child: Column(
                  children: stats.participacionesPorTipo.entries.map((entry) {
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _getParticipationColor(entry.key),
                        child: Text(
                          entry.key.substring(0, 1),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(entry.key),
                      trailing: Text(
                        '${entry.value}',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getParticipationColor(String tipo) {
    switch (tipo) {
      case 'VOLUNTARIA':
        return Colors.green;
      case 'SOLICITADA':
        return Colors.blue;
      case 'DEBATE':
        return Colors.orange;
      case 'PROYECTO':
        return Colors.purple;
      case 'EXPOSICIÓN':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }
}
