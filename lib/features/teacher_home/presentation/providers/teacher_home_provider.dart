import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers.dart';
import '../../data/models/day_schedule_entry_model.dart';
import '../../data/teacher_home_repository.dart';

final teacherHomeRepositoryProvider = Provider<TeacherHomeRepository>((ref) {
  return TeacherHomeRepository(ref.watch(apiClientProvider));
});

final teacherScheduleProvider = FutureProvider.autoDispose<List<DayScheduleEntryModel>>((ref) {
  return ref.watch(teacherHomeRepositoryProvider).fetchSchedule();
});

final selectedScheduleDayProvider = StateProvider<String>((ref) {
  const weekDays = [
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
  ];
  return weekDays[DateTime.now().weekday % 7];
});
