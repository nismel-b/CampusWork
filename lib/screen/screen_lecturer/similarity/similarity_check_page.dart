import 'package:flutter/material.dart';
import 'package:campuswork/model/user.dart';
import 'package:campuswork/services/project_service.dart';
import 'package:campuswork/services/similarity_service.dart';
import 'package:campuswork/model/project.dart';

class SimilarityCheckPage extends StatefulWidget {
  final User currentUser;

  const SimilarityCheckPage({super.key, required this.currentUser});

  @override
  State<SimilarityCheckPage> createState() => _SimilarityCheckPageState();
}

class _SimilarityCheckPageState extends State<SimilarityCheckPage> {
  final ProjectService _projectService = ProjectService();
  final SimilarityService _similarityService = SimilarityService();
  
  List<Project> _projects = [];
  List<Map<String, dynamic>> _similarityResults = [];
  bool _isLoading = true;
  bool _isAnalyzing = false;
  Project? _selectedProject;
  double _similarityThreshold = 0.7;

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    setState(() => _isLoading = true);
    try {
      final projects = _projectService.getAllProjects();
      setState(() {
        _projects = projects;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading projects: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _checkSimilarity(Project project) async {
    setState(() {
      _isAnalyzing = true;
      _selectedProject = project;
      _similarityResults.clear();
    });

    try {
      final results = <Map<String, dynamic>>[];
      
      // Compare with all other projects using the SimilarityService
      final similarProjects = await _similarityService.checkProjectSimilarity(
        projectName: project.projectName,
        description: project.description,
        courseName: project.courseName,
        resources: project.resources,
        existingProjectId: project.projectId,
      );
      
      // Filter by threshold and convert to our format
      for (var similarProject in similarProjects) {
        if (similarProject.score >= _similarityThreshold) {
          results.add({
            'project': similarProject.project,
            'similarity': similarProject.score,
            'riskLevel': _getRiskLevel(similarProject.score),
          });
        }
      }
      
      setState(() {
        _similarityResults = results;
        _isAnalyzing = false;
      });
    } catch (e) {
      debugPrint('Error checking similarity: $e');
      setState(() => _isAnalyzing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de l\'analyse: $e')),
      );
    }
  }

  String _getRiskLevel(double similarity) {
    if (similarity >= 0.9) return 'Très élevé';
    if (similarity >= 0.8) return 'Élevé';
    if (similarity >= 0.7) return 'Modéré';
    return 'Faible';
  }

  Color _getRiskColor(String riskLevel) {
    switch (riskLevel) {
      case 'Très élevé':
        return Colors.red;
      case 'Élevé':
        return Colors.orange;
      case 'Modéré':
        return Colors.yellow[700]!;
      default:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vérification de similarité'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: _showHelpDialog,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Settings panel
                _buildSettingsPanel(),
                
                // Projects list or results
                Expanded(
                  child: _selectedProject == null
                      ? _buildProjectsList()
                      : _buildResultsView(),
                ),
              ],
            ),
    );
  }

  Widget _buildSettingsPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Paramètres de détection',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text('Seuil de similarité: '),
              Expanded(
                child: Slider(
                  value: _similarityThreshold,
                  min: 0.5,
                  max: 1.0,
                  divisions: 10,
                  label: '${(_similarityThreshold * 100).round()}%',
                  onChanged: (value) {
                    setState(() => _similarityThreshold = value);
                  },
                ),
              ),
              Text('${(_similarityThreshold * 100).round()}%'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProjectsList() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.security, color: Colors.red[600]),
              const SizedBox(width: 8),
              const Text(
                'Sélectionnez un projet à analyser',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _projects.length,
            itemBuilder: (context, index) {
              final project = _projects[index];
              return _buildProjectCard(project);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProjectCard(Project project) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.folder, color: Colors.red),
        ),
        title: Text(
          project.projectName,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              project.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    project.courseName ?? 'Cours non spécifié',
                    style: const TextStyle(fontSize: 12, color: Colors.blue),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: ElevatedButton(
          onPressed: () => _checkSimilarity(project),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          child: const Text('Analyser'),
        ),
      ),
    );
  }

  Widget _buildResultsView() {
    return Column(
      children: [
        // Selected project header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.05),
            border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Analyse de: ${_selectedProject!.projectName}',
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_similarityResults.length} similarité${_similarityResults.length > 1 ? 's' : ''} détectée${_similarityResults.length > 1 ? 's' : ''}',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedProject = null;
                    _similarityResults.clear();
                  });
                },
                child: const Text('Nouvelle analyse'),
              ),
            ],
          ),
        ),
        
        // Results
        Expanded(
          child: _isAnalyzing
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Analyse en cours...'),
                    ],
                  ),
                )
              : _similarityResults.isEmpty
                  ? _buildNoSimilarityFound()
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _similarityResults.length,
                      itemBuilder: (context, index) {
                        final result = _similarityResults[index];
                        return _buildSimilarityResultCard(result);
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildNoSimilarityFound() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle,
              size: 50,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Aucune similarité détectée',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Ce projet semble original selon les critères définis.',
            style: TextStyle(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSimilarityResultCard(Map<String, dynamic> result) {
    final project = result['project'] as Project;
    final similarity = result['similarity'] as double;
    final riskLevel = result['riskLevel'] as String;
    final riskColor = _getRiskColor(riskLevel);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: riskColor.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with similarity score
            Row(
              children: [
                Expanded(
                  child: Text(
                    project.projectName,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: riskColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${(similarity * 100).round()}%',
                    style: TextStyle(
                      color: riskColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // Risk level
            Row(
              children: [
                Icon(Icons.warning, size: 16, color: riskColor),
                const SizedBox(width: 4),
                Text(
                  'Risque: $riskLevel',
                  style: TextStyle(color: riskColor, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Project description
            Text(
              project.description,
              style: TextStyle(color: Colors.grey[700]),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            
            // Actions
            Row(
              children: [
                TextButton.icon(
                  onPressed: () => _viewDetailedComparison(project),
                  icon: const Icon(Icons.compare_arrows, size: 16),
                  label: const Text('Comparer en détail'),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => _reportSimilarity(project, similarity),
                  icon: const Icon(Icons.report, size: 16),
                  label: const Text('Signaler'),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _viewDetailedComparison(Project similarProject) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.8,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Comparaison détaillée',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              
              Expanded(
                child: Row(
                  children: [
                    // Original project
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Projet analysé: ${_selectedProject!.projectName}',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[300]!),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: SingleChildScrollView(
                                child: Text(_selectedProject!.description),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(width: 16),
                    
                    // Similar project
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Projet similaire: ${similarProject.projectName}',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[300]!),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: SingleChildScrollView(
                                child: Text(similarProject.description),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
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

  void _reportSimilarity(Project similarProject, double similarity) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Signaler une similarité'),
        content: Text(
          'Voulez-vous signaler cette similarité de ${(similarity * 100).round()}% entre "${_selectedProject!.projectName}" et "${similarProject.projectName}" ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Similarité signalée aux administrateurs')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Signaler', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Aide - Vérification de similarité'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Comment ça fonctionne ?',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                '• L\'outil compare le texte des descriptions de projets\n'
                '• Il calcule un pourcentage de similarité\n'
                '• Vous pouvez ajuster le seuil de détection\n'
                '• Les résultats sont classés par niveau de risque',
              ),
              SizedBox(height: 16),
              Text(
                'Niveaux de risque :',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                '• Très élevé (90%+) : Plagiat probable\n'
                '• Élevé (80-89%) : Similarité suspecte\n'
                '• Modéré (70-79%) : À vérifier\n'
                '• Faible (<70%) : Similarité normale',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Compris'),
          ),
        ],
      ),
    );
  }
}