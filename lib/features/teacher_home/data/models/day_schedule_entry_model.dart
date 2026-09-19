/// One entry from `GET teacher/schedule` (TeacherScheduleController).
class DayScheduleEntryModel {
  final String day;
  final String subject;
  final String className;
  final String sectionName;
  final String? room;
  final String? startTime;
  final String? endTime;

  const DayScheduleEntryModel({
    required this.day,
    required this.subject,
    required this.className,
    required this.sectionName,
    this.room,
    this.startTime,
    this.endTime,
  });

  String get classLabel => '$subject / $className / $sectionName';

  factory DayScheduleEntryModel.fromJson(Map<String, dynamic> json) => DayScheduleEntryModel(
        day: (json['day'] ?? '').toString(),
        subject: (json['subject'] ?? '').toString(),
        className: (json['class_name'] ?? '').toString(),
        sectionName: (json['section_name'] ?? '').toString(),
        room: json['room']?.toString(),
        startTime: json['start_time']?.toString(),
        endTime: json['end_time']?.toString(),
      );
}
