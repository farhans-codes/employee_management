import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import '../../data/models/attendance_model.dart';

class AttendanceProvider extends ChangeNotifier {
  List<AttendanceModel> _attendances = [];
  AttendanceMeta? _meta;
  bool _isLoading = false;
  String? _errorMessage;
  String? _currentEmployeeId;

  // Pagination constants
  static const int _defaultLimit = 50;

  List<AttendanceModel> get attendances => _attendances;
  AttendanceMeta? get meta => _meta;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void setEmployeeId(String employeeId) {
    _currentEmployeeId = employeeId;
  }

  // Helper to set public ACL
  void _setPublicACL(ParseObject object) {
    final acl = ParseACL()
      ..setPublicReadAccess(allowed: true)
      ..setPublicWriteAccess(allowed: true);
    object.setACL(acl);
  }

  // Fetch attendance from Parse
  Future<void> fetchAttendance({int? month, int? year}) async {
    if (_currentEmployeeId == null) {
      _errorMessage = 'Employee ID not set';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final query = QueryBuilder<ParseObject>(ParseObject('Attendance'))
        ..whereEqualTo('employee_id', _currentEmployeeId!)
        ..orderByDescending('createdAt')
        ..setLimit(_defaultLimit);

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

        // Calculate meta based on fetched data
        final now = DateTime.now();
        final targetMonth = month ?? now.month;
        final targetYear = year ?? now.year;

        final presentCount =
            _attendances.where((a) => a.status == 'Present').length;

        _meta = AttendanceMeta(
          month: DateFormat('MMMM').format(DateTime(targetYear, targetMonth)),
          year: targetYear,
          totalPresent: presentCount,
          totalAbsent: 0,
          totalHolidays: 0,
        );
      }
    } catch (e) {
      _errorMessage = 'Failed to load attendance: ${e.toString()}';
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

      _setPublicACL(attendanceObject);

      final response = await attendanceObject.save();

      if (response.success) {
        await fetchAttendance();
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
        ..orderByDescending('createdAt')
        ..setLimit(1); // Only need the most recent check-in

      final response = await query.query();

      if (response.success &&
          response.results != null &&
          response.results!.isNotEmpty) {
        final attendanceObject = response.results!.first as ParseObject;
        attendanceObject.set('out_time', timeStr);

        final saveResponse = await attendanceObject.save();
        if (saveResponse.success) {
          await fetchAttendance();
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
    _attendances.clear();
    _meta = null;
    _currentEmployeeId = null;
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _attendances.clear();
    super.dispose();
  }
}
