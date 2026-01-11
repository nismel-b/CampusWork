import 'package:flutter/material.dart';
import '../../../model/user.dart';

class ProjectsToEvaluatePage extends StatelessWidget {
  final User currentUser;
  const ProjectsToEvaluatePage({super.key, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Projets à évaluer')),
      body: const Center(child: Text('Aucun projet à évaluer')),
    );
  }
}
