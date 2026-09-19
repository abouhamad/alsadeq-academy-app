/// From the legacy `teacher-section-list` endpoint (`section_id`/`section_name`
/// on both the admin and teacher branches).
class SectionOptionModel {
  final int id;
  final String name;

  const SectionOptionModel({required this.id, required this.name});

  factory SectionOptionModel.fromJson(Map<String, dynamic> json) {
    final rawId = json['section_id'];
    return SectionOptionModel(
      id: rawId is int ? rawId : int.tryParse('$rawId') ?? 0,
      name: (json['section_name'] ?? '').toString(),
    );
  }
}
