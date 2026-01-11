import 'package:flutter/material.dart';
import '../../../model/user.dart';

class CollaborationTab extends StatefulWidget {
  final User currentUser;
  const CollaborationTab({super.key, required this.currentUser});

  @override
  State<CollaborationTab> createState() => _CollaborationTabState();
}

class _CollaborationTabState extends State<CollaborationTab> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: ListTile(
            leading: const Icon(Icons.search),
            title: const Text('Chercher des collaborateurs'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {},
          ),
        ),
        const SizedBox(height: 16),
        const Text('Demandes en attente', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Center(child: Text('Aucune demande')),
      ],
    );
  }
}
