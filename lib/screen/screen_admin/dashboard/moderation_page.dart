import 'package:flutter/material.dart';
import '../../../model/user.dart';

class ModerationPage extends StatefulWidget {
  final User currentUser;
  const ModerationPage({super.key, required this.currentUser});

  @override
  State<ModerationPage> createState() => _ModerationPageState();
}

class _ModerationPageState extends State<ModerationPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Modération')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.gavel, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text('Aucun signalement', style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }
}
