import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/datasources/api_service.dart';
import '../../data/models/attendance_model.dart';

class AttendanceProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<AttendanceModel> _attendances = [];
  AttendanceMeta? _meta;
  bool _isLoading = false;
  String? _errorMessage;

  // Track today's activity for mock persistence
  AttendanceModel? _mockTodayAttendance;

  List<AttendanceModel> get attendances => _attendances;
  AttendanceMeta? get meta => _meta;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchAttendance(String token, {int? month, int? year}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final now = DateTime.now();
    final targetMonth = month ?? now.month;
    final targetYear = year ?? now.year;

    try {
      final response = await _apiService.getAttendance(
        token,
        month: targetMonth,
        year: targetYear,
      );

      if (response.success) {
        _attendances = response.data;

        // Apply mock override if we're looking at current month
        if (_mockTodayAttendance != null &&
            targetMonth == now.month &&
            targetYear == now.year) {
          int existingIndex = _attendances.indexWhere(
            (a) => a.date == _mockTodayAttendance!.date,
          );
          if (existingIndex != -1) {
            _attendances[existingIndex] = _mockTodayAttendance!;
          } else {
            _attendances.add(_mockTodayAttendance!);
          }
        }

        // Sort by date descending
        _attendances.sort((a, b) => b.date.compareTo(a.date));
        _meta = response.meta;
      } else {
        _errorMessage = 'Failed to load attendance';
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> checkIn(String token, String workType) async {
    try {
      final success = await _apiService.checkIn(token, workType);
      if (success) {
        final now = DateTime.now();
        final dateStr = DateFormat('yyyy-MM-dd').format(now);
        final timeStr = DateFormat('hh:mm a').format(now);
        final dayName = DateFormat('EEEE').format(now);

        _mockTodayAttendance = AttendanceModel(
          date: dateStr,
          dayName: dayName,
          inTime: timeStr,
          outTime: '-',
          status: 'Present',
          workType: workType,
        );

        // Refresh data (fetchAttendance will apply the mock override)
        await fetchAttendance(token);
      }
      return success;
    } catch (e) {
      return false;
    }
  }

  Future<bool> checkOut(String token) async {
    try {
      final success = await _apiService.checkOut(token);
      if (success) {
        final now = DateTime.now();
        final timeStr = DateFormat('hh:mm a').format(now);

        if (_mockTodayAttendance != null) {
          _mockTodayAttendance = AttendanceModel(
            date: _mockTodayAttendance!.date,
            dayName: _mockTodayAttendance!.dayName,
            inTime: _mockTodayAttendance!.inTime,
            outTime: timeStr,
            status: _mockTodayAttendance!.status,
            workType: _mockTodayAttendance!.workType,
          );
        }

        // Refresh data
        await fetchAttendance(token);
      }
      return success;
    } catch (e) {
      return false;
    }
  }
}
