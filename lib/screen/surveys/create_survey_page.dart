import 'package:flutter/material.dart';
import 'package:campuswork/model/user.dart';
import 'package:campuswork/services/survey_service.dart';
import 'package:uuid/uuid.dart';

class CreateSurveyPage extends StatefulWidget {
  final User currentUser;

  const CreateSurveyPage({super.key, required this.currentUser});

  @override
  State<CreateSurveyPage> createState() => _CreateSurveyPageState();
}

class _CreateSurveyPageState extends State<CreateSurveyPage> {
  final _formKey = GlobalKey<FormState>();
  final _questionController = TextEditingController();
  final _optionsControllers = <TextEditingController>[];
  String _selectedType = 'multiple_choice';
  DateTime? _expiresAt;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Ajouter deux options par défaut
    _addOption();
    _addOption();
  }

  @override
  void dispose() {
    _questionController.dispose();
    for (var controller in _optionsControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addOption() {
    setState(() {
      _optionsControllers.add(TextEditingController());
    });
  }

  void _removeOption(int index) {
    if (_optionsControllers.length > 2) {
      setState(() {
        _optionsControllers[index].dispose();
        _optionsControllers.removeAt(index);
      });
    }
  }

  Future<void> _createSurvey() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final options = _optionsControllers
          .map((controller) => controller.text.trim())
          .where((text) => text.isNotEmpty)
          .toList();

      final success = await SurveyService().createSurvey(
        surveyId: const Uuid().v4(),
        userId: widget.currentUser.userId,
        question: _questionController.text.trim(),
        type: _selectedType,
        options: options,
        expiresAt: _expiresAt,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sondage créé avec succès'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors de la création du sondage'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Créer un sondage'),
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _createSurvey,
              child: const Text('Créer'),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Question
              TextFormField(
                controller: _questionController,
                decoration: const InputDecoration(
                  labelText: 'Question du sondage',
                  border: OutlineInputBorder(),
                  hintText: 'Posez votre question...',
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Veuillez saisir une question';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Type de sondage
              Text(
                'Type de sondage',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'multiple_choice',
                    child: Text('Choix multiple'),
                  ),
                  DropdownMenuItem(
                    value: 'single_choice',
                    child: Text('Choix unique'),
                  ),
                  DropdownMenuItem(
                    value: 'text',
                    child: Text('Réponse libre'),
                  ),
                ],
                onChanged: (value) {
                  setState(() => _selectedType = value!);
                },
              ),
              const SizedBox(height: 24),

              // Options (seulement pour les choix multiples/uniques)
              if (_selectedType != 'text') ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Options de réponse',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    IconButton(
                      onPressed: _addOption,
                      icon: const Icon(Icons.add),
                      tooltip: 'Ajouter une option',
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ..._optionsControllers.asMap().entries.map((entry) {
                  final index = entry.key;
                  final controller = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: controller,
                            decoration: InputDecoration(
                              labelText: 'Option ${index + 1}',
                              border: const OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Option requise';
                              }
                              return null;
                            },
                          ),
                        ),
                        if (_optionsControllers.length > 2)
                          IconButton(
                            onPressed: () => _removeOption(index),
                            icon: const Icon(Icons.remove_circle, color: Colors.red),
                          ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 24),
              ],

              // Date d'expiration
              Text(
                'Date d\'expiration (optionnel)',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now().add(const Duration(days: 7)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (time != null) {
                      setState(() {
                        _expiresAt = DateTime(
                          date.year,
                          date.month,
                          date.day,
                          time.hour,
                          time.minute,
                        );
                      });
                    }
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today),
                      const SizedBox(width: 12),
                      Text(
                        _expiresAt == null
                            ? 'Sélectionner une date d\'expiration'
                            : 'Expire le ${_expiresAt!.day}/${_expiresAt!.month}/${_expiresAt!.year} à ${_expiresAt!.hour}:${_expiresAt!.minute.toString().padLeft(2, '0')}',
                      ),
                      const Spacer(),
                      if (_expiresAt != null)
                        IconButton(
                          onPressed: () => setState(() => _expiresAt = null),
                          icon: const Icon(Icons.clear),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Bouton de création
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _createSurvey,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Créer le sondage'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}