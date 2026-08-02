import 'package:go_router/go_router.dart';

import '../features/attendance/screens/add_attendance_screen.dart';
import '../features/attendance/screens/attendance_list_screen.dart';
import '../features/attendance/screens/hr_management_screen.dart';
import '../features/audit/screens/audit_log_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/splash_screen.dart';
import '../features/billing/screens/add_bill_screen.dart';
import '../features/billing/screens/bill_list_screen.dart';
import '../features/billing/screens/billing_management_screen.dart';
import '../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../features/inventory/screens/add_inventory_item_screen.dart';
import '../features/inventory/screens/inventory_item_list_screen.dart';
import '../features/inventory/screens/inventory_management_screen.dart';
import '../features/ipd/screens/add_ipd_admission_screen.dart';
import '../features/ipd/screens/ipd_admission_list_screen.dart';
import '../features/ipd/screens/ipd_management_screen.dart';
import '../features/lab/screens/add_lab_test_screen.dart';
import '../features/lab/screens/lab_management_screen.dart';
import '../features/lab/screens/lab_test_list_screen.dart';
import '../features/opd/screens/add_opd_visit_screen.dart';
import '../features/opd/screens/opd_management_screen.dart';
import '../features/opd/screens/opd_visit_list_screen.dart';
import '../features/patients/screens/add_patient_screen.dart';
import '../features/patients/screens/patient_list_screen.dart';
import '../features/patients/screens/patient_management_screen.dart';
import '../features/pharmacy/screens/add_medicine_screen.dart';
import '../features/pharmacy/screens/medicine_list_screen.dart';
import '../features/pharmacy/screens/pharmacy_management_screen.dart';
import '../features/reports/screens/reports_screen.dart';
import '../features/staff/screens/add_staff_profile_screen.dart';
import '../features/staff/screens/staff_management_screen.dart';
import '../features/staff/screens/staff_profile_list_screen.dart';

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

    // Patients
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

    // OPD
    GoRoute(
      path: '/opd',
      builder: (context, state) => const OpdManagementScreen(),
    ),
    GoRoute(
      path: '/opd/list',
      builder: (context, state) => const OpdVisitListScreen(),
    ),
    GoRoute(
      path: '/opd/add',
      builder: (context, state) => const AddOpdVisitScreen(),
    ),

    // IPD
    GoRoute(
      path: '/ipd',
      builder: (context, state) => const IpdManagementScreen(),
    ),
    GoRoute(
      path: '/ipd/list',
      builder: (context, state) => const IpdAdmissionListScreen(),
    ),
    GoRoute(
      path: '/ipd/add',
      builder: (context, state) => const AddIpdAdmissionScreen(),
    ),

    // Laboratory
    GoRoute(
      path: '/lab',
      builder: (context, state) => const LabManagementScreen(),
    ),
    GoRoute(
      path: '/lab/list',
      builder: (context, state) => const LabTestListScreen(),
    ),
    GoRoute(
      path: '/lab/add',
      builder: (context, state) => const AddLabTestScreen(),
    ),

    // Billing
    GoRoute(
      path: '/billing',
      builder: (context, state) => const BillingManagementScreen(),
    ),
    GoRoute(
      path: '/billing/list',
      builder: (context, state) => const BillListScreen(),
    ),
    GoRoute(
      path: '/billing/add',
      builder: (context, state) => const AddBillScreen(),
    ),

    // Pharmacy
    GoRoute(
      path: '/pharmacy',
      builder: (context, state) => const PharmacyManagementScreen(),
    ),
    GoRoute(
      path: '/pharmacy/list',
      builder: (context, state) => const MedicineListScreen(),
    ),
    GoRoute(
      path: '/pharmacy/add',
      builder: (context, state) => const AddMedicineScreen(),
    ),

    // Doctor / Nursing (Staff clinical profiles)
    GoRoute(
      path: '/staff',
      builder: (context, state) => const StaffManagementScreen(),
    ),
    GoRoute(
      path: '/staff/list',
      builder: (context, state) => const StaffProfileListScreen(),
    ),
    GoRoute(
      path: '/staff/add',
      builder: (context, state) => const AddStaffProfileScreen(),
    ),

    // General Inventory
    GoRoute(
      path: '/inventory',
      builder: (context, state) => const InventoryManagementScreen(),
    ),
    GoRoute(
      path: '/inventory/list',
      builder: (context, state) => const InventoryItemListScreen(),
    ),
    GoRoute(
      path: '/inventory/add',
      builder: (context, state) => const AddInventoryItemScreen(),
    ),

    // HR / Attendance
    GoRoute(
      path: '/hr',
      builder: (context, state) => const HrManagementScreen(),
    ),
    GoRoute(
      path: '/hr/attendance',
      builder: (context, state) => const AttendanceListScreen(),
    ),
    GoRoute(
      path: '/hr/attendance/add',
      builder: (context, state) => const AddAttendanceScreen(),
    ),

    // Reports
    GoRoute(
      path: '/reports',
      builder: (context, state) => const ReportsScreen(),
    ),

    // Audit Log
    GoRoute(
      path: '/audit',
      builder: (context, state) => const AuditLogScreen(),
    ),
  ],
);
