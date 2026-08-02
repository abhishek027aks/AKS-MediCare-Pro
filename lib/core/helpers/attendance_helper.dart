// ===========================================================
// AKS MediCare Pro
// Attendance Helper
//
// Shared lookup lists used across the HR / Staff Attendance
// module.
// ===========================================================

class AttendanceHelper {
  AttendanceHelper._();

  static const List<String> statuses = [
    'Present',
    'Absent',
    'Half Day',
    'On Leave',
    'Holiday',
  ];
}
