/// Maps the backend's integer `role_id` (see app/User.php + database seeders)
/// to app-level roles. Everything not explicitly listed is treated as
/// generic staff and currently unsupported by this app's navigation.
enum AppRole {
  superAdmin(1),
  student(2),
  parent(3),
  teacher(4),
  admin(5),
  accountant(6),
  receptionist(7),
  librarian(8),
  driver(9),
  unknown(-1);

  final int id;
  const AppRole(this.id);

  static AppRole fromId(int? id) {
    return AppRole.values.firstWhere(
      (role) => role.id == id,
      orElse: () => AppRole.unknown,
    );
  }

  bool get isSupported =>
      this == AppRole.student || this == AppRole.parent || this == AppRole.teacher;
}
