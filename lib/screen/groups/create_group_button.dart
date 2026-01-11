import 'package:flutter/material.dart';
import 'package:campuswork/screen/groups/group_formulaire.dart';
import 'package:campuswork/model/user.dart';

class CreateGroupButton extends StatelessWidget {
  final User currentUser;
  final VoidCallback? onGroupCreated;

  const CreateGroupButton({
    super.key,
    required this.currentUser,
    this.onGroupCreated,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => _showCreateGroupDialog(context),
      icon: const Icon(Icons.group_add),
      label: const Text('Créer un groupe'),
      backgroundColor: Theme.of(context).primaryColor,
    );
  }

  void _showCreateGroupDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.8,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Créer un nouveau groupe',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: GroupFormulaire(
                  currentUser: currentUser,
                  onGroupCreated: () {
                    Navigator.pop(context);
                    onGroupCreated?.call();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Version compacte pour les dashboards
class CreateGroupIconButton extends StatelessWidget {
  final User currentUser;
  final VoidCallback? onGroupCreated;

  const CreateGroupIconButton({
    super.key,
    required this.currentUser,
    this.onGroupCreated,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => _showCreateGroupBottomSheet(context),
      icon: const Icon(Icons.group_add),
      tooltip: 'Créer un groupe',
    );
  }

  void _showCreateGroupBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Créer un nouveau groupe',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Divider(),
            Expanded(
              child: GroupFormulaire(
                currentUser: currentUser,
                onGroupCreated: () {
                  Navigator.pop(context);
                  onGroupCreated?.call();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}