import 'package:flutter/material.dart';
import 'package:store_buy/service/survey_service.dart';


/// Écran pour gérer les sondages (vendeurs)
class SurveysScreen extends StatefulWidget {
  final String storeId;
  const SurveysScreen({super.key, required this.storeId});

  @override
  State<SurveysScreen> createState() => _SurveysScreenState();
}

class _SurveysScreenState extends State<SurveysScreen> {
  final SurveyService _surveyService = SurveyService();
  final TextEditingController _questionController = TextEditingController();
  List<Map<String, dynamic>> _surveys = [];
  bool _isLoading = true;
  final String _selectedType = 'yes_no';
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
    final surveys = await _surveyService.getActiveSurveys(widget.storeId);
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
      storeId: widget.storeId,
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
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Réponses'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: responses.length,
              itemBuilder: (context, index) {
                final response = responses[index];
                return ListTile(
                  title: Text(response['userName'] ?? 'Utilisateur'),
                  subtitle: Text(response['answer']),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fermer'),
            ),
          ],
        ),
      );
    }
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
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          leading: const Icon(Icons.poll, color: Color(0xFF3B82F6)),
                          title: Text(survey['question'] ?? ''),
                          subtitle: Text('Type: ${survey['type']}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.visibility),
                            onPressed: () => _viewResponses(survey['surveyId']),
                          ),
                          onLongPress: () async {
                            final delete = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Supprimer'),
                                content: const Text('Supprimer ce sondage?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: const Text('Annuler'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              ),
                            );
                            if (delete == true) {
                              await _surveyService.deleteSurvey(survey['surveyId']);
                              _loadSurveys();
                            }
                          },
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  void _showCreateSurveyDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Créer un sondage'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _questionController,
                  decoration: const InputDecoration(
                    labelText: 'Question',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 20),
                const Text('Type de réponse:'),
               /* RadioListTile<String>(
                  title: const Text('Oui/Non'),
                  value: 'yes_no',
                  groupValue: _selectedType,
                  onChanged: (value) => setState(() => _selectedType = value!),
                ),
                RadioListTile<String>(
                  title: const Text('Choix multiples'),
                  value: 'multiple_choice',
                  groupValue: _selectedType,
                  onChanged: (value) => setState(() => _selectedType = value!),
                ),
                RadioListTile<String>(
                  title: const Text('Texte libre'),
                  value: 'text',
                  groupValue: _selectedType,
                  onChanged: (value) => setState(() => _selectedType = value!),
                ),*/
                if (_selectedType == 'multiple_choice') ...[
                  const SizedBox(height: 10),
                  ...List.generate(_optionControllers.length, (index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _optionControllers[index],
                              decoration: InputDecoration(
                                labelText: 'Option ${index + 1}',
                                border: const OutlineInputBorder(),
                              ),
                            ),
                          ),
                          if (_optionControllers.length > 1)
                            IconButton(
                              icon: const Icon(Icons.remove_circle, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  _optionControllers[index].dispose();
                                  _optionControllers.removeAt(index);
                                });
                              },
                            ),
                        ],
                      ),
                    );
                  }),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _optionControllers.add(TextEditingController());
                      });
                    },
                    child: const Text('+ Ajouter une option'),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: _createSurvey,
              child: const Text('Créer'),
            ),
          ],
        ),
      ),
    );
  }
}


