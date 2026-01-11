import 'package:flutter/material.dart';
import '../../../model/user.dart';

class EvaluationCriteriaPage extends StatelessWidget {
  final User currentUser;
  const EvaluationCriteriaPage({super.key, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Critères d\'évaluation')),
      body: const Center(child: Text('Critères d\'évaluation')),
    );
  }
}
