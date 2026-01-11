import 'package:flutter/material.dart';
import 'package:campuswork/model/user.dart';
import 'package:campuswork/model/collaboration_request.dart';
import 'package:campuswork/services/collaboration_service.dart';
import 'package:campuswork/services/project_service.dart';
import 'package:campuswork/auth/auth_service.dart';
import 'package:campuswork/components/user_avatar.dart';

class CollaborationRequestsPage extends StatefulWidget {
  final User currentUser;

  const CollaborationRequestsPage({super.key, required this.currentUser});

  @override
  State<CollaborationRequestsPage> createState() => _CollaborationRequestsPageState();
}

class _CollaborationRequestsPageState extends State<CollaborationRequestsPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final CollaborationService _collaborationService = CollaborationService();
  List<CollaborationRequest> _receivedRequests = [];
  List<CollaborationRequest> _sentRequests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadRequests();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadRequests() async {
    setState(() => _isLoading = true);
    try {
      await _collaborationService.init();
      _receivedRequests = _collaborationService.getReceivedRequests(widget.currentUser.userId);
      _sentRequests = _collaborationService.getSentRequests(widget.currentUser.userId);
    } catch (e) {
      debugPrint('Error loading requests: $e');
    }
    setState(() => _isLoading = false);
  }

  Future<void> _handleRequest(String requestId, bool accept) async {
    final success = accept
        ? await _collaborationService.acceptRequest(requestId)
        : await _collaborationService.rejectRequest(requestId);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(accept ? 'Demande acceptée' : 'Demande rejetée'),
          backgroundColor: accept ? Colors.green : Colors.orange,
        ),
      );
      _loadRequests();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Demandes de collaboration'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              text: 'Reçues (${_receivedRequests.length})',
              icon: const Icon(Icons.inbox),
            ),
            Tab(
              text: 'Envoyées (${_sentRequests.length})',
              icon: const Icon(Icons.send),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildReceivedTab(),
                _buildSentTab(),
              ],
            ),
    );
  }

  Widget _buildReceivedTab() {
    if (_receivedRequests.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Aucune demande reçue',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Les demandes de collaboration apparaîtront ici',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _receivedRequests.length,
      itemBuilder: (context, index) {
        final request = _receivedRequests[index];
        return _buildRequestCard(request, isReceived: true);
      },
    );
  }

  Widget _buildSentTab() {
    if (_sentRequests.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.send_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Aucune demande envoyée',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Vos demandes de collaboration apparaîtront ici',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _sentRequests.length,
      itemBuilder: (context, index) {
        final request = _sentRequests[index];
        return _buildRequestCard(request, isReceived: false);
      },
    );
  }

  Widget _buildRequestCard(CollaborationRequest request, {required bool isReceived}) {
    final project = ProjectService().getProjectById(request.projectId);
    final otherUserId = isReceived ? request.fromUserId : request.toUserId;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête avec utilisateur et statut
            FutureBuilder<User?>(
              future: AuthService().getUserById(otherUserId),
              builder: (context, snapshot) {
                final otherUser = snapshot.data;
                return Row(
                  children: [
                    UserAvatar(
                      userId: otherUserId,
                      name: otherUser?.fullName ?? 'Utilisateur',
                      size: 40,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            otherUser?.fullName ?? 'Utilisateur inconnu',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            isReceived ? 'Demande de collaboration' : 'Demande envoyée',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey[600],
                                ),
                          ),
                        ],
                      ),
                    ),
                    _buildStatusChip(request.status),
                  ],
                );
              },
            ),
            const SizedBox(height: 12),

            // Projet
            if (project != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.folder, color: Colors.blue),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            project.projectName,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          if (project.description.isNotEmpty)
                            Text(
                              project.description,
                              style: Theme.of(context).textTheme.bodySmall,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Message
            if (request.message != null && request.message!.isNotEmpty) ...[
              Text(
                'Message:',
                style: Theme.of(context).textTheme.labelMedium,
              ),
              const SizedBox(height: 4),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Text(
                  request.message!,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Date
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  'Envoyée le ${request.createdAt.day}/${request.createdAt.month}/${request.createdAt.year}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ],
            ),

            // Actions pour les demandes reçues en attente
            if (isReceived && request.isPending) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _handleRequest(request.requestId, false),
                      icon: const Icon(Icons.close),
                      label: const Text('Rejeter'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _handleRequest(request.requestId, true),
                      icon: const Icon(Icons.check),
                      label: const Text('Accepter'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(CollaborationStatus status) {
    Color color;
    String text;
    IconData icon;

    switch (status) {
      case CollaborationStatus.pending:
        color = Colors.orange;
        text = 'En attente';
        icon = Icons.hourglass_empty;
        break;
      case CollaborationStatus.accepted:
        color = Colors.green;
        text = 'Acceptée';
        icon = Icons.check_circle;
        break;
      case CollaborationStatus.rejected:
        color = Colors.red;
        text = 'Rejetée';
        icon = Icons.cancel;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}