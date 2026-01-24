import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../models/user_model.dart';
import '../models/task_model.dart';
import '../models/attendance_model.dart';

class ApiService {
  final http.Client _client = http.Client();

  // Headers for API calls
  Map<String, String> _getHeaders({String? token}) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // ==================== AUTH ====================

  Future<LoginResponse> login(String employeeId, String password) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.login}');
      // Postman mock matching is strict with whitespace.
      // Using an encoder with 4 spaces to match the collection examples.
      const encoder = JsonEncoder.withIndent('    ');
      final body = encoder.convert({
        'employee_id': employeeId,
        'password': password,
      });

      print('--- API REQUEST ---');
      print('URL: $url');
      print('Body: (formatted for mock matching)\n$body');

      final response = await _client.post(
        url,
        headers: _getHeaders(),
        body: body,
      );

      print('--- API RESPONSE ---');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.body.isEmpty) {
        return LoginResponse(
          success: false,
          message:
              'Server returned an empty response (Status: ${response.statusCode})',
        );
      }

      final data = jsonDecode(response.body);
      final loginResp = LoginResponse.fromJson(data);

      // If server returns error status code but success:true (unlikely but safe to check)
      if (response.statusCode != 200 &&
          response.statusCode != 201 &&
          loginResp.success) {
        return LoginResponse(
          success: false,
          message: loginResp.message.isNotEmpty
              ? loginResp.message
              : 'Error: ${response.statusCode}',
        );
      }

      return loginResp;
    } catch (e) {
      print('--- API ERROR ---');
      print('Error: $e');
      return LoginResponse(
        success: false,
        message: 'Connection error: ${e.toString()}',
      );
    }
  }

  Future<bool> logout(String token) async {
    try {
      final response = await _client.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.logout}'),
        headers: _getHeaders(token: token),
      );

      final data = jsonDecode(response.body);
      return data['success'] ?? false;
    } catch (e) {
      return false;
    }
  }

  // ==================== USER ====================

  Future<UserModel?> getProfile(String token) async {
    try {
      final response = await _client.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.profile}'),
        headers: _getHeaders(token: token),
      );

      final data = jsonDecode(response.body);
      if (data['success'] == true && data['data'] != null) {
        return UserModel.fromJson(data['data']);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // ==================== TASKS ====================

  Future<TaskListResponse> getTasks(
    String token, {
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _client.get(
        Uri.parse(
          '${ApiConstants.baseUrl}${ApiConstants.tasks}?page=$page&limit=$limit',
        ),
        headers: _getHeaders(token: token),
      );

      final data = jsonDecode(response.body);
      return TaskListResponse.fromJson(data);
    } catch (e) {
      return TaskListResponse(success: false, data: []);
    }
  }

  Future<TaskModel?> getTask(String token, int taskId) async {
    try {
      final response = await _client.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.tasks}/$taskId'),
        headers: _getHeaders(token: token),
      );

      final data = jsonDecode(response.body);
      if (data['success'] == true && data['data'] != null) {
        return TaskModel.fromJson(data['data']);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> createTask(String token, TaskModel task) async {
    try {
      final response = await _client.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.tasks}'),
        headers: _getHeaders(token: token),
        body: jsonEncode(task.toCreateJson()),
      );

      final data = jsonDecode(response.body);
      return data['success'] ?? false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateTask(
    String token,
    int taskId, {
    String? status,
    String? description,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (status != null) body['status'] = status;
      if (description != null) body['description'] = description;

      final response = await _client.put(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.tasks}/$taskId'),
        headers: _getHeaders(token: token),
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);
      return data['success'] ?? false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteTask(String token, int taskId) async {
    try {
      final response = await _client.delete(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.tasks}/$taskId'),
        headers: _getHeaders(token: token),
      );

      final data = jsonDecode(response.body);
      return data['success'] ?? false;
    } catch (e) {
      return false;
    }
  }

  // ==================== ATTENDANCE ====================

  Future<AttendanceResponse> getAttendance(
    String token, {
    required int month,
    required int year,
  }) async {
    try {
      final monthStr = month.toString().padLeft(2, '0');
      final response = await _client.get(
        Uri.parse(
          '${ApiConstants.baseUrl}${ApiConstants.attendance}?month=$monthStr&year=$year',
        ),
        headers: _getHeaders(token: token),
      );

      final data = jsonDecode(response.body);
      return AttendanceResponse.fromJson(data);
    } catch (e) {
      return AttendanceResponse(success: false, data: []);
    }
  }

  Future<bool> checkIn(String token, String workType) async {
    try {
      final response = await _client.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.checkIn}'),
        headers: _getHeaders(token: token),
        body: jsonEncode({'work_type': workType}),
      );

      final data = jsonDecode(response.body);
      return data['success'] ?? false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> checkOut(String token) async {
    try {
      final response = await _client.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.checkOut}'),
        headers: _getHeaders(token: token),
      );

      final data = jsonDecode(response.body);
      return data['success'] ?? false;
    } catch (e) {
      return false;
    }
  }

  void dispose() {
    _client.close();
  }
}
