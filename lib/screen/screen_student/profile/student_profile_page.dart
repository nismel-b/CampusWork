import 'package:flutter/material.dart';
import '../../../model/user.dart';
import 'collaboration_tab.dart';

class StudentProfilePage extends StatelessWidget {
  final User currentUser;
  const StudentProfilePage({super.key, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Mon Profil'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Profil', icon: Icon(Icons.person)),
              Tab(text: 'Collaboration', icon: Icon(Icons.handshake)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Center(child: Text('Profil de ${currentUser.username}')),
            CollaborationTab(currentUser: currentUser),
          ],
        ),
      ),
    );
  }
}
