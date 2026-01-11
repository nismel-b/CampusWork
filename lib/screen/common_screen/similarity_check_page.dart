import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:campuswork/services/similarity_service.dart';
import 'package:campuswork/screen/screen_student/projects/project_card.dart';
import 'package:intl/intl.dart';

class SimilarityCheckPage extends StatefulWidget {
  final String projectName;
  final String description;
  final String? courseName;
  final List<String> resources;
  final List<String> tags;

  const SimilarityCheckPage({
    super.key,
    required this.projectName,
    required this.description,
    this.courseName,
    this.resources = const [],
    this.tags = const [],
  });

  @override
  State<SimilarityCheckPage> createState() => _SimilarityCheckPageState();
}

class _SimilarityCheckPageState extends State<SimilarityCheckPage> {
  List<SimilarProject> _similarProjects = [];
  List<String> _suggestions = [];
  bool _isLoading = true;
  bool _userAcknowledged = false;

  @override
  void initState() {
    super.initState();
    _checkSimilarity();
  }

  Future<void> _checkSimilarity() async {
    setState(() => _isLoading = true);

    try {
      final similarProjects = await SimilarityService().checkProjectSimilarity(
        projectName: widget.projectName,
        description: widget.description,
        courseName: widget.courseName,
        resources: widget.resources,
        tags: widget.tags,
      );

      final suggestions = SimilarityService().suggestImprovements(similarProjects);

      setState(() {
        _similarProjects = similarProjects;
        _suggestions = suggestions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la vérification: $e'),
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
        title: const Text('Vérification de similarité'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(false), // Retourner false = annuler
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Résumé du projet
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Votre projet',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.projectName,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.description,
                            style: Theme.of(context).textTheme.bodyMedium,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (widget.courseName != null) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.school, size: 16),
                                const SizedBox(width: 4),
                                Text(widget.courseName!),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Résultats de la vérification
                  if (_similarProjects.isEmpty)
                    _buildNoSimilarityFound()
                  else
                    _buildSimilarityResults(),

                  const SizedBox(height: 24),

                  // Actions
                  _buildActionButtons(),
                ],
              ),
            ),
    );
  }

  Widget _buildNoSimilarityFound() {
    return Card(
      color: Colors.green.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 64,
              color: Colors.green[600],
            ),
            const SizedBox(height: 16),
            Text(
              'Aucun projet similaire trouvé',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.green[700],
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Votre projet semble unique ! Vous pouvez continuer la création.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.green[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimilarityResults() {
    final highSimilarity = _similarProjects.where((p) => p.score >= 0.7).toList();
    final mediumSimilarity = _similarProjects.where((p) => p.score >= 0.5 && p.score < 0.7).toList();
    final lowSimilarity = _similarProjects.where((p) => p.score < 0.5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Alerte si similarité élevée
        if (highSimilarity.isNotEmpty)
          Card(
            color: Colors.red.withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.warning, color: Colors.red[600]),
                      const SizedBox(width: 8),
                      Text(
                        'Attention : Projets très similaires détectés',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Colors.red[700],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Nous avons trouvé ${highSimilarity.length} projet(s) très similaire(s) au vôtre. '
                    'Considérez modifier votre approche pour vous différencier.',
                    style: TextStyle(color: Colors.red[600]),
                  ),
                ],
              ),
            ),
          ),

        const SizedBox(height: 16),

        // Liste des projets similaires
        Text(
          'Projets similaires trouvés (${_similarProjects.length})',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),

        ...(_similarProjects.take(3).map((similarProject) => 
          _buildSimilarProjectCard(similarProject))),

        if (_similarProjects.length > 3) ...[
          const SizedBox(height: 8),
          Center(
            child: TextButton(
              onPressed: () {
                // TODO: Afficher tous les projets similaires
              },
              child: Text('Voir ${_similarProjects.length - 3} autres projets similaires'),
            ),
          ),
        ],

        const SizedBox(height: 24),

        // Suggestions d'amélioration
        if (_suggestions.isNotEmpty) ...[
          Text(
            'Suggestions pour vous différencier',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            color: Theme.of(context).colorScheme.surfaceVariant,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Conseils',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ..._suggestions.map((suggestion) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('• ', style: TextStyle(color: Theme.of(context).primaryColor)),
                        Expanded(child: Text(suggestion)),
                      ],
                    ),
                  )),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSimilarProjectCard(SimilarProject similarProject) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    similarProject.project.projectName,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: similarProject.severityColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: similarProject.severityColor),
                  ),
                  child: Text(
                    '${similarProject.scorePercentage} similaire',
                    style: TextStyle(
                      color: similarProject.severityColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              similarProject.project.description,
              style: Theme.of(context).textTheme.bodyMedium,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              similarProject.project.createdAt != null 
                  ? 'Créé le ${similarProject.project.createdAt}'
                  : 'Date de création inconnue',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Raisons de la similarité:',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            ...similarProject.reasons.map((reason) => Padding(
              padding: const EdgeInsets.only(left: 8, bottom: 2),
              child: Text(
                '• $reason',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_similarProjects.isNotEmpty) ...[
          CheckboxListTile(
            value: _userAcknowledged,
            onChanged: (value) => setState(() => _userAcknowledged = value ?? false),
            title: const Text('J\'ai pris connaissance des projets similaires'),
            subtitle: const Text('Je confirme que mon projet apporte une valeur unique'),
            controlAffinity: ListTileControlAffinity.leading,
          ),
          const SizedBox(height: 16),
        ],

        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => context.pop(false), // Retourner pour modifier
                child: const Text('Modifier mon projet'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: (_similarProjects.isEmpty || _userAcknowledged)
                    ? () => context.pop(true) // Continuer la création
                    : null,
                child: const Text('Continuer'),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        TextButton(
          onPressed: () => context.pop(false),
          child: const Text('Annuler la création'),
        ),
      ],
    );
  }
}