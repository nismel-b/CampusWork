import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:campuswork/auth/auth_service.dart';
import 'package:campuswork/services/project_service.dart';
import 'package:campuswork/model/project.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class CreateProjectPage extends StatefulWidget {
  const CreateProjectPage({super.key});

  @override
  State<CreateProjectPage> createState() => _CreateProjectPageState();
}

class _CreateProjectPageState extends State<CreateProjectPage> {
  final _formKey = GlobalKey<FormState>();

// step 1: info  de base 
  final _nameController = TextEditingController();
  final _courseController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _gradeController = TextEditingController();
  // step 2 : architecture et ressources utilisées
  final _architectureController = TextEditingController();
  final _resourcesController = TextEditingController();

  //step 3 : créer une catégorie de projet ou intégrer une déja existante
  final _categoryController = TextEditingController();
  //step 4 : état du projet
  

  //bouton pour passer ou continuer 
  //informations supplémentaire sur le project
  //step 5 : les diagrammes uml
  final _umlController = TextEditingController();

  //step 6 : les différents liens utiles du projet 
  final _downloadLinkController = TextEditingController();
  final _prototypeController = TextEditingController();
  // step 7 : powerpoint et fichier pdf de présentation
  final _powerpointLinkController = TextEditingController();
  final _prerequisitesController = TextEditingController();
  final _reportLinkController = TextEditingController();
  // step 8: ajouter des images du projet 
  final _imageurlController = TextEditingController();
  
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 7;
  final ImagePicker _picker = ImagePicker();
  

  ProjectStatus _status = ProjectStatus.public;
  ProjectState _state = ProjectState.enCours;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _courseController.dispose();
    _descriptionController.dispose();
    _architectureController.dispose();
    _resourcesController.dispose();
    super.dispose();
  }

// pour gérer les images
  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _imagePath = image.path;
      });
    }
  }

// pour créer un projet 
  Future<void> _createProject() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    // pour ajouter les différentes ressources: les sources qui nous ont permis de réaliser le projet
    final resources = _resourcesController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    //pour ajouter les liens des fichiers uml
    final uml = _umlController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    //pour ajouter des images
      final imageurl = _imageurlController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList(); 

    final project = Project(
      projectId: const Uuid().v4(),
      projectName: _nameController.text.trim(),
      courseName: _courseController.text.trim(),
      description: _descriptionController.text.trim(),
      imageurl: _imageurlController.text.trim(),
      uml: _umlController.text.trim(),
      category: _categoryController.text.trim(),
      prototypeLink: _prototypeController.text.trim(),
      downloadLink: _downloadLinkController.text.trim(),
      prerequisites: _prerequisitesController.text.trim(),
      powerpointLink: _powerpointLinkController.text.trim(),
      reportLink: _reportLinkController.text.trim() ,
      grade: _gradeController.text.trim() ,
      studentId: AuthService().currentUser!.userId,
      architecturePatterns: _architectureController.text.trim().isEmpty
          ? null
          : _architectureController.text.trim(),
      status: _status,
      state: _state,
      resources: resources,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final success = await ProjectService().createProject(project);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Projet créé avec succès'),
          backgroundColor: Colors.green,
        ),
      );
      context.go('/student-dashboard');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors de la création du projet'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  bool _validateStep(int step) {
    switch (step) {
      case 0:
        return _nameController.text.isNotEmpty &&
        _descriptionController.text.isNotEmpty
        &&  _courseController.text.isNotEmpty ;
      case 1:
        return _architectureController.text.isNotEmpty && _resourcesController.text.isNotEmpty;
      case 2:
        return _categoryController.text.isNotEmpty;
      case 3:
        return true; // état du projet
      case 4:
        return true; // Optionnel
      case 5:
        return true; //optionnel
      case 6: 
        return true; // optionnel
      case 7 :
      return true; // optionnel
      default:
        return false; 

    }
  }

  void _nextStep() {
    if (_validateStep(_currentStep)) {
      if (_currentStep < _totalSteps - 1) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        _createProject();
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs requis')),
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nouveau projet (${_currentStep + 1}/$_totalSteps)'),
        backgroundColor: const Color.fromARGB(255, 170, 190, 223),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: (_currentStep + 1) / _totalSteps,
            backgroundColor: Colors.grey[300],
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (index) {
          setState(() {
            _currentStep = index;
          });
        },
        children: [
          _buildStep1(),
          _buildStep2(),
          _buildStep3(),
          _buildStep4(),
          _buildStep5(),
          _buildStep6(),
          _buildStep7(),
          _buildStep8(),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey,
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Row(
          children: [
            if (_currentStep > 0)
              Expanded(
                child: OutlinedButton(
                  onPressed: _previousStep,
                  child: const Text('Précédent'),
                ),
              ),
            if (_currentStep > 0) const SizedBox(width: 10),
            Expanded(
              flex: _currentStep == 0 ? 1 : 1,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _nextStep,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 148, 177, 223),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(_currentStep == _totalSteps - 1 ? 'Créer le projet' : 'Suivant'),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildStep1() {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Informations générales',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nom du projet',
                    prefixIcon: Icon(Icons.title),
                  ),
                  validator: (value) => value == null || value.isEmpty ? 'Requis' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _courseController,
                  decoration: const InputDecoration(
                    labelText: 'Cours',
                    prefixIcon: Icon(Icons.book),
                  ),
                  validator: (value) => value == null || value.isEmpty ? 'Requis' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    prefixIcon: Icon(Icons.description),
                    alignLabelWithHint: true,
                  ),
                  validator: (value) => value == null || value.isEmpty ? 'Requis' : null,
                ),
                const SizedBox(height: 24),
                
                TextFormField(
                  controller: _gradeController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Niveau',
                    prefixIcon: Icon(Icons.school),
                    alignLabelWithHint: true,
                  ),
                  validator: (value) => value == null || value.isEmpty ? 'Requis' : null,
                ),
                ]
            )
          )
        )
      )
    );
  }
