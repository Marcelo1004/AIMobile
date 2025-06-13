import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

import '../../api/course_service.dart';
import '../../providers/auth_provider.dart';
import '../../models/user.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isPasswordVisible = false;
  bool _isSubmitting = false;
  String _selectedRole = 'ESTUDIANTE';
  bool _isLoadingCourses = false;
  List<Map<String, dynamic>> _courses = [];

  final List<Map<String, dynamic>> _roles = [
    {'value': 'ESTUDIANTE', 'label': 'Estudiante'},
    {'value': 'PROFESOR', 'label': 'Profesor'},
    {'value': 'ADMINISTRATIVO', 'label': 'Administrativo'},
  ];

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  /// Carga la lista de cursos desde el backend
  Future<void> _loadCourses() async {
    setState(() {
      _isLoadingCourses = true;
    });

    try {
      // Obtener instancia del AuthProvider para verificar el usuario actual
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.currentUser;

      // Verificar que el usuario sea administrador
      if (user == null || !user.isAdmin) {
        // Si no es administrador, redirigir a página anterior
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No tienes permisos para registrar usuarios'),
              backgroundColor: Colors.red,
            ),
          );
          Navigator.pop(context);
        });
        return;
      }

      // Obtener el servicio de cursos desde el mismo Provider que usamos para auth
      final courseService = CourseService(Provider.of<AuthProvider>(context, listen: false).apiClient);
      final courses = await courseService.getCourses();

      if (mounted) {
        setState(() {
          _courses = courses;
          _isLoadingCourses = false;
        });
      }
    } catch (e) {
      // En caso de error, mostrar mensaje y dejar lista vacía
      print('Error al cargar cursos: $e');
      if (mounted) {
        setState(() {
          _isLoadingCourses = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al cargar cursos. Por favor intenta nuevamente.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Verificar si el usuario actual es administrador, si no lo es, mostrar pantalla de acceso denegado
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    if (user == null || !user.isAdmin) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Acceso Restringido'),
          centerTitle: true,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock,
                size: 80,
                color: Colors.red,
              ),
              SizedBox(height: 20),
              Text(
                'Acceso Denegado',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                'No tienes permisos para registrar usuarios',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Usuario'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Registrar Nuevo Usuario',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              FormBuilder(
                key: _formKey,
                child: Column(
                  children: [
                    // Campo Nombre de usuario
                    FormBuilderTextField(
                      name: 'username',
                      decoration: const InputDecoration(
                        labelText: 'Nombre de usuario',
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(errorText: 'El nombre de usuario es obligatorio'),
                      ]),
                    ),
                    const SizedBox(height: 16),

                    // Campo Email
                    FormBuilderTextField(
                      name: 'email',
                      decoration: const InputDecoration(
                        labelText: 'Correo electrónico',
                        prefixIcon: Icon(Icons.email),
                      ),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(errorText: 'El correo es obligatorio'),
                        FormBuilderValidators.email(errorText: 'Ingrese un correo válido'),
                      ]),
                    ),
                    const SizedBox(height: 16),

                    // Campo Nombre
                    FormBuilderTextField(
                      name: 'firstName',
                      decoration: const InputDecoration(
                        labelText: 'Nombre',
                        prefixIcon: Icon(Icons.badge),
                      ),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(errorText: 'El nombre es obligatorio'),
                      ]),
                    ),
                    const SizedBox(height: 16),

                    // Campo Apellido
                    FormBuilderTextField(
                      name: 'lastName',
                      decoration: const InputDecoration(
                        labelText: 'Apellido',
                        prefixIcon: Icon(Icons.badge_outlined),
                      ),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(errorText: 'El apellido es obligatorio'),
                      ]),
                    ),
                    const SizedBox(height: 16),

                    // Selector de Rol
                    FormBuilderDropdown(
                      name: 'role',
                      decoration: const InputDecoration(
                        labelText: 'Rol',
                        prefixIcon: Icon(Icons.work),
                      ),
                      initialValue: _selectedRole,
                      items: _roles
                          .map((role) => DropdownMenuItem(
                                value: role['value'],
                                child: Text(role['label']),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedRole = value.toString();
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Selector de Curso (solo visible para estudiantes)
                    if (_selectedRole == 'ESTUDIANTE')
                      _isLoadingCourses
                        ? const Center(child: CircularProgressIndicator())
                        : FormBuilderDropdown(
                            name: 'course',
                            decoration: const InputDecoration(
                              labelText: 'Curso',
                              prefixIcon: Icon(Icons.school),
                            ),
                            items: _courses
                                .map((course) => DropdownMenuItem(
                                      value: course['id'],
                                      child: Text(course['nombre']),
                                    ))
                                .toList(),
                            validator: FormBuilderValidators.compose([
                              FormBuilderValidators.required(errorText: 'El curso es obligatorio para estudiantes'),
                            ]),
                          ),
                    if (_selectedRole == 'ESTUDIANTE')
                      const SizedBox(height: 16),

                    // Campo Contraseña
                    FormBuilderTextField(
                      name: 'password',
                      obscureText: !_isPasswordVisible,
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                      ),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(errorText: 'La contraseña es obligatoria'),
                        FormBuilderValidators.minLength(6, errorText: 'La contraseña debe tener al menos 6 caracteres'),
                      ]),
                    ),
                    const SizedBox(height: 16),

                    // Campo Confirmar Contraseña
                    FormBuilderTextField(
                      name: 'password2',
                      obscureText: !_isPasswordVisible,
                      decoration: const InputDecoration(
                        labelText: 'Confirmar Contraseña',
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
                      validator: (value) {
                        if (value != _formKey.currentState?.fields['password']?.value) {
                          return 'Las contraseñas no coinciden';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Botón de registro
                    Consumer<AuthProvider>(
                      builder: (context, authProvider, _) {
                        if (_isSubmitting) {
                          return const CircularProgressIndicator();
                        }

                        // Mostrar mensaje de error si existe
                        if (authProvider.error != null) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(authProvider.error!),
                                backgroundColor: Colors.red,
                              ),
                            );
                          });
                        }

                        return ElevatedButton(
                          onPressed: () => _submitForm(authProvider),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Registrar Usuario',
                            style: TextStyle(fontSize: 16),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitForm(AuthProvider authProvider) async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final formData = _formKey.currentState!.value;

      setState(() {
        _isSubmitting = true;
      });

      try {
        final success = await authProvider.register(
          username: formData['username'],
          email: formData['email'],
          firstName: formData['firstName'],
          lastName: formData['lastName'],
          password: formData['password'],
          password2: formData['password2'],
          role: formData['role'],
          courseId: _selectedRole == 'ESTUDIANTE' ? formData['course'] : null,
        );

        if (success && mounted) {
          // Si el registro es exitoso, mostrar mensaje y volver a la pantalla anterior
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Usuario registrado exitosamente'),
              backgroundColor: Colors.green,
            ),
          );

          Navigator.pop(context);
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
}
