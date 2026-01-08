import 'package:go_router/go_router.dart';
import 'package:campuswork/auth/auth_service.dart';
import 'package:campuswork/model/user.dart';
import 'package:campuswork/auth/login_page.dart';
import 'package:campuswork/auth/register_page.dart';
import 'package:campuswork/screen/screen_student/dashboard/dashboard.dart';
import 'package:campuswork/screen/screen_student/projects/create-project.dart';
import 'package:campuswork/screen/screen_student/dashboard/my_project.dart';
import 'package:campuswork/screen/screen_lecturer/dashboard/dashboard.dart';
import 'package:campuswork/screen/screen_admin/dashboard/dashboard.dart';
import 'package:campuswork/screen/screen_student/projects/project-grid.dart';
import 'package:campuswork/screen/screen_student/projects/project_details.dart';
import 'package:campuswork/screen/common_screen/notifications_pages.dart';

final router = GoRouter(
  initialLocation: '/',
  redirect: (context, state) {
    final isLoggedIn = AuthService().isLoggedIn;
    final currentUser = AuthService().currentUser;

    if (!isLoggedIn && state.uri.path != '/' && state.uri.path != '/register') {
      return '/';
    }

    if (isLoggedIn && state.uri.path == '/') {
      switch (currentUser!.userRole) {
        case UserRole.student:
          return '/student-dashboard';
        case UserRole.lecturer:
          return '/lecturer-dashboard';
        case UserRole.admin:
          return '/admin-dashboard';
      }
    }

    return null;
  },
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterPage(),
    ),
    GoRoute(
      path: '/student-dashboard',
      builder: (context, state) => const StudentDashboard(),
    ),
    GoRoute(
      path: '/lecturer-dashboard',
      builder: (context, state) => const LecturerDashboard(),
    ),
    GoRoute(
      path: '/admin-dashboard',
      builder: (context, state) => const AdminDashboard(),
    ),
    GoRoute(
      path: '/projects',
      builder: (context, state) => const ProjectsListPage(),
    ),
    GoRoute(
      path: '/project/:id',
      builder: (context, state) => ProjectDetailsPage(
        projectId: state.pathParameters['id']!,
      ),
    ),
    GoRoute(
      path: '/create-project',
      builder: (context, state) => const CreateProjectPage(),
    ),
    GoRoute(
      path: '/my-projects',
      builder: (context, state) => const MyProjectsPage(),
    ),
    GoRoute(
      path: '/notifications',
      builder: (context, state) => const NotificationsPage(),
    ),
  ],
);
