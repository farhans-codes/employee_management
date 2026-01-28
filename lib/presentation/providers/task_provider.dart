import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import '../../data/models/task_model.dart';

class TaskProvider extends ChangeNotifier {
  List<TaskModel> _tasks = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _currentEmployeeId;

  // Pagination constants
  static const int _defaultPageSize = 20;

  List<TaskModel> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void setEmployeeId(String employeeId) {
    _currentEmployeeId = employeeId;
  }

  // Fetch tasks from Parse with pagination support
  Future<void> fetchTasks({int page = 1, int limit = _defaultPageSize}) async {
    if (_currentEmployeeId == null) {
      _errorMessage = 'Employee ID not set';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final query = QueryBuilder<ParseObject>(ParseObject('Tasks'))
        ..whereEqualTo('employee_id', _currentEmployeeId!)
        ..orderByDescending('createdAt')
        ..setLimit(limit)
        ..setAmountToSkip((page - 1) * limit);

      final response = await query.query();

      if (response.success && response.results != null) {
        _tasks = response.results!.map((obj) {
          final task = obj as ParseObject;
          return TaskModel(
            id: task.get<int>('task_id') ?? 0,
            dayName: task.get<String>('day_name') ?? '',
            date: task.get<String>('date') ?? '',
            timeSlot: task.get<String>('time_slot') ?? '',
            status: task.get<String>('status') ?? '',
            description: task.get<String>('description') ?? '',
          );
        }).toList();
      }
    } catch (e) {
      _errorMessage = 'Failed to load tasks: ${e.toString()}';
      debugPrint('Fetch tasks error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Helper to set public ACL
  void _setPublicACL(ParseObject object) {
    final acl = ParseACL()
      ..setPublicReadAccess(allowed: true)
      ..setPublicWriteAccess(allowed: true);
    object.setACL(acl);
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

      _setPublicACL(taskObject);

      final response = await taskObject.save();

      if (response.success) {
        await fetchTasks();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Create task error: $e');
      _errorMessage = 'Failed to create task: ${e.toString()}';
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
    if (_currentEmployeeId == null) return false;

    try {
      final query = QueryBuilder<ParseObject>(ParseObject('Tasks'))
        ..whereEqualTo('task_id', taskId)
        ..setLimit(1);

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
          }
          notifyListeners();
          return true;
        }
      }
      return false;
    } catch (e) {
      debugPrint('Update task error: $e');
      _errorMessage = 'Failed to update task: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  // Delete task from Parse
  Future<bool> deleteTask(int taskId) async {
    if (_currentEmployeeId == null) return false;

    try {
      final query = QueryBuilder<ParseObject>(ParseObject('Tasks'))
        ..whereEqualTo('task_id', taskId)
        ..setLimit(1);

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
      _errorMessage = 'Failed to delete task: ${e.toString()}';
      debugPrint('Delete task error: $e');
      notifyListeners();
      return false;
    }
  }

  void clearSession() {
    _tasks.clear();
    _currentEmployeeId = null;
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _tasks.clear();
    super.dispose();
  }
}
