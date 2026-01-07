class Message{
  final String messageId;
  final String senderId;
  final String receiverId;
  final String content;
  final bool isRead;
  final bool synced;
  final DateTime createdAt;

  Message(
    {
      required this.messageId,
      required this.senderId,
      required this.receiverId,
      required this.content,
      required this.isRead,
      required this.synced,
      required this.createdAt,
    }
  );
}