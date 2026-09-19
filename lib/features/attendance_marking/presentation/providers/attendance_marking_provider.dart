import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/providers.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/attendance_marking_repository.dart';
import '../../data/models/class_option_model.dart';
import '../../data/models/roster_student_model.dart';
import '../../data/models/section_option_model.dart';

final attendanceMarkingRepositoryProvider = Provider<AttendanceMarkingRepository>((ref) {
  return AttendanceMarkingRepository(ref.watch(apiClientProvider));
});

class AttendanceMarkingState {
  final List<ClassOptionModel> classes;
  final List<SectionOptionModel> sections;
  final int? classId;
  final int? sectionId;
  final DateTime date;
  final List<RosterStudentModel> roster;
  final Map<int, String> statusByStudent;
  final bool isLoading;
  final bool isSaving;
  final String? error;

  const AttendanceMarkingState({
    this.classes = const [],
    this.sections = const [],
    this.classId,
    this.sectionId,
    required this.date,
    this.roster = const [],
    this.statusByStudent = const {},
    this.isLoading = false,
    this.isSaving = false,
    this.error,
  });

  AttendanceMarkingState copyWith({
    List<ClassOptionModel>? classes,
    List<SectionOptionModel>? sections,
    int? classId,
    int? sectionId,
    DateTime? date,
    List<RosterStudentModel>? roster,
    Map<int, String>? statusByStudent,
    bool? isLoading,
    bool? isSaving,
    String? error,
    bool clearSections = false,
    bool clearSectionId = false,
    bool clearError = false,
  }) {
    return AttendanceMarkingState(
      classes: classes ?? this.classes,
      sections: clearSections ? const [] : (sections ?? this.sections),
      classId: classId ?? this.classId,
      sectionId: clearSectionId ? null : (sectionId ?? this.sectionId),
      date: date ?? this.date,
      roster: roster ?? this.roster,
      statusByStudent: statusByStudent ?? this.statusByStudent,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      error: clearError ? null : (error ?? this.error),
    );
  }

  String get formattedDate => DateFormat('yyyy-MM-dd').format(date);
}

class AttendanceMarkingController extends StateNotifier<AttendanceMarkingState> {
  AttendanceMarkingController(this._repository, this._userId)
      : super(AttendanceMarkingState(date: DateTime.now())) {
    _loadClasses();
  }

  final AttendanceMarkingRepository _repository;
  final int _userId;

  Future<void> _loadClasses() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final classes = await _repository.fetchClasses(_userId);
      state = state.copyWith(classes: classes, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> selectClass(int classId) async {
    state = state.copyWith(
      classId: classId,
      clearSectionId: true,
      clearSections: true,
      roster: const [],
      statusByStudent: const {},
    );
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final sections = await _repository.fetchSections(_userId, classId);
      state = state.copyWith(sections: sections, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> selectSection(int sectionId) async {
    state = state.copyWith(sectionId: sectionId);
    await _loadRoster();
  }

  Future<void> selectDate(DateTime date) async {
    state = state.copyWith(date: date);
    await _loadRoster();
  }

  Future<void> _loadRoster() async {
    final classId = state.classId;
    final sectionId = state.sectionId;
    if (classId == null || sectionId == null) return;

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final roster = await _repository.fetchRoster(
        classId: classId,
        sectionId: sectionId,
        date: state.formattedDate,
      );
      final statuses = <int, String>{
        for (final student in roster)
          if (student.existingStatus != null) student.studentId: student.existingStatus!,
      };
      state = state.copyWith(roster: roster, statusByStudent: statuses, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void setStatus(int studentId, String status) {
    final updated = Map<int, String>.from(state.statusByStudent)..[studentId] = status;
    state = state.copyWith(statusByStudent: updated);
  }

  Future<bool> save() async {
    final classId = state.classId;
    final sectionId = state.sectionId;
    if (classId == null || sectionId == null) return false;

    state = state.copyWith(isSaving: true, clearError: true);
    try {
      final records = state.statusByStudent.entries
          .map((entry) => {'student_id': entry.key, 'status': entry.value, 'note': ''})
          .toList();
      await _repository.saveAttendance(
        classId: classId,
        sectionId: sectionId,
        date: state.formattedDate,
        records: records,
      );
      state = state.copyWith(isSaving: false);
      return true;
    } catch (e) {
      state = state.copyWith(isSaving: false, error: e.toString());
      return false;
    }
  }
}

final attendanceMarkingControllerProvider =
    StateNotifierProvider.autoDispose<AttendanceMarkingController, AttendanceMarkingState>((ref) {
  final userId = ref.watch(authControllerProvider).user?.id ?? 0;
  return AttendanceMarkingController(ref.watch(attendanceMarkingRepositoryProvider), userId);
});
