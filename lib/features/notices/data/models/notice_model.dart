/// Maps `NoticesController@list`'s fixed response shape
/// (id, notice_title, notice_message, notice_date, publish_on).
class NoticeModel {
  final int id;
  final String title;
  final String? message;
  final String? date;

  const NoticeModel({
    required this.id,
    required this.title,
    this.message,
    this.date,
  });

  factory NoticeModel.fromJson(Map<String, dynamic> json) => NoticeModel(
        id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}') ?? 0,
        title: (json['notice_title'] ?? 'Notice').toString(),
        message: json['notice_message']?.toString(),
        date: (json['notice_date'] ?? json['publish_on'])?.toString(),
      );
}
