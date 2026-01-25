import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/datasources/api_service.dart';
import '../../data/models/task_model.dart';

class TaskProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<TaskModel> _tasks = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Track session changes for mock persistence
  final List<TaskModel> _sessionCreatedTasks = [];
  final Map<int, TaskModel> _sessionUpdatedTasks = {};
  final Set<int> _sessionDeletedTaskIds = {};

  // Getters
  List<TaskModel> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Fetch tasks
  Future<void> fetchTasks(String token, {int page = 1, int limit = 10}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.getTasks(
        token,
        page: page,
        limit: limit,
      );

      List<TaskModel> apiTasks = [];
      if (response.success) {
        apiTasks = response.data;
      } else {
        // Log error but don't clear the list if we have session tasks
        _errorMessage = 'Note: Using local data as server sync failed';
      }

      // Apply session deletions
      apiTasks.removeWhere((t) => _sessionDeletedTaskIds.contains(t.id));

      // Use a map to track combined list for easier updating/merging
      Map<int, TaskModel> combinedTasksMap = {for (var t in apiTasks) t.id: t};

      // Add back session-updated tasks
      _sessionUpdatedTasks.forEach((id, task) {
        if (!_sessionDeletedTaskIds.contains(id)) {
          combinedTasksMap[id] = task;
        }
      });

      // Add session-created tasks
      for (var newTask in _sessionCreatedTasks) {
        if (!_sessionDeletedTaskIds.contains(newTask.id)) {
          combinedTasksMap[newTask.id] = newTask;
        }
      }

      List<TaskModel> finalTasks = combinedTasksMap.values.toList();

      // Sort: newest first
      // We sort session-created tasks to the top if they have high IDs
      finalTasks.sort((a, b) {
        int dateComp = b.date.compareTo(a.date);
        if (dateComp != 0) return dateComp;
        return b.id.compareTo(a.id);
      });

      _tasks = finalTasks;
    } catch (e) {
      _errorMessage = 'Local sync error: ${e.toString()}';
      // In case of error, at least show session tasks
      _tasks = [..._sessionCreatedTasks];
    }

    _isLoading = false;
    notifyListeners();
  }

  // Create task
  Future<bool> createTask(String token, TaskModel task) async {
    // API returns success for mock, but we need to update locally
    try {
      final success = await _apiService.createTask(token, task);

      if (success) {
        final now = DateTime.now();
        // Generate a pseudo-unique ID for session
        final mockId = DateTime.now().millisecondsSinceEpoch;
        final dayName = DateFormat('EEEE').format(now);
        final dateStr = DateFormat('yyyy-MM-dd').format(now);

        final newTask = task.copyWith(
          id: mockId,
          dayName: dayName,
          date: dateStr,
        );

        _sessionCreatedTasks.add(newTask);

        // Refresh local list immediately
        await fetchTasks(token);
        return true;
      } else {
        _errorMessage = 'Failed to create task';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  // Update task
  Future<bool> updateTask(
    String token,
    int taskId, {
    String? status,
    String? description,
  }) async {
    try {
      final success = await _apiService.updateTask(
        token,
        taskId,
        status: status,
        description: description,
      );

      if (success) {
        // Find existing task
        final index = _tasks.indexWhere((t) => t.id == taskId);
        if (index != -1) {
          final updatedTask = _tasks[index].copyWith(
            status: status ?? _tasks[index].status,
            description: description ?? _tasks[index].description,
          );

          // Store in session updates
          _sessionUpdatedTasks[taskId] = updatedTask;

          // If it was a newly created task, update it there too
          final createdIndex = _sessionCreatedTasks.indexWhere(
            (t) => t.id == taskId,
          );
          if (createdIndex != -1) {
            _sessionCreatedTasks[createdIndex] = updatedTask;
          }

          // Update local list
          _tasks[index] = updatedTask;
          notifyListeners();
        }
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Delete task
  Future<bool> deleteTask(String token, int taskId) async {
    try {
      final success = await _apiService.deleteTask(token, taskId);

      if (success) {
        // Track deletion
        _sessionDeletedTaskIds.add(taskId);
        _sessionCreatedTasks.removeWhere((t) => t.id == taskId);
        _sessionUpdatedTasks.remove(taskId);

        // Remove from local list
        _tasks.removeWhere((t) => t.id == taskId);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _apiService.dispose();
    super.dispose();
  }
}
