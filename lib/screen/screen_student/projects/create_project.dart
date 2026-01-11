import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:campuswork/auth/auth_service.dart';
import 'package:campuswork/services/project_service.dart';
import 'package:campuswork/model/project.dart';
import 'package:campuswork/theme/theme.dart';
import 'package:image_picker/image_picker.dart';


class CreateProjectPage extends StatefulWidget {
  const CreateProjectPage({super.key});

  @override
  State<CreateProjectPage> createState() => _CreateProjectPageState();
}

class _CreateProjectPageState extends State<CreateProjectPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();

  // Controllers
  final _nameController = TextEditingController();
  final _courseController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _gradeController = TextEditingController();
  final _architectureController = TextEditingController();
  final _resourcesController = TextEditingController();
  final _categoryController = TextEditingController();
  final _umlController = TextEditingController();
  final _downloadLinkController = TextEditingController();
  final _prototypeController = TextEditingController();
  final _powerpointLinkController = TextEditingController();
  final _prerequisitesController = TextEditingController();
  final _reportLinkController = TextEditingController();
  final _imageurlController = TextEditingController();

  // Animation controllers
  late AnimationController _animationController;
  late AnimationController _progressController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _progressAnimation;

  // State
  int _currentStep = 0;
  final int _totalSteps = 4; // Simplified to 4 main steps
  bool _isLoading = false;
  ProjectStatus _status = ProjectStatus.public;
  ProjectState _state = ProjectState.enCours;
  String _imagePath = '';
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _progressController = AnimationController(
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

    _slideAnimation = Tween<double>(
      begin: 50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
    _updateProgress();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _progressController.dispose();
    _pageController.dispose();
    _nameController.dispose();
    _courseController.dispose();
    _descriptionController.dispose();
    _gradeController.dispose();
    _architectureController.dispose();
    _resourcesController.dispose();
    _categoryController.dispose();
    _umlController.dispose();
    _downloadLinkController.dispose();
    _prototypeController.dispose();
    _powerpointLinkController.dispose();
    _prerequisitesController.dispose();
    _reportLinkController.dispose();
    _imageurlController.dispose();
    super.dispose();
  }

  void _updateProgress() {
    _progressController.animateTo((_currentStep + 1) / _totalSteps);
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _imagePath = image.path;
        _imageurlController.text = image.path;
      });
    }
  }

  Future<void> _createProject() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    debugPrint('🔵 Starting project creation...');

    final resources = _resourcesController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final prerequisites = _prerequisitesController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final currentUser = AuthService().currentUser;
    if (currentUser == null) {
      debugPrint('❌ No current user found');
      setState(() => _isLoading = false);
      _showErrorSnackBar('Erreur: utilisateur non connecté');
      return;
    }

    debugPrint('✅ Current user: ${currentUser.username} (${currentUser.userId})');

    final project = Project(
      projectId: const Uuid().v4(),
      projectName: _nameController.text.trim(),
      courseName: _courseController.text.trim(),
      description: _descriptionController.text.trim(),
      imageUrl: _imageurlController.text.trim().isEmpty ? null : _imageurlController.text.trim(),
      uml: _umlController.text.trim().isEmpty ? null : _umlController.text.trim(),
      category: _categoryController.text.trim().isEmpty ? null : _categoryController.text.trim(),
      prototypeLink: _prototypeController.text.trim().isEmpty ? null : _prototypeController.text.trim(),
      downloadLink: _downloadLinkController.text.trim().isEmpty ? null : _downloadLinkController.text.trim(),
      prerequisites: prerequisites,
      powerpointLink: _powerpointLinkController.text.trim().isEmpty ? null : _powerpointLinkController.text.trim(),
      reportLink: _reportLinkController.text.trim().isEmpty ? null : _reportLinkController.text.trim(),
      grade: _gradeController.text.trim().isEmpty ? null : _gradeController.text.trim(),
      userId: currentUser.userId,
      architecturePatterns: _architectureController.text.trim().isEmpty
          ? null
          : _architectureController.text.trim(),
      status: _status,
      state: _state.toString().split('.').last,
      resources: resources,
      createdAt: DateTime.now().toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
    );

    debugPrint('🔵 Project object created:');
    debugPrint('   - ID: ${project.projectId}');
    debugPrint('   - Name: ${project.projectName}');
    debugPrint('   - User: ${project.userId}');

    final success = await ProjectService().createProject(project);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      debugPrint('✅ Project creation successful, showing success dialog');
      _showSuccessDialog();
    } else {
      debugPrint('❌ Project creation failed');
      _showErrorSnackBar('Erreur lors de la création du projet');
    }
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
            const Text('Projet créé !'),
          ],
        ),
        content: const Text(
          'Votre projet a été créé avec succès et est maintenant visible par vos enseignants.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Fermer le dialogue
              Navigator.of(context).pop(true); // Retourner à la page précédente avec succès
            },
            child: const Text('Retour'),
          ),
        ],
      ),
    );
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

  bool _validateStep(int step) {
    switch (step) {
      case 0:
        return _nameController.text.isNotEmpty &&
               _descriptionController.text.isNotEmpty &&
               _courseController.text.isNotEmpty;
      case 1:
        return _architectureController.text.isNotEmpty && 
               _resourcesController.text.isNotEmpty;
      case 2:
        return _categoryController.text.isNotEmpty;
      case 3:
        return true; // Optional step
      default:
        return false;
    }
  }

  void _nextStep() {
    if (_validateStep(_currentStep)) {
      if (_currentStep < _totalSteps - 1) {
        setState(() => _currentStep++);
        _pageController.nextPage(
          duration: AppTheme.normalAnimation,
          curve: Curves.easeInOut,
        );
        _updateProgress();
        _animationController.reset();
        _animationController.forward();
      } else {
        _createProject();
      }
    } else {
      _showErrorSnackBar('Veuillez remplir tous les champs requis');
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.previousPage(
        duration: AppTheme.normalAnimation,
        curve: Curves.easeInOut,
      );
      _updateProgress();
      _animationController.reset();
      _animationController.forward();
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
          child: Column(
            children: [
              // Modern Header
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
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: PageView(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      onPageChanged: (index) {
                        setState(() => _currentStep = index);
                      },
                      children: [
                        _buildBasicInfoStep(),
                        _buildTechnicalStep(),
                        _buildCategoryStep(),
                        _buildOptionalStep(),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Navigation Buttons
              _buildNavigationButtons(),
            ],
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
                  'Nouveau projet',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Étape ${_currentStep + 1} sur $_totalSteps',
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
      child: AnimatedBuilder(
        animation: _progressAnimation,
        builder: (context, child) {
          return LinearProgressIndicator(
            value: _progressAnimation.value,
            backgroundColor: Colors.white.withOpacity(0.3),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            minHeight: 4,
          );
        },
      ),
    );
  }

  Widget _buildBasicInfoStep() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Transform.translate(
        offset: Offset(0, _slideAnimation.value),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Informations de base',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1A1D29),
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    'Commençons par les informations essentielles de votre projet',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  _buildTextField(
                    controller: _nameController,
                    label: 'Nom du projet',
                    icon: Icons.folder_outlined,
                    hint: 'Ex: Application mobile de gestion',
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Le nom du projet est requis';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 20),
                  
                  _buildTextField(
                    controller: _courseController,
                    label: 'Cours/Matière',
                    icon: Icons.school_outlined,
                    hint: 'Ex: Développement Mobile',
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Le cours est requis';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 20),
                  
                  _buildTextField(
                    controller: _descriptionController,
                    label: 'Description',
                    icon: Icons.description_outlined,
                    hint: 'Décrivez votre projet en quelques phrases...',
                    maxLines: 4,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'La description est requise';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 20),
                  
                  _buildTextField(
                    controller: _gradeController,
                    label: 'Note (optionnel)',
                    icon: Icons.grade_outlined,
                    hint: 'Ex: 18.5',
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTechnicalStep() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Transform.translate(
        offset: Offset(0, _slideAnimation.value),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Aspects techniques',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1D29),
                  ),
                ),
                
                const SizedBox(height: 8),
                
                Text(
                  'Détaillez l\'architecture et les technologies utilisées',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF6B7280),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                _buildTextField(
                  controller: _architectureController,
                  label: 'Architecture/Design patterns',
                  icon: Icons.architecture_outlined,
                  hint: 'Ex: MVC, MVVM, Clean Architecture...',
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'L\'architecture est requise';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 20),
                
                _buildTextField(
                  controller: _resourcesController,
                  label: 'Technologies utilisées',
                  icon: Icons.code_outlined,
                  hint: 'Ex: Flutter, Firebase, Node.js (séparées par des virgules)',
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Les technologies sont requises';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 20),
                
                _buildTextField(
                  controller: _prerequisitesController,
                  label: 'Prérequis',
                  icon: Icons.checklist_outlined,
                  hint: 'Ex: Android Studio, SDK Flutter (séparés par des virgules)',
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryStep() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Transform.translate(
        offset: Offset(0, _slideAnimation.value),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Catégorie et statut',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1D29),
                  ),
                ),
                
                const SizedBox(height: 8),
                
                Text(
                  'Classifiez votre projet et définissez sa visibilité',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF6B7280),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                _buildTextField(
                  controller: _categoryController,
                  label: 'Catégorie',
                  icon: Icons.category_outlined,
                  hint: 'Ex: Application mobile, Site web, IA...',
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'La catégorie est requise';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 32),
                
                // Project Status
                Text(
                  'Visibilité du projet',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1D29),
                  ),
                ),
                const SizedBox(height: 16),
                
                _buildStatusCard(
                  status: ProjectStatus.public,
                  title: 'Public',
                  description: 'Visible par tous les étudiants et enseignants',
                  icon: Icons.public,
                  color: const Color(0xFF10B981),
                ),
                
                const SizedBox(height: 12),
                
                _buildStatusCard(
                  status: ProjectStatus.private,
                  title: 'Privé',
                  description: 'Visible uniquement par vous et vos enseignants',
                  icon: Icons.lock_outline,
                  color: const Color(0xFF6B7280),
                ),
                
                const SizedBox(height: 32),
                
                // Project State
                Text(
                  'État du projet',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1D29),
                  ),
                ),
                const SizedBox(height: 16),
                
                _buildStateCard(
                  state: ProjectState.enCours,
                  title: 'En cours',
                  description: 'Projet en développement',
                  icon: Icons.work_outline,
                  color: const Color(0xFFF59E0B),
                ),
                
                const SizedBox(height: 12),
                
                _buildStateCard(
                  state: ProjectState.termine,
                  title: 'Terminé',
                  description: 'Projet finalisé',
                  icon: Icons.check_circle_outline,
                  color: const Color(0xFF10B981),
                ),
                
                const SizedBox(height: 12),
                
                _buildStateCard(
                  state: ProjectState.note,
                  title: 'Noté',
                  description: 'Projet évalué par l\'enseignant',
                  icon: Icons.grade_outlined,
                  color: const Color(0xFF7B68EE),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOptionalStep() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Transform.translate(
        offset: Offset(0, _slideAnimation.value),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ressources additionnelles',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1D29),
                  ),
                ),
                
                const SizedBox(height: 8),
                
                Text(
                  'Ajoutez des liens et ressources pour enrichir votre projet (optionnel)',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF6B7280),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                _buildTextField(
                  controller: _prototypeController,
                  label: 'Lien prototype/démo',
                  icon: Icons.play_circle_outline,
                  hint: 'https://...',
                  keyboardType: TextInputType.url,
                ),
                
                const SizedBox(height: 20),
                
                _buildTextField(
                  controller: _downloadLinkController,
                  label: 'Lien de téléchargement',
                  icon: Icons.download_outlined,
                  hint: 'https://github.com/...',
                  keyboardType: TextInputType.url,
                ),
                
                const SizedBox(height: 20),
                
                _buildTextField(
                  controller: _umlController,
                  label: 'Diagrammes UML',
                  icon: Icons.account_tree_outlined,
                  hint: 'Lien vers vos diagrammes UML',
                  keyboardType: TextInputType.url,
                ),
                
                const SizedBox(height: 20),
                
                _buildTextField(
                  controller: _powerpointLinkController,
                  label: 'Présentation PowerPoint',
                  icon: Icons.slideshow_outlined,
                  hint: 'Lien vers votre présentation',
                  keyboardType: TextInputType.url,
                ),
                
                const SizedBox(height: 20),
                
                _buildTextField(
                  controller: _reportLinkController,
                  label: 'Rapport de projet',
                  icon: Icons.description_outlined,
                  hint: 'Lien vers votre rapport PDF',
                  keyboardType: TextInputType.url,
                ),
                
                const SizedBox(height: 32),
                
                // Image Upload Section
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F7FA),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE8EDF2)),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.image_outlined,
                        size: 48,
                        color: const Color(0xFF6B7280),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Ajouter une image',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1A1D29),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Ajoutez une capture d\'écran ou une image de votre projet',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF6B7280),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _pickImage,
                        icon: const Icon(Icons.upload_outlined),
                        label: const Text('Choisir une image'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4A90E2),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      if (_imagePath.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: const Color(0xFF10B981),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Image sélectionnée',
                                  style: TextStyle(
                                    color: const Color(0xFF10B981),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: const Color(0xFF1A1D29),
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFF6B7280)),
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
        hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
      ),
    );
  }

  Widget _buildStatusCard({
    required ProjectStatus status,
    required String title,
    required String description,
    required IconData icon,
    required Color color,
  }) {
    final isSelected = _status == status;
    
    return GestureDetector(
      onTap: () => setState(() => _status = status),
      child: AnimatedContainer(
        duration: AppTheme.normalAnimation,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : const Color(0xFFF5F7FA),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : const Color(0xFFE8EDF2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected ? color : const Color(0xFF6B7280),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
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
              Icon(Icons.check_circle, color: color, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStateCard({
    required ProjectState state,
    required String title,
    required String description,
    required IconData icon,
    required Color color,
  }) {
    final isSelected = _state == state;
    
    return GestureDetector(
      onTap: () => setState(() => _state = state),
      child: AnimatedContainer(
        duration: AppTheme.normalAnimation,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : const Color(0xFFF5F7FA),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : const Color(0xFFE8EDF2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected ? color : const Color(0xFF6B7280),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
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
              Icon(Icons.check_circle, color: color, size: 20),
          ],
        ),
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
                      _currentStep == _totalSteps - 1 ? 'Créer le projet' : 'Suivant',
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