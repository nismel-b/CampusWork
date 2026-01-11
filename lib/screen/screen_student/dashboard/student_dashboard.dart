import 'package:flutter/material.dart';
import '../../../model/user.dart';
import '../projects/projects_list_page.dart';
import '../courses/courses_page.dart';
import '../team/team_page.dart';

class StudentDashboard extends StatefulWidget {
  final User currentUser;
  const StudentDashboard({super.key, required this.currentUser});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tableau de bord Étudiant')),
      body: GridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        children: [
          _buildCard('Mes Projets', Icons.folder, Colors.blue, () {
            Navigator.push(context, MaterialPageRoute(
              builder: (context) => ProjectsListPage(currentUser: widget.currentUser),
            ));
          }),
          _buildCard('Mes Cours', Icons.book, Colors.green, () {
            Navigator.push(context, MaterialPageRoute(
              builder: (context) => CoursesPage(currentUser: widget.currentUser),
            ));
          }),
          _buildCard('Mon Équipe', Icons.group, Colors.orange, () {
            Navigator.push(context, MaterialPageRoute(
              builder: (context) => TeamPage(currentUser: widget.currentUser),
            ));
          }),
          _buildCard('Nouveau Projet', Icons.add_circle, Colors.purple, () {
            // Navigate to create project
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
