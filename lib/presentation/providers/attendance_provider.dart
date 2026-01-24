import 'package:flutter/material.dart';
import '../../data/datasources/api_service.dart';
import '../../data/models/attendance_model.dart';

class AttendanceProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<AttendanceModel> _attendances = [];
  AttendanceMeta? _meta;
  bool _isLoading = false;
  String? _errorMessage;

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
        // Refresh data
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
        // Refresh data
        await fetchAttendance(token);
      }
      return success;
    } catch (e) {
      return false;
    }
  }
}
