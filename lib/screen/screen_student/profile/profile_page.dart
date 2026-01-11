import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:campuswork/auth/auth_service.dart';
import 'package:campuswork/model/student.dart';
import 'package:campuswork/components/user_avatar.dart';
import 'package:intl/intl.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Student _student;
  bool _isEditing = false;
  final _formKey = GlobalKey<FormState>();
  
  // Controllers pour l'édition
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _githubController = TextEditingController();
  final _linkedinController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _student = AuthService().currentUser as Student;
    _initializeControllers();
  }

  void _initializeControllers() {
    _firstNameController.text = _student.firstName;
    _lastNameController.text = _student.lastName;
    _emailController.text = _student.email;
    _phoneController.text = _student.phonenumber;
    _githubController.text = _student.githubLink ?? '';
    _linkedinController.text = _student.linkedinLink ?? '';
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _githubController.dispose();
    _linkedinController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await AuthService().updateUser(
      userId: _student.userId,
      firstname: _firstNameController.text.trim(),
      lastname: _lastNameController.text.trim(),
      email: _emailController.text.trim(),
      phonenumber: _phoneController.text.trim(),
    );

    if (success) {
      setState(() {
        _isEditing = false;
        _student = AuthService().currentUser as Student;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil mis à jour avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors de la mise à jour'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Profil'),
        actions: [
          if (_isEditing)
            TextButton(
              onPressed: () {
                setState(() => _isEditing = false);
                _initializeControllers();
              },
              child: const Text('Annuler'),
            )
          else
            IconButton(
              onPressed: () => setState(() => _isEditing = true),
              icon: const Icon(Icons.edit),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Avatar et info de base
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      UserAvatar(
                        userId: _student.userId,
                        name: _student.fullName,
                        size: 80,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _student.fullName,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Étudiant',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Informations personnelles
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Informations personnelles',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),
                      
                      if (_isEditing) ...[
                        TextFormField(
                          controller: _firstNameController,
                          decoration: const InputDecoration(
                            labelText: 'Prénom',
                            prefixIcon: Icon(Icons.person),
                          ),
                          validator: (value) => value?.isEmpty == true ? 'Requis' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _lastNameController,
                          decoration: const InputDecoration(
                            labelText: 'Nom',
                            prefixIcon: Icon(Icons.person),
                          ),
                          validator: (value) => value?.isEmpty == true ? 'Requis' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email),
                          ),
                          validator: (value) {
                            if (value?.isEmpty == true) return 'Requis';
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
                              return 'Email invalide';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _phoneController,
                          decoration: const InputDecoration(
                            labelText: 'Téléphone',
                            prefixIcon: Icon(Icons.phone),
                          ),
                        ),
                      ] else ...[
                        _buildInfoRow('Prénom', _student.firstName),
                        _buildInfoRow('Nom', _student.lastName),
                        _buildInfoRow('Email', _student.email),
                        _buildInfoRow('Téléphone', _student.phonenumber),
                      ],
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Informations académiques
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Informations académiques',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow('Matricule', _student.matricule),
                      _buildInfoRow('Niveau', _student.level),
                      _buildInfoRow('Semestre', _student.semester),
                      _buildInfoRow('Section', _student.section),
                      _buildInfoRow('Filière', _student.filiere),
                      _buildInfoRow('Année académique', _student.academicYear),
                      _buildInfoRow('Date de naissance', 
                        DateFormat('dd/MM/yyyy').format(_student.birthday)),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Liens sociaux
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Liens sociaux',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),
                      
                      if (_isEditing) ...[
                        TextFormField(
                          controller: _githubController,
                          decoration: const InputDecoration(
                            labelText: 'GitHub',
                            prefixIcon: Icon(Icons.code),
                            hintText: 'https://github.com/username',
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _linkedinController,
                          decoration: const InputDecoration(
                            labelText: 'LinkedIn',
                            prefixIcon: Icon(Icons.work),
                            hintText: 'https://linkedin.com/in/username',
                          ),
                        ),
                      ] else ...[
                        _buildLinkRow('GitHub', _student.githubLink),
                        _buildLinkRow('LinkedIn', _student.linkedinLink),
                      ],
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              if (_isEditing)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveProfile,
                    child: const Text('Sauvegarder'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : 'Non renseigné',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: value.isNotEmpty ? null : Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkRow(String label, String? url) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: url?.isNotEmpty == true
                ? InkWell(
                    onTap: () {
                      // TODO: Ouvrir le lien
                    },
                    child: Text(
                      url!,
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  )
                : Text(
                    'Non renseigné',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
          ),
        ],
      ),
    );
  }
}