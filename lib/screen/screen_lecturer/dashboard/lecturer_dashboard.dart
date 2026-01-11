import 'package:flutter/material.dart';
import '../../../model/user.dart';
import 'projects_to_evaluate_page.dart';
import 'students_management_page.dart';
import 'groups_management_page.dart';
import 'evaluation_criteria_page.dart';

class LecturerDashboard extends StatefulWidget {
  final User currentUser;
  const LecturerDashboard({super.key, required this.currentUser});

  @override
  State<LecturerDashboard> createState() => _LecturerDashboardState();
}

class _LecturerDashboardState extends State<LecturerDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tableau de bord Enseignant'),
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        children: [
          _buildCard('Projets à évaluer', Icons.assignment, Colors.blue, () {
            Navigator.push(context, MaterialPageRoute(
              builder: (context) => ProjectsToEvaluatePage(currentUser: widget.currentUser),
            ));
          }),
          _buildCard('Gestion des étudiants', Icons.people, Colors.green, () {
            Navigator.push(context, MaterialPageRoute(
              builder: (context) => StudentsManagementPage(currentUser: widget.currentUser),
            ));
          }),
          _buildCard('Gestion des groupes', Icons.group, Colors.orange, () {
            Navigator.push(context, MaterialPageRoute(
              builder: (context) => GroupsManagementPage(currentUser: widget.currentUser),
            ));
          }),
          _buildCard('Critères d\'évaluation', Icons.checklist, Colors.purple, () {
            Navigator.push(context, MaterialPageRoute(
              builder: (context) => EvaluationCriteriaPage(currentUser: widget.currentUser),
            ));
          }),
        ],
      ),
    );
  }

  Widget _buildCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 12),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
