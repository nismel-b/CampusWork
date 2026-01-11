import 'package:flutter/material.dart';
import 'package:campuswork/services/project_service.dart';
import 'package:campuswork/model/project.dart';
import 'project_card.dart';

class ProjectsListPage extends StatefulWidget {
  const ProjectsListPage({super.key});

  @override
  State<ProjectsListPage> createState() => _ProjectsListPageState();
}

class _ProjectsListPageState extends State<ProjectsListPage> {
  final _searchController = TextEditingController();
  String? _selectedCourse;
  ProjectState? _selectedState;
  List<Project> _projects = [];

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadProjects() {
    setState(() {
      _projects = ProjectService().searchProjects(
        _searchController.text,
        courseName: _selectedCourse,
        state: _selectedState?.toString().split('.').last,
      );
    });
  }

  void _showFilterSheet() {
    final courses = ProjectService().getAllCourses();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filtres',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedCourse = null;
                      _selectedState = null;
                    });
                    _loadProjects();
                    Navigator.pop(context);
                  },
                  child: const Text('Réinitialiser'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Cours',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: courses.map((course) => FilterChip(
                label: Text(course),
                selected: _selectedCourse == course,
                onSelected: (selected) {
                  setState(() => _selectedCourse = selected ? course : null);
                },
              )).toList(),
            ),
            const SizedBox(height: 24),
            Text(
              'État',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ProjectState.values.map((state) {
                final label = state == ProjectState.enCours
                    ? 'En cours'
                    : state == ProjectState.termine
                    ? 'Terminé'
                    : 'Noté';
                return FilterChip(
                  label: Text(label),
                  selected: _selectedState == state,
                  onSelected: (selected) {
                    setState(() => _selectedState = selected ? state : null);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                _loadProjects();
                Navigator.pop(context);
              },
              child: const Text('Appliquer'),
            ),
            SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explorer les projets'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Rechercher un projet...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _loadProjects();
                          },
                        )
                            : null,
                      ),
                      onChanged: (_) => _loadProjects(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: (_selectedCourse != null || _selectedState != null)
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: (_selectedCourse != null || _selectedState != null)
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).dividerColor,
                      ),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.filter_list,
                        color: (_selectedCourse != null || _selectedState != null)
                            ? Colors.white
                            : Theme.of(context).iconTheme.color,
                      ),
                      onPressed: _showFilterSheet,
                      tooltip: 'Filtres',
                    ),
                  ),
                ],
              ),
            ),
            if (_selectedCourse != null || _selectedState != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Wrap(
                  spacing: 8,
                  children: [
                    if (_selectedCourse != null)
                      Chip(
                        label: Text(_selectedCourse!),
                        deleteIcon: const Icon(Icons.close, size: 18),
                        onDeleted: () {
                          setState(() => _selectedCourse = null);
                          _loadProjects();
                        },
                      ),
                    if (_selectedState != null)
                      Chip(
                        label: Text(_selectedState == ProjectState.enCours
                            ? 'En cours'
                            : _selectedState == ProjectState.termine
                            ? 'Terminé'
                            : 'Noté'),
                        deleteIcon: const Icon(Icons.close, size: 18),
                        onDeleted: () {
                          setState(() => _selectedState = null);
                          _loadProjects();
                        },
                      ),
                  ],
                ),
              ),
            const SizedBox(height: 8),
            Expanded(
              child: _projects.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search_off,
                      size: 64,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Aucun projet trouvé',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              )
                  : ListView.builder(
                itemCount: _projects.length,
                itemBuilder: (context, index) => ProjectCard(
                  project: _projects[index],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
