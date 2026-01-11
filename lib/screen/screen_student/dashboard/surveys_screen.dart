import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:campuswork/services/survey_service.dart';
import 'package:campuswork/model/user.dart';

/// Écran pour gérer les sondages des étudiants
class SurveysScreen extends StatefulWidget {
  final User currentUser;
  const SurveysScreen({super.key, required this.currentUser});

  @override
  State<SurveysScreen> createState() => _SurveysScreenState();
}

class _SurveysScreenState extends State<SurveysScreen> {
  final SurveyService _surveyService = SurveyService();
  final TextEditingController _questionController = TextEditingController();
  List<Map<String, dynamic>> _surveys = [];
  bool _isLoading = true;
  String _selectedType = 'yes_no';
  List<TextEditingController> _optionControllers = [TextEditingController()];

  @override
  void initState() {
    super.initState();
    _loadSurveys();
  }

  @override
  void dispose() {
    _questionController.dispose();
    for (var controller in _optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadSurveys() async {
    final surveys = await _surveyService.getAllSurveys();
    setState(() {
      _surveys = surveys;
      _isLoading = false;
    });
  }

  Future<void> _createSurvey() async {
    if (_questionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez entrer une question')),
      );
      return;
    }

    List<String>? options;
    if (_selectedType == 'multiple_choice') {
      options = _optionControllers
          .where((c) => c.text.trim().isNotEmpty)
          .map((c) => c.text.trim())
          .toList();
      if (options.length < 2) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ajoutez au moins 2 options')),
        );
        return;
      }
    }

    await _surveyService.createSurvey(
      surveyId: const Uuid().v4(),
      userId: widget.currentUser.userId,
      question: _questionController.text.trim(),
      type: _selectedType,
      options: options,
    );

