import 'package:flutter/material.dart';
import '../../../model/user.dart';

class StudentsManagementPage extends StatelessWidget {
  final User currentUser;
  const StudentsManagementPage({super.key, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestion des étudiants')),
      body: const Center(child: Text('Liste des étudiants')),
    );
  }
}
