import 'package:flutter/material.dart';
import '../../../model/user.dart';
import '../../../services/survey_service.dart';

class SurveyDetailPage extends StatefulWidget {
  final Map<String, dynamic> survey;
  final User currentUser;

  const SurveyDetailPage({
    super.key,
    required this.survey,
    required this.currentUser,
  });

  @override
  State<SurveyDetailPage> createState() => _SurveyDetailPageState();
}

class _SurveyDetailPageState extends State<SurveyDetailPage> {
  final SurveyService _surveyService = SurveyService();
  List<String> _options = [];
  String? _selectedOption;
  bool _hasVoted = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSurveyDetails();
  }

  Future<void> _loadSurveyDetails() async {
    setState(() => _isLoading = true);
    try {
      final options = await _surveyService.getSurveyOptions(widget.survey['surveyId'] ?? widget.survey['survey_id'] ?? '');
      final hasVoted = await _surveyService.hasUserVoted(
        widget.survey['surveyId'] ?? widget.survey['survey_id'] ?? '',
        widget.currentUser.userId,
      );
      
      setState(() {
        _options = options;
        _hasVoted = hasVoted;
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

  Future<void> _vote() async {
    if (_selectedOption == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sélectionnez une option')),
      );
      return;
    }

    try {
      final success = await _surveyService.vote(
        widget.survey['surveyId'] ?? widget.survey['survey_id'] ?? '',
        widget.currentUser.userId,
        _selectedOption!,
      );

      if (success) {
        setState(() => _hasVoted = true);
        _loadSurveyDetails();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Vote enregistré')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sondage'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildQuestion(),
                  const SizedBox(height: 24),
                  _buildOptions(),
                  if (!_hasVoted) ...[
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _vote,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Voter'),
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        CircleAvatar(
          backgroundImage: widget.survey['user_avatar'] != null
              ? NetworkImage(widget.survey['user_avatar'])
              : null,
          child: widget.survey['user_avatar'] == null
              ? Text(widget.survey['username']?[0]?.toUpperCase() ?? 'U')
              : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.survey['username'] ?? 'Utilisateur',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                widget.survey['created_at'] ?? widget.survey['createdAt'] ?? '',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuestion() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          widget.survey['question'] ?? '',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildOptions() {
    return Column(
      children: _options.asMap().entries.map((entry) {
        final index = entry.key;
        final option = entry.value;
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _hasVoted
              ? _buildResultOption(option, 0.0, 0) // Placeholder values for results
              : _buildVoteOption(option, index.toString()),
        );
      }).toList(),
    );
  }

  Widget _buildVoteOption(String option, String optionId) {
    return RadioListTile<String>(
      value: optionId,
      groupValue: _selectedOption,
      onChanged: (value) => setState(() => _selectedOption = value),
      title: Text(option),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: _selectedOption == optionId
              ? Theme.of(context).primaryColor
              : Colors.grey[300]!,
        ),
      ),
    );
  }

  Widget _buildResultOption(
    String option,
    double percentage,
    int voteCount,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  option,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              Text(
                '${percentage.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage / 100,
              minHeight: 8,
              backgroundColor: Colors.grey[200],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$voteCount vote${voteCount > 1 ? 's' : ''}',
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ],
      ),
    );
  }
}