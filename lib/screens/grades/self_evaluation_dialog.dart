import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../models/grade.dart';
import '../../providers/grade_provider.dart';

class SelfEvaluationDialog extends StatefulWidget {
  final Grade grade;

  const SelfEvaluationDialog({super.key, required this.grade});

  @override
  State<SelfEvaluationDialog> createState() => _SelfEvaluationDialogState();
}

class _SelfEvaluationDialogState extends State<SelfEvaluationDialog> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isSubmitting = false;
  double _serValue = 0.0;
  double _decidirValue = 0.0;

  @override
  void initState() {
    super.initState();
    // Inicializar con valores existentes si ya hay autoevaluación
    _serValue = widget.grade.autoevaluacionSer ?? 0.0;
    _decidirValue = widget.grade.autoevaluacionDecidir ?? 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Autoevaluación'),
      content: SingleChildScrollView(
        child: FormBuilder(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Evalúa tu desempeño en los siguientes aspectos:',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 16),

              // Autoevaluación SER (0-5)
              const Text(
                'SER (valores, actitudes, comportamiento)',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 8),
              FormBuilderSlider(
                name: 'ser',
                min: 0.0,
                max: 5.0,
                initialValue: _serValue,
                divisions: 10, // Para permitir valores de 0.5
                valueTransformer: (value) => value?.toDouble(),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                ),
                displayValues: DisplayValues.current,
                numberFormat: NumberFormat('#.##'),
                onChanged: (value) {
                  setState(() {
                    _serValue = value ?? 0.0;
                  });
                },
              ),
              Text(
                _getScoreDescription(_serValue / 5),
                style: TextStyle(
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                  color: _getColorForScore(_serValue / 5),
                ),
              ),
              const SizedBox(height: 16),

              // Autoevaluación DECIDIR (0-5)
              const Text(
                'DECIDIR (aplicación práctica, toma de decisiones)',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 8),
              FormBuilderSlider(
                name: 'decidir',
                min: 0.0,
                max: 5.0,
                initialValue: _decidirValue,
                divisions: 10, // Para permitir valores de 0.5
                valueTransformer: (value) => value?.toDouble(),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                ),
                displayValues: DisplayValues.current,
                numberFormat: NumberFormat('#.##'),
                onChanged: (value) {
                  setState(() {
                    _decidirValue = value ?? 0.0;
                  });
                },
              ),
              Text(
                _getScoreDescription(_decidirValue / 5),
                style: TextStyle(
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                  color: _getColorForScore(_decidirValue / 5),
                ),
              ),
              const SizedBox(height: 16),

              // Texto de ayuda
              const Text(
                'Tu autoevaluación es muy importante para el proceso de formación. Por favor, realízala de manera honesta.',
                style: TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        _isSubmitting
            ? const CircularProgressIndicator()
            : TextButton(
                onPressed: () => _submitSelfEvaluation(context),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Theme.of(context).primaryColor,
                ),
                child: const Text('Enviar Autoevaluación'),
              ),
      ],
    );
  }

  Future<void> _submitSelfEvaluation(BuildContext context) async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      setState(() {
        _isSubmitting = true;
      });

      try {
        final gradeProvider = Provider.of<GradeProvider>(context, listen: false);

        if (widget.grade.id != null) {
          final success = await gradeProvider.submitSelfEvaluation(
            widget.grade.id!,
            _serValue,
            _decidirValue,
          );

          if (success) {
            if (mounted) {
              Navigator.of(context).pop(true); // Enviar resultado positivo
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Autoevaluación enviada correctamente'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('No se pudo enviar la autoevaluación'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al enviar la autoevaluación: $e'),
              backgroundColor: Colors.red,
            ),
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
  }

  String _getScoreDescription(double percentage) {
    if (percentage >= 0.8) {
      return 'Excelente';
    } else if (percentage >= 0.6) {
      return 'Bueno';
    } else if (percentage >= 0.4) {
      return 'Regular';
    } else if (percentage >= 0.2) {
      return 'Necesita mejorar';
    } else {
      return 'Insuficiente';
    }
  }

  Color _getColorForScore(double percentage) {
    if (percentage >= 0.8) {
      return Colors.green;
    } else if (percentage >= 0.6) {
      return Colors.lightGreen;
    } else if (percentage >= 0.4) {
      return Colors.amber;
    } else if (percentage >= 0.2) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}
