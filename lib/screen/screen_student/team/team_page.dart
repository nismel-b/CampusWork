import 'package:flutter/material.dart';
import '../../../model/user.dart';

class TeamPage extends StatelessWidget {
  final User currentUser;
  const TeamPage({super.key, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mon Équipe')),
      body: const Center(child: Text('Membres de l\'équipe')),
    );
  }
}
