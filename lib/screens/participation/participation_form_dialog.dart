import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../models/participation.dart';
import '../../providers/participation_provider.dart';

class ParticipationFormDialog extends StatefulWidget {
  final Participation? participation;

  const ParticipationFormDialog({
    Key? key,
    this.participation,
  }) : super(key: key);

  @override
  State<ParticipationFormDialog> createState() => _ParticipationFormDialogState();
}

class _ParticipationFormDialogState extends State<ParticipationFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _estudianteController = TextEditingController();
  final _materiaController = TextEditingController();
  final _descripcionController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  String _selectedTipo = 'VOLUNTARIA';
  int _valor = 7;

  bool _isSubmitting = false;

  final List<String> _tiposParticipacion = [
    'VOLUNTARIA', 'SOLICITADA', 'DEBATE', 'PROYECTO', 'EXPOSICIÓN'
  ];

  @override
  void initState() {
    super.initState();

    // Si se está editando una participación existente, cargar sus datos
    if (widget.participation != null) {
      _estudianteController.text = widget.participation!.estudiante.toString();
      _materiaController.text = widget.participation!.materia.toString();
      _selectedDate = widget.participation!.fecha;
      _selectedTipo = widget.participation!.tipo;
      _descripcionController.text = widget.participation!.descripcion;
      _valor = widget.participation!.valor;
    }
  }

  @override
  void dispose() {
    _estudianteController.dispose();
    _materiaController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final participationProvider = Provider.of<ParticipationProvider>(
        context,
        listen: false
      );

      final participation = Participation(
        id: widget.participation?.id ?? 0, // 0 para nuevas participaciones
        estudiante: int.parse(_estudianteController.text),
        materia: int.parse(_materiaController.text),
        fecha: _selectedDate,
        tipo: _selectedTipo,
        descripcion: _descripcionController.text,
        valor: _valor,
      );

      bool success;
      if (widget.participation == null) {
        success = await participationProvider.createParticipation(participation);
      } else {
        success = await participationProvider.updateParticipation(participation);
      }

      if (success && mounted) {
        Navigator.of(context).pop(true);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(participationProvider.error ?? 'Error al guardar la participación')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.participation == null
        ? 'Registrar Participación'
        : 'Editar Participación'
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Campo para ID del estudiante
              TextFormField(
                controller: _estudianteController,
                decoration: const InputDecoration(
                  labelText: 'ID del Estudiante',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese el ID del estudiante';
                  }
                  if (int.tryParse(value) == null) {
                    return 'El ID debe ser un número';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Campo para ID de la materia
              TextFormField(
                controller: _materiaController,
                decoration: const InputDecoration(
                  labelText: 'ID de la Materia',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese el ID de la materia';
                  }
                  if (int.tryParse(value) == null) {
                    return 'El ID debe ser un número';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Campo para seleccionar la fecha
              ListTile(
                title: Text('Fecha: ${DateFormat('dd/MM/yyyy').format(_selectedDate)}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: _selectDate,
              ),
              const SizedBox(height: 16),

              // Campo para seleccionar el tipo de participación
              DropdownButtonFormField<String>(
                value: _selectedTipo,
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
                  if (value != null) {
                    setState(() {
                      _selectedTipo = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // Campo para la descripción
              TextFormField(
                controller: _descripcionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese una descripción';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Campo para el valor (1-10)
              Text('Valor: $_valor / 10'),
              Slider(
                value: _valor.toDouble(),
                min: 1,
                max: 10,
                divisions: 9,
                label: _valor.toString(),
                onChanged: (double value) {
                  setState(() {
                    _valor = value.round();
                  });
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submitForm,
          child: _isSubmitting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Text('Guardar'),
        ),
      ],
    );
  }
}
