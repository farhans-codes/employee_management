import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import '../../data/models/attendance_model.dart';

class AttendanceProvider extends ChangeNotifier {
  List<AttendanceModel> _attendances = [];
  List<AttendanceModel> _recentAttendances =
      []; // Home page এর জন্য recent logs
  AttendanceMeta? _meta;
  bool _isLoading = false;
  String? _errorMessage;
  String? _currentEmployeeId;

  List<AttendanceModel> get attendances => _attendances;
  List<AttendanceModel> get recentAttendances => _recentAttendances;
  AttendanceMeta? get meta => _meta;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void setEmployeeId(String employeeId) {
    _currentEmployeeId = employeeId;
  }

  // Fetch recent attendance for Home page (no month filter)
  Future<void> fetchRecentAttendance({int limit = 5}) async {
    if (_currentEmployeeId == null) return;

    try {
      final query = QueryBuilder<ParseObject>(ParseObject('Attendance'))
        ..whereEqualTo('employee_id', _currentEmployeeId!)
        ..orderByDescending(
          'createdAt',
        ) // System timestamp - সবচেয়ে recent আগে আসবে
        ..setLimit(limit);

      final response = await query.query();

      if (response.success && response.results != null) {
        _recentAttendances = response.results!.map((obj) {
          final att = obj as ParseObject;
          return AttendanceModel(
            date: att.get<String>('date') ?? '',
            dayName: att.get<String>('day_name') ?? '',
            inTime: att.get<String>('in_time') ?? '',
            outTime: att.get<String>('out_time') ?? '-',
            status: att.get<String>('status') ?? '',
            workType: att.get<String>('work_type') ?? '',
          );
        }).toList();
      } else {
        _recentAttendances = [];
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Fetch recent attendance error: $e');
    }
  }

  // Fetch attendance from Parse (filtered by month)
  Future<void> fetchAttendance({int? month, int? year}) async {
    if (_currentEmployeeId == null) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final now = DateTime.now();
      final targetMonth = month ?? now.month;
      final targetYear = year ?? now.year;

      // Create date prefix for the selected month
      // Date format in database is 'yyyy-MM-dd'
      final monthStr = targetMonth.toString().padLeft(2, '0');
      final datePrefix = '$targetYear-$monthStr'; // e.g., "2026-01"

      final query = QueryBuilder<ParseObject>(ParseObject('Attendance'))
        ..whereEqualTo('employee_id', _currentEmployeeId!)
        ..whereStartsWith('date', datePrefix)
        ..orderByDescending(
          'createdAt',
        ); // System timestamp - সবচেয়ে recent আগে আসবে

      final response = await query.query();

      if (response.success && response.results != null) {
        _attendances = response.results!.map((obj) {
          final att = obj as ParseObject;
          return AttendanceModel(
            date: att.get<String>('date') ?? '',
            dayName: att.get<String>('day_name') ?? '',
            inTime: att.get<String>('in_time') ?? '',
            outTime: att.get<String>('out_time') ?? '-',
            status: att.get<String>('status') ?? '',
            workType: att.get<String>('work_type') ?? '',
          );
        }).toList();
      } else {
        _attendances = [];
      }

      // Calculate meta based on fetched data
      _meta = AttendanceMeta(
        month: DateFormat('MMMM').format(DateTime(targetYear, targetMonth)),
        year: targetYear,
        totalPresent: _attendances.where((a) => a.status == 'Present').length,
        totalAbsent: 0,
        totalHolidays: 0,
      );
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Fetch attendance error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Check In
  Future<bool> checkIn(String workType) async {
    if (_currentEmployeeId == null) return false;

    final now = DateTime.now();
    final dateStr = DateFormat('yyyy-MM-dd').format(now);
    final timeStr = DateFormat('hh:mm a').format(now);
    final dayName = DateFormat('EEEE').format(now);

    try {
      final attendanceObject = ParseObject('Attendance')
        ..set('employee_id', _currentEmployeeId)
        ..set('date', dateStr)
        ..set('day_name', dayName)
        ..set('in_time', timeStr)
        ..set('out_time', '-')
        ..set('status', 'Present')
        ..set('work_type', workType);

      // Set ACL for public access
      final acl = ParseACL();
      acl.setPublicReadAccess(allowed: true);
      acl.setPublicWriteAccess(allowed: true);
      attendanceObject.setACL(acl);

      final response = await attendanceObject.save();

      if (response.success) {
        fetchRecentAttendance(); // Home page refresh
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Check-in error: $e');
      return false;
    }
  }

  // Check Out
  Future<bool> checkOut() async {
    if (_currentEmployeeId == null) return false;

    final now = DateTime.now();
    final dateStr = DateFormat('yyyy-MM-dd').format(now);
    final timeStr = DateFormat('hh:mm a').format(now);

    try {
      final query = QueryBuilder<ParseObject>(ParseObject('Attendance'))
        ..whereEqualTo('employee_id', _currentEmployeeId!)
        ..whereEqualTo('date', dateStr)
        ..orderByDescending('createdAt'); // সবচেয়ে recent check-in আগে আসবে

      final response = await query.query();

      if (response.success &&
          response.results != null &&
          response.results!.isNotEmpty) {
        final attendanceObject = response.results!.first as ParseObject;
        attendanceObject.set('out_time', timeStr);

        final saveResponse = await attendanceObject.save();
        if (saveResponse.success) {
          fetchRecentAttendance(); // Home page refresh
          return true;
        }
      }
      return false;
    } catch (e) {
      debugPrint('Check-out error: $e');
      return false;
    }
  }

  void clearSession() {
    _attendances = [];
    _recentAttendances = [];
    _meta = null;
    _currentEmployeeId = null;
    notifyListeners();
  }
}
