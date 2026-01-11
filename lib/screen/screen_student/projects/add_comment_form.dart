import 'package:flutter/material.dart';
import 'package:campuswork/model/user.dart';
import 'package:campuswork/model/comment.dart';
import 'package:campuswork/services/comment_service.dart';
import 'package:campuswork/components/components.dart';
import 'package:uuid/uuid.dart';

class AddCommentForm extends StatefulWidget {
  final String projectId;
  final User currentUser;
  final VoidCallback? onCommentAdded;
  final Comment? parentComment; // Pour les réponses
  final bool isReply;

  const AddCommentForm({
    super.key,
    required this.projectId,
    required this.currentUser,
    this.onCommentAdded,
    this.parentComment,
    this.isReply = false,
  });

  @override
  State<AddCommentForm> createState() => _AddCommentFormState();
}

class _AddCommentFormState extends State<AddCommentForm> {
  final _commentController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête
            Row(
              children: [
                UserAvatar(
                  userId: widget.currentUser.userId,
                  name: widget.currentUser.fullName,
                  size: 40,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.isReply 
                            ? 'Répondre à ${widget.parentComment?.userFullName}'
                            : 'Ajouter un commentaire',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      Text(
                        widget.currentUser.fullName,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Commentaire parent (si c'est une réponse)
            if (widget.isReply && widget.parentComment != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.reply, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          'En réponse à ${widget.parentComment!.userFullName}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.parentComment!.content,
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

            // Champ de commentaire
            TextFormField(
              controller: _commentController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: widget.isReply 
                    ? 'Écrivez votre réponse...'
                    : 'Partagez vos pensées sur ce projet...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Le commentaire ne peut pas être vide';
                }
                if (value.trim().length < 3) {
                  return 'Le commentaire doit contenir au moins 3 caractères';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Boutons d'action
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    child: const Text('Annuler'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitComment,
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(widget.isReply ? 'Répondre' : 'Commenter'),
                  ),
                ),
              ],
            ),

            // Espace pour le clavier
            SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
          ],
        ),
      ),
    );
  }

  Future<void> _submitComment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final comment = Comment(
        commentId: const Uuid().v4(),
        projectId: widget.projectId,
        userId: widget.currentUser.userId,
        userFullName: widget.currentUser.fullName,
        content: _commentController.text.trim(),
        createdAt: DateTime.now(),
      );

      final success = await CommentService().addComment(comment);

      if (mounted) {
        setState(() => _isLoading = false);
        
        if (success) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.isReply 
                  ? 'Réponse ajoutée avec succès'
                  : 'Commentaire ajouté avec succès'),
              backgroundColor: Colors.green,
            ),
          );
          widget.onCommentAdded?.call();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erreur lors de l\'ajout du commentaire'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

// Widget pour afficher le formulaire dans un bottom sheet
class CommentBottomSheet extends StatelessWidget {
  final String projectId;
  final User currentUser;
  final VoidCallback? onCommentAdded;
  final Comment? parentComment;

  const CommentBottomSheet({
    super.key,
    required this.projectId,
    required this.currentUser,
    this.onCommentAdded,
    this.parentComment,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: AddCommentForm(
              projectId: projectId,
              currentUser: currentUser,
              onCommentAdded: onCommentAdded,
              parentComment: parentComment,
              isReply: parentComment != null,
            ),
          ),
        );
      },
    );
  }
}

// Fonction utilitaire pour afficher le formulaire de commentaire
void showCommentForm({
  required BuildContext context,
  required String projectId,
  required User currentUser,
  VoidCallback? onCommentAdded,
  Comment? parentComment,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => CommentBottomSheet(
      projectId: projectId,
      currentUser: currentUser,
      onCommentAdded: onCommentAdded,
      parentComment: parentComment,
    ),
  );
}

// Widget compact pour déclencher l'ajout de commentaire
class AddCommentButton extends StatelessWidget {
  final String projectId;
  final User currentUser;
  final VoidCallback? onCommentAdded;
  final bool isCompact;

  const AddCommentButton({
    super.key,
    required this.projectId,
    required this.currentUser,
    this.onCommentAdded,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isCompact) {
      return IconButton(
        onPressed: () => _showCommentForm(context),
        icon: const Icon(Icons.comment),
        tooltip: 'Ajouter un commentaire',
      );
    }

    return InkWell(
      onTap: () => _showCommentForm(context),
      borderRadius: BorderRadius.circular(25),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            UserAvatar(
              userId: currentUser.userId,
              name: currentUser.fullName,
              size: 32,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Ajouter un commentaire...',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ),
            Icon(Icons.comment, color: Colors.grey[600], size: 20),
          ],
        ),
      ),
    );
  }

  void _showCommentForm(BuildContext context) {
    showCommentForm(
      context: context,
      projectId: projectId,
      currentUser: currentUser,
      onCommentAdded: onCommentAdded,
    );
  }
}