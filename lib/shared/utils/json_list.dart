/// Backend list endpoints don't consistently nest under the same key inside
/// `data` (sometimes `data` IS the list, sometimes it's
/// `{data: [...]}`, `{student_list: [...]}`, etc. across SmApiController
/// methods). This pulls out "the list" defensively instead of one repo per
/// endpoint hardcoding a specific key that may not match.
List<Map<String, dynamic>> extractJsonList(dynamic payload) {
  if (payload == null) return const [];
  if (payload is List) {
    return payload.whereType<Map>().map((e) => e.cast<String, dynamic>()).toList();
  }
  if (payload is Map) {
    for (final value in payload.values) {
      if (value is List && value.isNotEmpty && value.first is Map) {
        return value.whereType<Map>().map((e) => e.cast<String, dynamic>()).toList();
      }
    }
  }
  return const [];
}