Widget _buildStep2(){
  return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Détails techniques',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _architectureController,
                  decoration: const InputDecoration(
                    labelText: 'Architecture & Design Patterns (optionnel)',
                    prefixIcon: Icon(Icons.architecture),
                    hintText: 'ex: MVVM, Repository Pattern',
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _resourcesController,
                  decoration: const InputDecoration(
                    labelText: 'Ressources utilisées (séparées par virgules)',
                    prefixIcon: Icon(Icons.code),
                    hintText: 'ex: Flutter, Firebase, Node.js',
                  ),
                ),
                const SizedBox(height: 24),
              ]
              ),)))
  );
}
Widget _buildStep3(){
  return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Catégories de projet',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _categoryController,
                  decoration: const InputDecoration(
                    labelText: 'Catégories',
                    prefixIcon: Icon(Icons.architecture),
                    hintText: 'ex: app_ecommerce, jeux_vidéos',
                  ),
                ),
              
              ]
              ),)))
  );
}
Widget _buildStep4(){
  return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Configuration',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Theme.of(context).dividerColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Visibilité',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      SegmentedButton<ProjectStatus>(
                        segments: const [
                          ButtonSegment(
                            value: ProjectStatus.public,
                            label: Text('Public'),
                            icon: Icon(Icons.public),
                          ),
                          ButtonSegment(
                            value: ProjectStatus.private,
                            label: Text('Privé'),
                            icon: Icon(Icons.lock),
                          ),
                        ],
                        selected: {_status},
                        onSelectionChanged: (Set<ProjectStatus> newSelection) {
                          setState(() => _status = newSelection.first);
                        },
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'État',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      SegmentedButton<ProjectState>(
                        segments: const [
                          ButtonSegment(
                            value: ProjectState.enCours,
                            label: Text('En cours'),
                          ),
                          ButtonSegment(
                            value: ProjectState.termine,
                            label: Text('Terminé'),
                          ),
                        ],
                        selected: {_state},
                        onSelectionChanged: (Set<ProjectState> newSelection) {
                          setState(() => _state = newSelection.first);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ]
              ),)))
  );
}
Widget _buildStep5(){
  return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Diagrammes Uml',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _umlController,
                  decoration: const InputDecoration(
                    labelText: 'Insérer des diagrammes du projet',
                    prefixIcon: Icon(Icons.image),
                    hintText: 'ex: mon_uml.png',
                  ),
                ),
              
              ]
              ),)))
  );
}
Widget _buildStep6(){
  return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Liens utiles',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _downloadLinkController,
                  decoration: const InputDecoration(
                    labelText: 'Téléverser votre projet',
                    prefixIcon: Icon(Icons.folder_copy),
                    hintText: 'ex: lien github ou fichier exécutable du projet',
                  ),
                ),
              const SizedBox(height: 10),
              Text(
                  'Télécharger le prototype du projet',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _prototypeController,
                  decoration: const InputDecoration(
                    labelText: 'Prototype',
                    prefixIcon: Icon(Icons.folder_copy),
                    hintText: 'ex: lien figma, adobeXd, Canva',
                  ),
                ),
              
              ]
              ),)))
  );
}
Widget _buildStep7(){
  return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Rapport de projet et présentation',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _powerpointLinkController,
                  decoration: const InputDecoration(
                    labelText: 'Ajouter un powerpoint pour la présentation de votre projet',
                    prefixIcon: Icon(Icons.file_copy),
                    hintText: 'ex: mon_projet.ppt',
                  ),
                ),
              const SizedBox(height: 16),
              Text(
                  'Prérequis',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _prerequisitesController,
                  decoration: const InputDecoration(
                    labelText: 'Readme de votre app',
                    prefixIcon: Icon(Icons.architecture),
                    hintText: 'ex: comment lancer votre application ',
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Rapport de projet',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _reportLinkController,
                  decoration: const InputDecoration(
                    labelText: 'Rapport',
                    prefixIcon: Icon(Icons.file_copy),
                    hintText: 'ex: mon_projet.pdf',
                  ),
                ),
                
              ]
              ),)))
  );
}
Widget _buildStep8(){
  return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
              const Text(
            'Ajouter des screens du projet',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text(
            'Compléter votre projet avec des images',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 30),
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey),
              ),
              child: _imagePath.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.file(File(_imagePath), fit: BoxFit.cover),
                    )
                  : const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_photo_alternate, size: 50),
                        SizedBox(height: 10),
                        Text('Ajouter des images du projet'),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 20),
              ]
              ),)))
  );
}
}