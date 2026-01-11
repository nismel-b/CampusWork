import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:campuswork/model/user.dart';
import 'package:campuswork/auth/auth_service.dart';
import 'package:campuswork/auth/oauth_service.dart';
import 'package:campuswork/database/database_helper.dart';
import 'package:campuswork/database/database_helper_extension.dart';
import 'package:campuswork/theme/theme.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  
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
  DateTime _birthday = DateTime.now().subtract(const Duration(days: 6570)); // ~18 years

  // Lecturer specific fields
  final _uniteDenseignementController = TextEditingController();
  final _lecturerSectionController = TextEditingController();

  UserRole? _selectedRole;
  int _currentStep = 0;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
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
    if (_selectedRole == null) {
      _showErrorSnackBar('Veuillez sélectionner un rôle');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final username = _usernameController.text.trim();
      final email = _emailController.text.trim();
      final password = _passwordController.text;
      
      debugPrint('🔄 Registration attempt - Username: $username, Email: $email');
      
      final user = await AuthService().registerUser(
        firstname: _firstNameController.text.trim(),
        lastname: _lastNameController.text.trim(),
        username: username,
        email: email,
        phonenumber: _phonenumberController.text.trim(),
        password: password,
        userRole: _selectedRole!,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (user != null) {
        debugPrint('✅ Registration successful for: $username');
        
        // Save role-specific data
        try {
          if (_selectedRole == UserRole.student) {
            await _saveStudentData(user.userId);
            debugPrint('✅ Student data saved for: $username');
          } else if (_selectedRole == UserRole.lecturer) {
            await _saveLecturerData(user.userId);
            debugPrint('✅ Lecturer data saved for: $username');
          }
          
          // Automatically log in the user after successful registration
          debugPrint('🔄 Attempting auto-login for: $username');
          final loggedInUser = await AuthService().loginUser(
            username: user.username,
            password: password,
          );
          
          if (loggedInUser != null && mounted) {
            debugPrint('✅ Auto-login successful for: $username');
            // Navigate directly to appropriate dashboard
            _navigateBasedOnRole(loggedInUser.userRole);
          } else {
            debugPrint('❌ Auto-login failed for: $username');
            // Fallback to success dialog if auto-login fails
            _showSuccessDialog();
          }
        } catch (e) {
          debugPrint('❌ Error saving role-specific data: $e');
          _showErrorSnackBar('Compte créé mais erreur lors de la sauvegarde des données spécifiques: $e');
        }
      } else {
        debugPrint('❌ Registration failed for: $username');
        _showErrorSnackBar('Erreur lors de l\'inscription. Vérifiez que l\'email et le nom d\'utilisateur ne sont pas déjà utilisés.');
      }
    } catch (e) {
      debugPrint('❌ Registration error: $e');
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showErrorSnackBar('Erreur lors de l\'inscription: ${e.toString()}');
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
    } catch (e) {
      debugPrint('Error saving student data: $e');
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
    } catch (e) {
      debugPrint('Error saving lecturer data: $e');
      rethrow;
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

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Theme.of(context).colorScheme.tertiary),
            const SizedBox(width: 12),
            const Text('Inscription réussie !'),
          ],
        ),
        content: const Text(
          'Votre compte a été créé avec succès. Vous êtes maintenant connecté.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Navigate to appropriate dashboard based on user role
              final currentUser = AuthService().currentUser;
              if (currentUser != null) {
                _navigateBasedOnRole(currentUser.userRole);
              } else {
                context.go('/');
              }
            },
            child: const Text('Continuer'),
          ),
        ],
      ),
    );
  }

  void _navigateBasedOnRole(UserRole role) {
    switch (role) {
      case UserRole.student:
        context.go('/student-dashboard');
        break;
      case UserRole.lecturer:
        context.go('/lecturer-dashboard');
        break;
      case UserRole.admin:
        context.go('/admin-dashboard');
        break;
    }
  }

  void _nextStep() {
    if (_currentStep == 0 && _selectedRole == null) {
      _showErrorSnackBar('Veuillez sélectionner un rôle');
      return;
    }
    
    if (_currentStep < 2) {
      setState(() => _currentStep++);
      _pageController.nextPage(
        duration: AppTheme.normalAnimation,
        curve: Curves.easeInOut,
      );
    } else {
      _register();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.previousPage(
        duration: AppTheme.normalAnimation,
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.primaryGradient,
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Column(
                children: [
                  // Header
                  _buildHeader(),
                  
                  // Progress Indicator
                  _buildProgressIndicator(),
                  
                  // Content
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: PageView(
                        controller: _pageController,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          _buildRoleSelection(),
                          _buildPersonalInfo(),
                          _buildAccountInfo(),
                        ],
                      ),
                    ),
                  ),
                  
                  // Navigation Buttons
                  _buildNavigationButtons(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Créer un compte',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Rejoignez CampusWork dès aujourd\'hui',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: List.generate(3, (index) {
          final isActive = index <= _currentStep;
          final isCompleted = index < _currentStep;
          
          return Expanded(
            child: Container(
              height: 4,
              margin: EdgeInsets.only(right: index < 2 ? 8 : 0),
              decoration: BoxDecoration(
                color: isActive 
                    ? Colors.white 
                    : Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
              child: isCompleted
                  ? Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    )
                  : null,
            ),
          );
        }),
      ),
    );
  }

  Widget _buildRoleSelection() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Choisissez votre rôle',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1D29),
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            'Sélectionnez le rôle qui correspond à votre statut',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF6B7280),
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Student Role
          _buildRoleCard(
            role: UserRole.student,
            title: 'Étudiant',
            description: 'Créez et partagez vos projets académiques',
            icon: Icons.school_outlined,
            color: const Color(0xFF4A90E2),
          ),
          
          const SizedBox(height: 16),
          
          // Lecturer Role
          _buildRoleCard(
            role: UserRole.lecturer,
            title: 'Enseignant',
            description: 'Évaluez et guidez les projets étudiants',
            icon: Icons.person_outline,
            color: const Color(0xFF7B68EE),
          ),

          const Spacer(),

          // Social Login Section
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
          
          const SizedBox(height: 16),
          
          Text(
            'Inscription rapide avec',
            style: TextStyle(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSocialButton(
                icon: Icons.g_mobiledata,
                label: 'Google',
                color: const Color(0xFFDB4437),
                onTap: _loginWithGoogle,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRoleCard({
    required UserRole role,
    required String title,
    required String description,
    required IconData icon,
    required Color color,
  }) {
    final isSelected = _selectedRole == role;
    
    return GestureDetector(
      onTap: () => setState(() => _selectedRole = role),
      child: AnimatedContainer(
        duration: AppTheme.normalAnimation,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : const Color(0xFFF5F7FA),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : const Color(0xFFE8EDF2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected ? color : const Color(0xFF6B7280),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            
            const SizedBox(width: 16),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isSelected ? color : const Color(0xFF1A1D29),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            
            if (isSelected)
              Icon(Icons.check_circle, color: color, size: 24),
          ],
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

  Widget _buildPersonalInfo() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Informations personnelles',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A1D29),
                ),
              ),
              
              const SizedBox(height: 8),
              
              Text(
                'Renseignez vos informations de base',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF6B7280),
                ),
              ),
              
              const SizedBox(height: 32),
              
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _firstNameController,
                      label: 'Prénom',
                      icon: Icons.person_outline,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Requis';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      controller: _lastNameController,
                      label: 'Nom',
                      icon: Icons.person_outline,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Requis';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              _buildTextField(
                controller: _emailController,
                label: 'Email institutionnel',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Email requis';
                  }
                  if (!value.contains('@') || !value.contains('.')) {
                    return 'Email invalide';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 20),
              
              _buildTextField(
                controller: _phonenumberController,
                label: 'Numéro de téléphone',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Numéro requis';
                  }
                  return null;
                },
              ),

              // Role-specific fields
              if (_selectedRole == UserRole.student) ...[
                const SizedBox(height: 24),
                Text(
                  'Informations académiques',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1D29),
                  ),
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _matriculeController,
                  label: 'Matricule',
                  icon: Icons.badge_outlined,
                  validator: (value) => value == null || value.trim().isEmpty ? 'Matricule requis' : null,
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: _selectBirthday,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F7FA),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE8EDF2)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.cake_outlined, color: Color(0xFF6B7280)),
                        const SizedBox(width: 12),
                        Text(
                          'Date de naissance: ${_birthday.day}/${_birthday.month}/${_birthday.year}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _levelController,
                        label: 'Niveau',
                        icon: Icons.grade,
                        validator: (value) => value == null || value.trim().isEmpty ? 'Niveau requis' : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        controller: _semesterController,
                        label: 'Semestre',
                        icon: Icons.calendar_today,
                        validator: (value) => value == null || value.trim().isEmpty ? 'Semestre requis' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _sectionController,
                  label: 'Section',
                  icon: Icons.class_,
                  validator: (value) => value == null || value.trim().isEmpty ? 'Section requise' : null,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _filiereController,
                  label: 'Filière',
                  icon: Icons.book,
                  validator: (value) => value == null || value.trim().isEmpty ? 'Filière requise' : null,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _academicYearController,
                  label: 'Année académique',
                  icon: Icons.calendar_month,
                  validator: (value) => value == null || value.trim().isEmpty ? 'Année académique requise' : null,
                ),
              ],

              if (_selectedRole == UserRole.lecturer) ...[
                const SizedBox(height: 24),
                Text(
                  'Informations professionnelles',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1D29),
                  ),
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _uniteDenseignementController,
                  label: 'Unité d\'enseignement',
                  icon: Icons.menu_book,
                  validator: (value) => value == null || value.trim().isEmpty ? 'Unité d\'enseignement requise' : null,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _lecturerSectionController,
                  label: 'Section',
                  icon: Icons.class_,
                  validator: (value) => value == null || value.trim().isEmpty ? 'Section requise' : null,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountInfo() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informations de compte',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1D29),
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            'Créez vos identifiants de connexion',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF6B7280),
            ),
          ),
          
          const SizedBox(height: 32),
          
          _buildTextField(
            controller: _usernameController,
            label: 'Nom d\'utilisateur',
            icon: Icons.alternate_email,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Nom d\'utilisateur requis';
              }
              if (value.length < 3) {
                return 'Au moins 3 caractères';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 20),
          
          _buildTextField(
            controller: _passwordController,
            label: 'Mot de passe',
            icon: Icons.lock_outline,
            obscureText: _obscurePassword,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: const Color(0xFF6B7280),
              ),
              onPressed: () {
                setState(() => _obscurePassword = !_obscurePassword);
              },
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Mot de passe requis';
              }
              if (value.length < 8) {
                return 'Au moins 8 caractères';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 20),
          
          _buildTextField(
            controller: _confirmPasswordController,
            label: 'Confirmer le mot de passe',
            icon: Icons.lock_outline,
            obscureText: _obscureConfirmPassword,
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                color: const Color(0xFF6B7280),
              ),
              onPressed: () {
                setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
              },
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Confirmation requise';
              }
              if (value != _passwordController.text) {
                return 'Les mots de passe ne correspondent pas';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: const Color(0xFF1A1D29),
      ),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF6B7280)),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: const Color(0xFFF5F7FA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: const Color(0xFFE8EDF2), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: const Color(0xFF4A90E2), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.error, width: 1),
        ),
        labelStyle: const TextStyle(color: Color(0xFF6B7280)),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousStep,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(color: Colors.white.withOpacity(0.5)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Précédent'),
              ),
            ),
          
          if (_currentStep > 0) const SizedBox(width: 16),
          
          Expanded(
            flex: _currentStep == 0 ? 1 : 1,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _nextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF4A90E2),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4A90E2)),
                      ),
                    )
                  : Text(
                      _currentStep == 2 ? 'Créer le compte' : 'Suivant',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: const Color(0xFF4A90E2),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

