class MessageModel {
  final int id;
  final int senderId;
  final int recipientId;
  final String body;
  final String createdAt;
  final bool isMine;

  const MessageModel({
    required this.id,
    required this.senderId,
    required this.recipientId,
    required this.body,
    required this.createdAt,
    required this.isMine,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) => MessageModel(
        id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}') ?? 0,
        senderId: json['sender_id'] is int
            ? json['sender_id'] as int
            : int.tryParse('${json['sender_id']}') ?? 0,
        recipientId: json['recipient_id'] is int
            ? json['recipient_id'] as int
            : int.tryParse('${json['recipient_id']}') ?? 0,
        body: (json['body'] ?? '').toString(),
        createdAt: (json['created_at'] ?? '').toString(),
        isMine: json['is_mine'] == true,
      );
}
