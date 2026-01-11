import 'package:flutter/material.dart';
import '../../../model/user.dart';
import '../../../services/survey_service.dart';
import 'create_survey_page.dart';
import 'survey_detail_page.dart';

class SurveyPage extends StatefulWidget {
  final User currentUser;

  const SurveyPage({super.key, required this.currentUser});

  @override
  State<SurveyPage> createState() => _SurveyPageState();
}

class _SurveyPageState extends State<SurveyPage> {
  final SurveyService _surveyService = SurveyService();
  List<Map<String, dynamic>> _surveys = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSurveys();
  }

  Future<void> _loadSurveys() async {
    setState(() => _isLoading = true);
    try {
      final surveys = await _surveyService.getAllSurveys();
      setState(() {
        _surveys = surveys;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  void _createSurvey() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateSurveyPage(currentUser: widget.currentUser),
      ),
    ).then((_) => _loadSurveys());
  }

  void _openSurveyDetail(Map<String, dynamic> survey) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SurveyDetailPage(
          survey: survey,
          currentUser: widget.currentUser,
        ),
      ),
    ).then((_) => _loadSurveys());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sondages'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _createSurvey,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _surveys.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.poll, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'Aucun sondage disponible',
                        style: TextStyle(color: Colors.grey[600], fontSize: 16),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _createSurvey,
                        icon: const Icon(Icons.add),
                        label: const Text('Créer un sondage'),
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

  Widget _buildSurveyCard(Map<String, dynamic> survey) {
    final totalVotes = survey['total_votes'] ?? 0;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _openSurveyDetail(survey),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundImage: survey['user_avatar'] != null
                        ? NetworkImage(survey['user_avatar'])
                        : null,
                    child: survey['user_avatar'] == null
                        ? Text(survey['username']?[0]?.toUpperCase() ?? 'U')
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          survey['username'] ?? 'Utilisateur',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          survey['created_at'] ?? '',
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.poll, color: Theme.of(context).primaryColor),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                survey['question'] ?? '',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.how_to_vote, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '$totalVotes vote${totalVotes > 1 ? 's' : ''}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  const Spacer(),
                  Text(
                    'Voir les résultats',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: Theme.of(context).primaryColor,
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