    _questionController.clear();
    for (var controller in _optionControllers) {
      controller.clear();
    }
    _optionControllers = [TextEditingController()];
    _loadSurveys();

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sondage créé avec succès'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _viewResponses(String surveyId) async {
    final responses = await _surveyService.getSurveyResponses(surveyId);
    final survey = _surveys.firstWhere((s) => s['surveyId'] == surveyId);
    
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.7,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Survey Question
                Text(
                  'Sondage',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    survey['question'] ?? 'Question non disponible',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                const SizedBox(height: 20),
                
                // Responses Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Réponses (${responses.length})',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (responses.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.download),
                        onPressed: () => _exportResponses(surveyId, responses),
                        tooltip: 'Exporter les réponses',
                      ),
                  ],
                ),
                const Divider(),
                
                // Responses List
                Expanded(
                  child: responses.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.inbox, size: 64, color: Colors.grey),
                              SizedBox(height: 16),
                              Text(
                                'Aucune réponse pour le moment',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: responses.length,
                          itemBuilder: (context, index) {
                            final response = responses[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: const Color(0xFF3B82F6),
                                  child: Text(
                                    (response['userName'] ?? 'U')[0].toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  response['userName'] ?? 'Utilisateur anonyme',
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                                subtitle: Container(
                                  margin: const EdgeInsets.only(top: 8),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[50],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    response['answer'] ?? 'Pas de réponse',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                                trailing: Text(
                                  _formatDate(response['createdAt']),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
                
                // Actions
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Fermer'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  Widget _buildSurveyCard(Map<String, dynamic> survey) {
    final surveyType = survey['type'] ?? 'yes_no';
    final responseCount = survey['responseCount'] ?? 0;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Colors.grey[50]!,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _viewResponses(survey['surveyId']),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with type badge
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getSurveyTypeColor(surveyType).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getSurveyTypeIcon(surveyType),
                            size: 16,
                            color: _getSurveyTypeColor(surveyType),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _getSurveyTypeLabel(surveyType),
                            style: TextStyle(
                              color: _getSurveyTypeColor(surveyType),
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    PopupMenuButton<String>(
                      icon: Icon(Icons.more_vert, color: Colors.grey[600]),
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'view',
                          child: Row(
                            children: [
                              Icon(Icons.visibility, size: 18),
                              SizedBox(width: 8),
                              Text('Voir les réponses'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 18, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Supprimer', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                      onSelected: (value) async {
                        if (value == 'view') {
                          _viewResponses(survey['surveyId']);
                        } else if (value == 'delete') {
                          _deleteSurvey(survey['surveyId']);
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Question
                Text(
                  survey['question'] ?? 'Question non disponible',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1D29),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Stats
                Row(
                  children: [
                    _buildStatChip(
                      icon: Icons.people,
                      label: '$responseCount réponse${responseCount > 1 ? 's' : ''}',
                      color: Colors.blue,
                    ),
                    const SizedBox(width: 12),
                    _buildStatChip(
                      icon: Icons.access_time,
                      label: _formatDate(survey['createdAt']),
                      color: Colors.grey,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _getSurveyTypeColor(String type) {
    switch (type) {
      case 'yes_no':
        return const Color(0xFF10B981);
      case 'multiple_choice':
        return const Color(0xFF3B82F6);
      case 'text':
        return const Color(0xFF8B5CF6);
      default:
        return Colors.grey;
    }
  }

  IconData _getSurveyTypeIcon(String type) {
    switch (type) {
      case 'yes_no':
        return Icons.check_circle;
      case 'multiple_choice':
        return Icons.radio_button_checked;
      case 'text':
        return Icons.text_fields;
      default:
        return Icons.poll;
    }
  }

  String _getSurveyTypeLabel(String type) {
    switch (type) {
      case 'yes_no':
        return 'Oui/Non';
      case 'multiple_choice':
        return 'Choix multiples';
      case 'text':
        return 'Texte libre';
      default:
        return 'Sondage';
    }
  }

  Future<void> _deleteSurvey(String surveyId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 12),
            Text('Supprimer le sondage'),
          ],
        ),
        content: const Text(
          'Êtes-vous sûr de vouloir supprimer ce sondage ? Cette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Supprimer', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _surveyService.deleteSurvey(surveyId);
      _loadSurveys();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sondage supprimé avec succès'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return '';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return '';
    }
  }

  void _exportResponses(String surveyId, List<Map<String, dynamic>> responses) {
    // TODO: Implement export functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Export des réponses - Fonctionnalité à venir'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sondages'),
        backgroundColor: const Color(0xFF3B82F6),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCreateSurveyDialog(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _surveys.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.poll, size: 100, color: Colors.grey),
                      SizedBox(height: 20),
                      Text(
                        'Aucun sondage',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadSurveys,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _surveys.length,
                    itemBuilder: (context, index) {
                      final survey = _surveys[index];
                      return _buildSurveyCard(survey);
                    },
                  ),
                ),
    );
  }

  void _showCreateSurveyDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.8,
          padding: const EdgeInsets.all(24),
          child: StatefulBuilder(
            builder: (context, setState) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3B82F6).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.poll,
                        color: Color(0xFF3B82F6),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Text(
                        'Créer un nouveau sondage',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1D29),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Question input
                        const Text(
                          'Question du sondage',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A1D29),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: TextField(
                            controller: _questionController,
                            decoration: const InputDecoration(
                              hintText: 'Posez votre question ici...',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.all(16),
                            ),
                            maxLines: 3,
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // Survey type selection
                        const Text(
                          'Type de réponse',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A1D29),
                          ),
                        ),
                        const SizedBox(height: 12),
                        
                        // Beautiful type selection cards
                        _buildTypeSelectionCard(
                          type: 'yes_no',
                          title: 'Oui / Non',
                          description: 'Question simple avec réponse oui ou non',
                          icon: Icons.check_circle,
                          color: const Color(0xFF10B981),
                          isSelected: _selectedType == 'yes_no',
                          onTap: () => setState(() => _selectedType = 'yes_no'),
                        ),
                        const SizedBox(height: 12),
                        _buildTypeSelectionCard(
                          type: 'multiple_choice',
                          title: 'Choix multiples',
                          description: 'Plusieurs options de réponse',
                          icon: Icons.radio_button_checked,
                          color: const Color(0xFF3B82F6),
                          isSelected: _selectedType == 'multiple_choice',
                          onTap: () => setState(() => _selectedType = 'multiple_choice'),
                        ),
                        const SizedBox(height: 12),
                        _buildTypeSelectionCard(
                          type: 'text',
                          title: 'Texte libre',
                          description: 'Réponse ouverte en texte',
                          icon: Icons.text_fields,
                          color: const Color(0xFF8B5CF6),
                          isSelected: _selectedType == 'text',
                          onTap: () => setState(() => _selectedType = 'text'),
                        ),
                        
                        // Options for multiple choice
                        if (_selectedType == 'multiple_choice') ...[
                          const SizedBox(height: 24),
                          const Text(
                            'Options de réponse',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1A1D29),
                            ),
                          ),
                          const SizedBox(height: 12),
                          ...List.generate(_optionControllers.length, (index) {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: Colors.grey[300]!),
                                      ),
                                      child: TextField(
                                        controller: _optionControllers[index],
                                        decoration: InputDecoration(
                                          hintText: 'Option ${index + 1}',
                                          border: InputBorder.none,
                                          contentPadding: const EdgeInsets.all(16),
                                          prefixIcon: Icon(
                                            Icons.radio_button_unchecked,
                                            color: Colors.grey[400],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (_optionControllers.length > 2)
                                    IconButton(
                                      onPressed: () {
                                        setState(() {
                                          _optionControllers[index].dispose();
                                          _optionControllers.removeAt(index);
                                        });
                                      },
                                      icon: const Icon(Icons.remove_circle, color: Colors.red),
                                    ),
                                ],
                              ),
                            );
                          }),
                          if (_optionControllers.length < 6)
                            Container(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  setState(() {
                                    _optionControllers.add(TextEditingController());
                                  });
                                },
                                icon: const Icon(Icons.add),
                                label: const Text('Ajouter une option'),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.all(16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ],
                    ),
                  ),
                ),
                
                // Action buttons
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Annuler'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _createSurvey,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3B82F6),
                          padding: const EdgeInsets.all(16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Créer le sondage',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeSelectionCard({
    required String type,
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          color: isSelected ? color.withOpacity(0.05) : Colors.white,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? color.withOpacity(0.1) : Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isSelected ? color : Colors.grey[600],
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? color : const Color(0xFF1A1D29),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: color,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}


