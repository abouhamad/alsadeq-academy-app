import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/attendance/presentation/screens/attendance_screen.dart';
import '../../features/attendance_marking/presentation/screens/attendance_marking_screen.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_shell.dart';
import '../../features/dismissal/presentation/screens/dismissal_screen.dart';
import '../../features/exams/presentation/screens/exam_results_screen.dart';
import '../../features/fees/presentation/screens/fees_screen.dart';
import '../../features/homework/presentation/screens/homework_detail_screen.dart';
import '../../features/homework/presentation/screens/homework_list_screen.dart';
import '../../features/messages/presentation/screens/contacts_screen.dart';
import '../../features/messages/presentation/screens/thread_screen.dart';
import '../../features/notices/presentation/screens/notices_screen.dart';
import '../../features/parent_home/presentation/screens/parent_home_screen.dart';
import '../../features/pickup/presentation/screens/pickup_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/routine/presentation/screens/parent_schedule_screen.dart';
import '../../features/routine/presentation/screens/routine_screen.dart';
import '../../features/teacher_home/presentation/screens/teacher_home_screen.dart';
import '../../shared/widgets/main_scaffold.dart';
import '../theme/app_colors.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );
  }
}

/// Bridges Riverpod state changes into a [Listenable] so go_router
/// re-evaluates its `redirect` callback whenever auth status changes,
/// without rebuilding the GoRouter instance itself (which would drop the
/// navigation stack).
class _RouterRefreshNotifier extends ChangeNotifier {
  _RouterRefreshNotifier(Ref ref) {
    ref.listen(authControllerProvider.select((state) => state.status), (_, __) {
      notifyListeners();
    });
  }
}

final _routerRefreshProvider = Provider<_RouterRefreshNotifier>((ref) {
  return _RouterRefreshNotifier(ref);
});

final routerProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = ref.watch(_routerRefreshProvider);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final status = ref.read(authControllerProvider).status;
      final path = state.matchedLocation;

      if (status == AuthStatus.unknown) {
        return path == '/' ? null : '/';
      }
      if (status == AuthStatus.unauthenticated) {
        return path == '/login' ? null : '/login';
      }
      // authenticated
      if (path == '/' || path == '/login') return '/dashboard';
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/dashboard', builder: (context, state) => const DashboardShell()),
      GoRoute(
        path: '/homework',
        builder: (context, state) =>
            const MainScaffold(currentPath: '/homework', child: HomeworkListScreen()),
      ),
      GoRoute(
        path: '/homework/detail',
        builder: (context, state) => HomeworkDetailScreen(homework: state.extra as Map<String, dynamic>),
      ),
      GoRoute(path: '/attendance', builder: (context, state) => const AttendanceScreen()),
      GoRoute(
        path: '/attendance/mark',
        builder: (context, state) =>
            const MainScaffold(currentPath: '/attendance/mark', child: AttendanceMarkingScreen()),
      ),
      GoRoute(
        path: '/notices',
        builder: (context, state) => const MainScaffold(currentPath: '/notices', child: NoticesScreen()),
      ),
      GoRoute(path: '/routine', builder: (context, state) => const RoutineScreen()),
      GoRoute(path: '/fees', builder: (context, state) => const FeesScreen()),
      GoRoute(path: '/exams', builder: (context, state) => const ExamResultsScreen()),
      GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen()),
      GoRoute(
        path: '/parent/home',
        builder: (context, state) =>
            const MainScaffold(currentPath: '/parent/home', child: ParentHomeScreen()),
      ),
      GoRoute(
        path: '/parent/schedule',
        builder: (context, state) =>
            const MainScaffold(currentPath: '/parent/schedule', child: ParentScheduleScreen()),
      ),
      GoRoute(
        path: '/pickup',
        builder: (context, state) => const MainScaffold(currentPath: '/pickup', child: PickupScreen()),
      ),
      GoRoute(
        path: '/teacher/home',
        builder: (context, state) =>
            const MainScaffold(currentPath: '/teacher/home', child: TeacherHomeScreen()),
      ),
      GoRoute(
        path: '/dismissal',
        builder: (context, state) => const MainScaffold(currentPath: '/dismissal', child: DismissalScreen()),
      ),
      GoRoute(
        path: '/messages',
        builder: (context, state) => const MainScaffold(currentPath: '/messages', child: ContactsScreen()),
      ),
      GoRoute(
        path: '/messages/thread',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return ThreadScreen(otherUserId: extra['userId'] as int, otherUserName: extra['name'] as String);
        },
      ),
    ],
  );
});
