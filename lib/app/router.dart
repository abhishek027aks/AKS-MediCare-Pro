import 'package:go_router/go_router.dart';

import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/splash_screen.dart';
import '../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../features/patients/screens/patient_management_screen.dart';
import '../features/patients/screens/patient_list_screen.dart';
import '../features/patients/screens/add_patient_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const DashboardScreen(),
    ),
    GoRoute(
      path: '/patients',
      builder: (context, state) => const PatientManagementScreen(),
    ),
    GoRoute(
      path: '/patients/list',
      builder: (context, state) => const PatientListScreen(),
    ),
    GoRoute(
      path: '/patients/add',
      builder: (context, state) => const AddPatientScreen(),
    ),
  ],
);
