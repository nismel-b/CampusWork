import 'package:flutter/material.dart';
import '../../../model/user.dart';

class GroupsManagementPage extends StatelessWidget {
  final User currentUser;
  const GroupsManagementPage({super.key, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestion des groupes')),
      body: const Center(child: Text('Gestion des groupes')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}
