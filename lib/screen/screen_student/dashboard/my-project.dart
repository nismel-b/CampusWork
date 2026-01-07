import 'package:flutter/material.dart';
import 'package:campuswork/auth/auth_service.dart';
import 'package:campuswork/services/project-services.dart';
import 'package:campuswork/components/projects/project_card.dart';

class MyProjectsPage extends StatelessWidget {
  const MyProjectsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = AuthService().currentUser;
    final projects = ProjectService().getProjectsByStudent(currentUser!.userId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes projets'),
      ),
      body: SafeArea(
        child: projects.isEmpty
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.folder_open,
                size: 64,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
              const SizedBox(height: 16),
              Text(
                'Aucun projet pour le moment',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        )
            : ListView.builder(
          itemCount: projects.length,
          itemBuilder: (context, index) => ProjectCard(
            project: projects[index],
          ),
        ),
      ),
    );
  }
}
