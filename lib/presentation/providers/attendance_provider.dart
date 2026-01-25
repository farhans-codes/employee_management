import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/models/attendance_model.dart';

class AttendanceProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<AttendanceModel> _attendances = [];
  AttendanceMeta? _meta;
  bool _isLoading = false;
  String? _errorMessage;

  List<AttendanceModel> get attendances => _attendances;
  AttendanceMeta? get meta => _meta;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Fetch attendance from Firestore
  Future<void> fetchAttendance(String token, {int? month, int? year}) async {
    final user = _auth.currentUser;
    if (user == null) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final now = DateTime.now();
    final targetMonth = month ?? now.month;
    final targetYear = year ?? now.year;

    try {
      // Create a date range for the selected month to filter Firestore
      final startDateStr = DateFormat(
        'yyyy-MM-01',
      ).format(DateTime(targetYear, targetMonth));
      final endDateStr = DateFormat(
        'yyyy-MM-dd',
      ).format(DateTime(targetYear, targetMonth + 1, 0)); // Last day of month

      final querySnapshot = await _firestore
          .collection('attendance')
          .where('userId', isEqualTo: user.uid)
          .where('date', isGreaterThanOrEqualTo: startDateStr)
          .where('date', isLessThanOrEqualTo: endDateStr)
          .get();

      _attendances = querySnapshot.docs.map((doc) {
        return AttendanceModel.fromJson(doc.data());
      }).toList();

      // Sort by date descending
      _attendances.sort((a, b) => b.date.compareTo(a.date));

      // Mock meta for UI compatibility
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
  Future<bool> checkIn(String token, String workType) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      final now = DateTime.now();
      final dateStr = DateFormat('yyyy-MM-dd').format(now);
      final timeStr = DateFormat('hh:mm a').format(now);
      final dayName = DateFormat('EEEE').format(now);

      final attendanceData = {
        'userId': user.uid,
        'date': dateStr,
        'day_name': dayName,
        'in_time': timeStr,
        'out_time': '-',
        'status': 'Present',
        'work_type': workType,
        'createdAt': FieldValue.serverTimestamp(),
      };

      // Use userId + date as document ID to ensure unique entry per day
      await _firestore
          .collection('attendance')
          .doc("${user.uid}_$dateStr")
          .set(attendanceData);

      await fetchAttendance(token);
      return true;
    } catch (e) {
      debugPrint('Check-in error: $e');
      return false;
    }
  }

  // Check Out
  Future<bool> checkOut(String token) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      final now = DateTime.now();
      final dateStr = DateFormat('yyyy-MM-dd').format(now);
      final timeStr = DateFormat('hh:mm a').format(now);

      final attendanceDocRef = _firestore
          .collection('attendance')
          .doc("${user.uid}_$dateStr");

      final doc = await attendanceDocRef.get();
      if (doc.exists) {
        await attendanceDocRef.update({
          'out_time': timeStr,
          'status': 'Present',
          'updatedAt': FieldValue.serverTimestamp(),
        });

        await fetchAttendance(token);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Check-out error: $e');
      return false;
    }
  }

  // Clear session for logout
  void clearSession() {
    _attendances = [];
    _meta = null;
    notifyListeners();
  }
}
