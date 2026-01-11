import 'package:flutter/material.dart';
import '../../../model/user.dart';

class CoursesPage extends StatelessWidget {
  final User currentUser;
  const CoursesPage({super.key, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mes Cours')),
      body: const Center(child: Text('Liste des cours')),
    );
  }
}
