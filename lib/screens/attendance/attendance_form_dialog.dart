import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../models/attendance.dart';
import '../../providers/attendance_provider.dart';

class AttendanceFormDialog extends StatefulWidget {
  final Attendance? attendance;

  const AttendanceFormDialog({
    Key? key,
    this.attendance,
  }) : super(key: key);

  @override
  State<AttendanceFormDialog> createState() => _AttendanceFormDialogState();
}

class _AttendanceFormDialogState extends State<AttendanceFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _estudianteController = TextEditingController();
  final _materiaController = TextEditingController();
  final _justificacionController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  bool _presente = true;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();

    // Si se está editando una asistencia existente, cargar sus datos
    if (widget.attendance != null) {
      _estudianteController.text = widget.attendance!.estudiante.toString();
      _materiaController.text = widget.attendance!.materia.toString();
      _selectedDate = widget.attendance!.fecha;
      _presente = widget.attendance!.presente;
      if (widget.attendance!.justificacion != null) {
        _justificacionController.text = widget.attendance!.justificacion!;
      }
    }
  }

  @override
  void dispose() {
    _estudianteController.dispose();
    _materiaController.dispose();
    _justificacionController.dispose();
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
      final attendanceProvider = Provider.of<AttendanceProvider>(
        context,
        listen: false
      );

      final attendance = Attendance(
        id: widget.attendance?.id ?? 0, // 0 para nuevas asistencias
        estudiante: int.parse(_estudianteController.text),
        materia: int.parse(_materiaController.text),
        fecha: _selectedDate,
        presente: _presente,
        justificacion: _presente ? null : _justificacionController.text.isNotEmpty
            ? _justificacionController.text
            : null,
      );

      bool success;
      if (widget.attendance == null) {
        success = await attendanceProvider.createAttendance(attendance);
      } else {
        success = await attendanceProvider.updateAttendance(attendance);
      }

      if (success && mounted) {
        Navigator.of(context).pop(true);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(attendanceProvider.error ?? 'Error al guardar la asistencia')),
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
      title: Text(widget.attendance == null
        ? 'Registrar Asistencia'
        : 'Editar Asistencia'
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

              // Campo para indicar si estuvo presente
              SwitchListTile(
                title: const Text('Estado de Asistencia'),
                subtitle: Text(_presente ? 'Presente' : 'Ausente'),
                value: _presente,
                onChanged: (value) {
                  setState(() {
                    _presente = value;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Campo para la justificación (solo visible si está ausente)
              if (!_presente)
                TextFormField(
                  controller: _justificacionController,
                  decoration: const InputDecoration(
                    labelText: 'Justificación (opcional)',
                  ),
                  maxLines: 3,
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
