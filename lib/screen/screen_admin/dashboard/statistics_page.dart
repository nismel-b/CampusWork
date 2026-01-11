import 'package:flutter/material.dart';
import '../../../model/user.dart';

class StatisticsPage extends StatefulWidget {
  final User currentUser;
  const StatisticsPage({super.key, required this.currentUser});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Statistiques')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildStatCard('Total Utilisateurs', '0', Icons.people, Colors.blue),
          _buildStatCard('Total Projets', '0', Icons.folder, Colors.green),
          _buildStatCard('Total Posts', '0', Icons.post_add, Colors.orange),
          _buildStatCard('Total Commentaires', '0', Icons.comment, Colors.purple),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: Icon(icon, color: color, size: 40),
        title: Text(title),
        trailing: Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
      ),
    );
  }
}
