class RoutineEntryModel {
  final Map<String, dynamic> raw;

  const RoutineEntryModel(this.raw);

  String get day => _firstString(['day', 'day_name']) ?? '';
  String? get subject => _firstString(['subject_name', 'subject']);
  String? get startTime => _firstString(['start_time', 'from_time']);
  String? get endTime => _firstString(['end_time', 'to_time']);
  String? get room => _firstString(['room_name', 'room']);

  String? _firstString(List<String> keys) {
    for (final key in keys) {
      final value = raw[key];
      if (value != null && value.toString().trim().isNotEmpty) return value.toString();
    }
    return null;
  }

  factory RoutineEntryModel.fromJson(Map<String, dynamic> json) => RoutineEntryModel(json);
}
