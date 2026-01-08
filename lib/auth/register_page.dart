import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:campuswork/model/user.dart';
import 'package:campuswork/auth/auth_service.dart';
import 'package:campuswork/auth/oauth_service.dart';
import 'package:campuswork/database/database_helper.dart';
import 'package:campuswork/database/database_helper_extension.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  
  // Common fields
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phonenumberController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Student specific fields
  final _matriculeController = TextEditingController();
  final _levelController = TextEditingController();
  final _semesterController = TextEditingController();
  final _sectionController = TextEditingController();
  final _filiereController = TextEditingController();
  final _academicYearController = TextEditingController();
  DateTime _birthday = DateTime(2000, 1, 1);

  // Lecturer specific fields
  final _uniteDenseignementController = TextEditingController();
  final _lecturerSectionController = TextEditingController();

  UserRole? _selectedRole;
 // int _currentStep = 0;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _phonenumberController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _matriculeController.dispose();
    _levelController.dispose();
    _semesterController.dispose();
    _sectionController.dispose();
    _filiereController.dispose();
    _academicYearController.dispose();
    _uniteDenseignementController.dispose();
    _lecturerSectionController.dispose();
    super.dispose();
  }

  Future<void> _selectBirthday() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _birthday,
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      helpText: 'Sélectionnez votre date de naissance',
    );
    if (picked != null && picked != _birthday) {
      setState(() => _birthday = picked);
    }
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Check if username already exists
      final usernameExists = await AuthService().usernameExists(
        _usernameController.text.trim(),
      );

      if (usernameExists) {
        if (!mounted) return;
        _showErrorSnackBar('Ce nom d\'utilisateur existe déjà');
        setState(() => _isLoading = false);
        return;
      }

      // Check if email already exists
      final emailExists = await AuthService().emailExists(
        _emailController.text.trim(),
      );

      if (emailExists) {
        if (!mounted) return;
        _showErrorSnackBar('Cet email est déjà utilisé');
        setState(() => _isLoading = false);
        return;
      }

      // Register user with role-specific data
      final user = await AuthService().registerUser(
        firstname: _firstNameController.text.trim(),
        lastname: _lastNameController.text.trim(),
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        phonenumber: _phonenumberController.text.trim(),
        password: _passwordController.text,
        userRole: _selectedRole!,
      );

      if (!mounted) return;

      if (user != null) {
        // Save role-specific data
        if (_selectedRole == UserRole.student) {
          await _saveStudentData(user.userId);
        } else {
          await _saveLecturerData(user.userId);
        }
        
        _showSuccessDialog();
      } else {
        _showErrorSnackBar('Erreur lors de l\'inscription. Veuillez réessayer.');
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar('Une erreur est survenue: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveStudentData(String userId) async {
    try {
      final db = await DatabaseHelper.instance.database;
      await DatabaseExtensions.insertStudent(
        db: db,
        userId: userId,
        matricule: _matriculeController.text.trim(),
        birthday: _birthday,
        level: _levelController.text.trim(),
        semester: _semesterController.text.trim(),
        section: _sectionController.text.trim(),
        filiere: _filiereController.text.trim(),
        academicYear: _academicYearController.text.trim(),
      );
      debugPrint('✅ Student data saved successfully');
    } catch (e) {
      debugPrint('❌ Error saving student data: $e');
      rethrow;
    }
  }

  Future<void> _saveLecturerData(String userId) async {
    try {
      final db = await DatabaseHelper.instance.database;
      await DatabaseExtensions.insertLecturer(
        db: db,
        userId: userId,
        uniteDenseignement: _uniteDenseignementController.text.trim(),
        section: _lecturerSectionController.text.trim(),
      );
      debugPrint('✅ Lecturer data saved successfully');
    } catch (e) {
      debugPrint('❌ Error saving lecturer data: $e');
      rethrow;
    }
  }

  Future<void> _loginWithGitHub() async {
    setState(() => _isLoading = true);
    try {
      final user = await OAuthService().signInWithGitHub();
      if (user != null && mounted) {
        _showSuccessDialog();
      } else if (mounted) {
        _showErrorSnackBar('Connexion GitHub annulée ou échouée');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Erreur lors de la connexion GitHub: $e');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loginWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      final user = await OAuthService().signInWithGoogle();
      if (user != null && mounted) {
        _showSuccessDialog();
      } else if (mounted) {
        _showErrorSnackBar('Connexion Google annulée ou échouée');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Erreur lors de la connexion Google: $e');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loginWithLinkedIn() async {
    setState(() => _isLoading = true);
    try {
      final user = await OAuthService().signInWithLinkedIn();
      if (user != null && mounted) {
        _showSuccessDialog();
      } else if (mounted) {
        _showErrorSnackBar('Connexion LinkedIn annulée ou échouée');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Erreur lors de la connexion LinkedIn: $e');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.check_circle, color: Colors.green, size: 48),
        title: const Text('Inscription réussie'),
        content: const Text(
          'Votre compte a été créé avec succès. Vous pouvez maintenant vous connecter.',
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/');
            },
            child: const Text('Se connecter'),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email requis';
    final emailRegex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) return 'Email invalide';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Mot de passe requis';
    if (value.length < 8) return 'Minimum 8 caractères';
    if (!value.contains(RegExp(r'[A-Z]'))) return 'Doit contenir au moins une majuscule';
    if (!value.contains(RegExp(r'[0-9]'))) return 'Doit contenir au moins un chiffre';
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) return 'Confirmation requise';
    if (value != _passwordController.text) return 'Les mots de passe ne correspondent pas';
    return null;
  }

  String? _validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) return 'Numéro requis';
    final cleaned = value.replaceAll(RegExp(r'[\s\-()]'), '');
    if (!cleaned.startsWith('+') || cleaned.length < 11 || cleaned.length > 16) {
      return 'Format: +237XXXXXXXXX';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Créer un compte'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _selectedRole == null ? _buildRoleSelection() : _buildRegistrationForm(),
      ),
    );
  }

  Widget _buildRoleSelection() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_circle,
              size: 80,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 24),
            Text(
              'Qui êtes-vous ?',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Choisissez votre profil pour commencer',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            
            // Student Card
            _buildRoleCard(
              icon: Icons.school,
              title: 'Étudiant',
              description: 'Accédez aux cours, devoirs et ressources',
              color: Colors.blue,
              onTap: () => setState(() => _selectedRole = UserRole.student),
            ),
            
            const SizedBox(height: 16),
            
            // Lecturer Card
            _buildRoleCard(
              icon: Icons.person,
              title: 'Enseignant',
              description: 'Gérez vos cours et évaluez vos étudiants',
              color: Colors.purple,
              onTap: () => setState(() => _selectedRole = UserRole.lecturer),
            ),
            
            const SizedBox(height: 48),
            
            // Social Login Divider
            Row(
              children: [
                Expanded(child: Divider(color: Colors.grey[300])),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'OU',
                    style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500),
                  ),
                ),
                Expanded(child: Divider(color: Colors.grey[300])),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Social Login Buttons
            Text(
              'Inscription rapide avec',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildSocialButton(
                  icon: Icons.code,
                  label: 'GitHub',
                  color: Colors.black,
                  onTap: _loginWithGitHub,
                ),
                const SizedBox(width: 12),
                _buildSocialButton(
                  icon: Icons.g_mobiledata,
                  label: 'Google',
                  color: const Color(0xFFDB4437),
                  onTap: _loginWithGoogle,
                ),
                const SizedBox(width: 12),
                _buildSocialButton(
                  icon: Icons.business,
                  label: 'LinkedIn',
                  color: const Color(0xFF0077B5),
                  onTap: _loginWithLinkedIn,
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Login Link
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Vous avez déjà un compte ?'),
                TextButton(
                  onPressed: () => context.go('/'),
                  child: const Text('Se connecter'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withValues(alpha:0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 32, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(icon, size: 28, color: color),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegistrationForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Role Badge
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => setState(() => _selectedRole = null),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _selectedRole == UserRole.student 
                        ? Colors.blue.withValues(alpha:0.1)
                        : Colors.purple.withValues(alpha:0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _selectedRole == UserRole.student ? Icons.school : Icons.person,
                        size: 16,
                        color: _selectedRole == UserRole.student ? Colors.blue : Colors.purple,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _selectedRole == UserRole.student ? 'Étudiant' : 'Enseignant',
                        style: TextStyle(
                          color: _selectedRole == UserRole.student ? Colors.blue : Colors.purple,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Personal Information
            Text(
              'Informations personnelles',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _firstNameController,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Prénom',
                      prefixIcon: Icon(Icons.person_outline),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => 
                      value == null || value.trim().isEmpty ? 'Prénom requis' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _lastNameController,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Nom',
                      prefixIcon: Icon(Icons.person_outline),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => 
                      value == null || value.trim().isEmpty ? 'Nom requis' : null,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Nom d\'utilisateur',
                prefixIcon: Icon(Icons.alternate_email),
                border: OutlineInputBorder(),
                helperText: 'Utilisé pour vous connecter',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) return 'Nom d\'utilisateur requis';
                if (value.length < 3) return 'Minimum 3 caractères';
                if (value.contains(' ')) return 'Pas d\'espaces autorisés';
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email_outlined),
                border: OutlineInputBorder(),
              ),
              validator: _validateEmail,
            ),
            
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _phonenumberController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Numéro de téléphone',
                prefixIcon: Icon(Icons.phone_outlined),
                border: OutlineInputBorder(),
                helperText: 'Format: +237XXXXXXXXX',
              ),
              validator: _validatePhoneNumber,
            ),
            
            const SizedBox(height: 24),
            
            // Security
            Text(
              'Sécurité',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'Mot de passe',
                prefixIcon: const Icon(Icons.lock_outlined),
                border: const OutlineInputBorder(),
                helperText: 'Min. 8 caractères, 1 majuscule, 1 chiffre',
                helperMaxLines: 2,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  ),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              validator: _validatePassword,
            ),
            
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: _obscureConfirmPassword,
              decoration: InputDecoration(
                labelText: 'Confirmer le mot de passe',
                prefixIcon: const Icon(Icons.lock_outlined),
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  ),
                  onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                ),
              ),
              validator: _validateConfirmPassword,
            ),
            
            const SizedBox(height: 24),
            
            // Role-specific fields
            if (_selectedRole == UserRole.student) _buildStudentFields(),
            if (_selectedRole == UserRole.lecturer) _buildLecturerFields(),
            
            const SizedBox(height: 32),
            
            // Register Button
            FilledButton(
              onPressed: _isLoading ? null : _register,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Créer mon compte',
                      style: TextStyle(fontSize: 16),
                    ),
            ),
            
            const SizedBox(height: 16),
            
            // Login Link
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Vous avez déjà un compte ?'),
                TextButton(
                  onPressed: () => context.go('/'),
                  child: const Text('Se connecter'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Informations académiques',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        
        TextFormField(
          controller: _matriculeController,
          decoration: const InputDecoration(
            labelText: 'Matricule',
            prefixIcon: Icon(Icons.badge_outlined),
            border: OutlineInputBorder(),
          ),
          validator: (value) => value == null || value.trim().isEmpty ? 'Matricule requis' : null,
        ),
        
        const SizedBox(height: 16),
        
        InkWell(
          onTap: _selectBirthday,
          child: InputDecorator(
            decoration: const InputDecoration(
              labelText: 'Date de naissance',
              prefixIcon: Icon(Icons.cake_outlined),
              border: OutlineInputBorder(),
            ),
            child: Text(
              '${_birthday.day}/${_birthday.month}/${_birthday.year}',
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _levelController,
                decoration: const InputDecoration(
                  labelText: 'Niveau',
                  hintText: 'L1, L2, L3...',
                  prefixIcon: Icon(Icons.grade),
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.trim().isEmpty ? 'Niveau requis' : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _semesterController,
                decoration: const InputDecoration(
                  labelText: 'Semestre',
                  hintText: 'Spring, Fall',
                  prefixIcon: Icon(Icons.calendar_today),
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.trim().isEmpty ? 'Semestre requis' : null,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        TextFormField(
          controller: _sectionController,
          decoration: const InputDecoration(
            labelText: 'Section',
            hintText: 'FR, EN',
            prefixIcon: Icon(Icons.class_),
            border: OutlineInputBorder(),
          ),
          validator: (value) => value == null || value.trim().isEmpty ? 'Section requise' : null,
        ),
        
        const SizedBox(height: 16),
        
        TextFormField(
          controller: _filiereController,
          decoration: const InputDecoration(
            labelText: 'Filière',
            hintText: 'ICT, Business...',
            prefixIcon: Icon(Icons.book),
            border: OutlineInputBorder(),
          ),
          validator: (value) => value == null || value.trim().isEmpty ? 'Filière requise' : null,
        ),
        
        const SizedBox(height: 16),
        
        TextFormField(
          controller: _academicYearController,
          decoration: const InputDecoration(
            labelText: 'Année académique',
            hintText: '2024-2025',
            prefixIcon: Icon(Icons.calendar_month),
            border: OutlineInputBorder(),
          ),
          validator: (value) => value == null || value.trim().isEmpty ? 'Année académique requise' : null,
        ),
      ],
    );
  }

  Widget _buildLecturerFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Informations professionnelles',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        
        TextFormField(
          controller: _uniteDenseignementController,
          decoration: const InputDecoration(
            labelText: 'Unité d\'enseignement',
            hintText: 'Mathématiques, Physique...',
            prefixIcon: Icon(Icons.menu_book),
            border: OutlineInputBorder(),
          ),
          validator: (value) => value == null || value.trim().isEmpty ? 'Unité d\'enseignement requise' : null,
        ),
        
        const SizedBox(height: 16),
        
        TextFormField(
          controller: _lecturerSectionController,
          decoration: const InputDecoration(
            labelText: 'Section',
            hintText: 'FR, EN',
            prefixIcon: Icon(Icons.class_),
            border: OutlineInputBorder(),
          ),
          validator: (value) => value == null || value.trim().isEmpty ? 'Section requise' : null,
        ),
      ],
    );
  }
}