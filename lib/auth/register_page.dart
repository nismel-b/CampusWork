import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:campuswork/model/user.dart';
import 'package:campuswork/model/student.dart';
import 'package:campuswork/model/lecturer.dart';
import 'package:campuswork/auth/auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phonenumberController = TextEditingController();
  final _usernameController = TextEditingController();

  // Student fields
  final _matriculeController = TextEditingController();
  final _levelController = TextEditingController();
  final _semesterController = TextEditingController();
  final _sectionController = TextEditingController();
  final _filiereController = TextEditingController();
  final _academicYearController = TextEditingController();

  // Lecturer fields
  final _uniteDenseignementController = TextEditingController();

  UserRole _selectedRole = UserRole.student;
  final DateTime _birthday = DateTime(2000, 1, 1);
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    _phonenumberController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final now = DateTime.now();
    User user;

    if (_selectedRole == UserRole.student) {
      user = Student(
        userId: const Uuid().v4(),
        username: _usernameController.text.trim(),
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
        phonenumber: _phonenumberController.text.trim(),
        password: _passwordController.text,
        createdAt: now,
        updatedAt: now,
        matricule: _matriculeController.text.trim(),
        birthday: _birthday,
        level: _levelController.text.trim(),
        semester: _semesterController.text.trim(),
        section: _sectionController.text.trim(),
        filiere: _filiereController.text.trim(),
        academicYear: _academicYearController.text.trim(),
      );
    } else {
      user = Lecturer(
        userId: const Uuid().v4(),
        username: _usernameController.text.trim(),
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        phonenumber: _phonenumberController.text.trim(),
        createdAt: now,
        updatedAt: now,
        uniteDenseignement: _uniteDenseignementController.text.trim(),
        section: _sectionController.text.trim(),
      );
    }

    final success = await AuthService().registerUser(
      userId: '',
      firstname: '',
      lastname: '',
      username: '',
      email: '',
      phonenumber: '',
      password: '',
      userRole: UserRole.student,
      createdAt: null,
      updatedAt: null,);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success != null && mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('✅ Inscription réussie'),
          content: const Text(
            'Votre compte a été créé avec succès. Il doit être approuvé par un administrateur avant que vous puissiez vous connecter.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.go('/');
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email déjà utilisé ou erreur d\'inscription'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Créer un compte'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Type de compte',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                SegmentedButton<UserRole>(
                  segments: const [
                    ButtonSegment(
                      value: UserRole.student,
                      label: Text('Étudiant'),
                      icon: Icon(Icons.school),
                    ),
                    ButtonSegment(
                      value: UserRole.lecturer,
                      label: Text('Enseignant'),
                      icon: Icon(Icons.person),
                    ),
                  ],
                  selected: {_selectedRole},
                  onSelectionChanged: (Set<UserRole> newSelection) {
                    setState(() => _selectedRole = newSelection.first);
                  },
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _firstNameController,
                  decoration: const InputDecoration(
                    labelText: 'Prénom',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (value) => value == null || value.isEmpty ? 'Requis' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _lastNameController,
                  decoration: const InputDecoration(
                    labelText: 'Nom',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (value) => value == null || value.isEmpty ? 'Requis' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Requis';
                    if (!value.contains('@')) return 'Email invalide';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Mot de passe',
                    prefixIcon: const Icon(Icons.lock_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Requis';
                    if (value.length < 10 ) return 'Minimum 10 caractères';
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                if (_selectedRole == UserRole.student) ...[
                  Text(
                    'Informations académiques',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _matriculeController,
                    decoration: const InputDecoration(
                      labelText: 'Matricule',
                      prefixIcon: Icon(Icons.badge_outlined),
                    ),
                    validator: (value) => value == null || value.isEmpty ? 'Requis' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _levelController,
                    decoration: const InputDecoration(
                      labelText: 'Niveau (ex: L3)',
                      prefixIcon: Icon(Icons.grade),
                    ),
                    validator: (value) => value == null || value.isEmpty ? 'Requis' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _semesterController,
                    decoration: const InputDecoration(
                      labelText: 'Semestre (ex: Spring)',
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                    validator: (value) => value == null || value.isEmpty ? 'Requis' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _sectionController,
                    decoration: const InputDecoration(
                      labelText: 'Section (fr/ en)',
                      prefixIcon: Icon(Icons.class_),
                    ),
                    validator: (value) => value == null || value.isEmpty ? 'Requis' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _filiereController,
                    decoration: const InputDecoration(
                      labelText: 'Filière (ex: ICT)',
                      prefixIcon: Icon(Icons.book),
                    ),
                    validator: (value) => value == null || value.isEmpty ? 'Requis' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _academicYearController,
                    decoration: const InputDecoration(
                      labelText: 'Année académique (ex: summer2025)',
                      prefixIcon: Icon(Icons.calendar_month),
                    ),
                    validator: (value) => value == null || value.isEmpty ? 'Requis' : null,
                  ),
                ] else ...[
                  Text(
                    'Informations professionnelles',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _uniteDenseignementController,
                    decoration: const InputDecoration(
                      labelText: 'Unité d\'enseignement',
                      prefixIcon: Icon(Icons.menu_book),
                    ),
                    validator: (value) => value == null || value.isEmpty ? 'Requis' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _sectionController,
                    decoration: const InputDecoration(
                      labelText: 'Section (fr/ en)',
                      prefixIcon: Icon(Icons.class_),
                    ),
                    validator: (value) => value == null || value.isEmpty ? 'Requis' : null,
                  ),
                ],
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  child: _isLoading
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      : const Text('S\'inscrire'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

