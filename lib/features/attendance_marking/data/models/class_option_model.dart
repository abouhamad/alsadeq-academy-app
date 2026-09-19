/// From the legacy `teacher-class-list` endpoint. Field names differ by
/// branch server-side (admin rows use `id`, teacher rows use `class_id`),
/// so this falls back across both like the app's other legacy-endpoint
/// models do.
class ClassOptionModel {
  final int id;
  final String name;

  const ClassOptionModel({required this.id, required this.name});

  factory ClassOptionModel.fromJson(Map<String, dynamic> json) {
    final rawId = json['class_id'] ?? json['id'];
    return ClassOptionModel(
      id: rawId is int ? rawId : int.tryParse('$rawId') ?? 0,
      name: (json['class_name'] ?? '').toString(),
    );
  }
}
