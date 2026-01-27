import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import '../../data/models/task_model.dart';

class TaskProvider extends ChangeNotifier {
  List<TaskModel> _tasks = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _currentEmployeeId;

  List<TaskModel> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void setEmployeeId(String employeeId) {
    _currentEmployeeId = employeeId;
  }

  // Fetch tasks from Parse
  Future<void> fetchTasks({int page = 1, int limit = 10}) async {
    if (_currentEmployeeId == null) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final query = QueryBuilder<ParseObject>(ParseObject('Tasks'))
        ..whereEqualTo('employee_id', _currentEmployeeId!)
        ..orderByDescending('date')
        ..orderByDescending('createdAt');

      final response = await query.query();

      if (response.success && response.results != null) {
        _tasks = response.results!.map((obj) {
          final task = obj as ParseObject;
          return TaskModel(
            id:
                int.tryParse(task.objectId ?? '0') ??
                task.get<int>('task_id') ??
                0,
            dayName: task.get<String>('day_name') ?? '',
            date: task.get<String>('date') ?? '',
            timeSlot: task.get<String>('time_slot') ?? '',
            status: task.get<String>('status') ?? '',
            description: task.get<String>('description') ?? '',
          );
        }).toList();
      }
    } catch (e) {
      _errorMessage = 'Error: ${e.toString()}';
      debugPrint('Fetch tasks error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // Create task in Parse
  Future<bool> createTask(TaskModel task) async {
    if (_currentEmployeeId == null) return false;

    final now = DateTime.now();
    final dayName = DateFormat('EEEE').format(now);
    final dateStr = DateFormat('yyyy-MM-dd').format(now);

    try {
      // Generate a unique task_id
      final taskId = DateTime.now().millisecondsSinceEpoch;

      final taskObject = ParseObject('Tasks')
        ..set('task_id', taskId)
        ..set('employee_id', _currentEmployeeId)
        ..set('day_name', dayName)
        ..set('date', dateStr)
        ..set('time_slot', task.timeSlot)
        ..set('status', task.status)
        ..set('description', task.description);

      // Set ACL for public access (since we are handling auth manually)
      final acl = ParseACL();
      acl.setPublicReadAccess(allowed: true);
      acl.setPublicWriteAccess(allowed: true);
      taskObject.setACL(acl);

      final response = await taskObject.save();

      if (response.success) {
        await fetchTasks(); // Refresh list
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Create task error: $e');
      _errorMessage = 'Error: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  // Update task in Parse
  Future<bool> updateTask(
    int taskId, {
    String? status,
    String? description,
  }) async {
    try {
      // Find the task by task_id or objectId
      final query = QueryBuilder<ParseObject>(ParseObject('Tasks'))
        ..whereEqualTo('task_id', taskId);

      final response = await query.query();

      if (response.success &&
          response.results != null &&
          response.results!.isNotEmpty) {
        final taskObject = response.results!.first as ParseObject;

        if (status != null) taskObject.set('status', status);
        if (description != null) taskObject.set('description', description);

        final saveResponse = await taskObject.save();

        if (saveResponse.success) {
          // Update local state
          final index = _tasks.indexWhere((t) => t.id == taskId);
          if (index != -1) {
            _tasks[index] = _tasks[index].copyWith(
              status: status ?? _tasks[index].status,
              description: description ?? _tasks[index].description,
            );
            notifyListeners();
          }
          return true;
        }
      }
      return false;
    } catch (e) {
      debugPrint('Update task error: $e');
      _errorMessage = 'Error: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  // Delete task from Parse
  Future<bool> deleteTask(int taskId) async {
    try {
      final query = QueryBuilder<ParseObject>(ParseObject('Tasks'))
        ..whereEqualTo('task_id', taskId);

      final response = await query.query();

      if (response.success &&
          response.results != null &&
          response.results!.isNotEmpty) {
        final taskObject = response.results!.first as ParseObject;
        final deleteResponse = await taskObject.delete();

        if (deleteResponse.success) {
          _tasks.removeWhere((t) => t.id == taskId);
          notifyListeners();
          return true;
        }
      }
      return false;
    } catch (e) {
      _errorMessage = 'Delete error: ${e.toString()}';
      debugPrint('Delete task error: $e');
      notifyListeners();
      return false;
    }
  }

  void clearSession() {
    _tasks = [];
    _currentEmployeeId = null;
    notifyListeners();
  }
}
