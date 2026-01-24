import 'package:flutter/material.dart';
import '../../data/datasources/api_service.dart';
import '../../data/models/task_model.dart';

class TaskProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<TaskModel> _tasks = [];
  bool _isLoading = false;
  String? _errorMessage;

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

      if (response.success) {
        _tasks = response.data;
      } else {
        _errorMessage = 'Failed to fetch tasks';
      }
    } catch (e) {
      _errorMessage = 'Error: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
  }

  // Create task
  Future<bool> createTask(String token, TaskModel task) async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _apiService.createTask(token, task);

      if (success) {
        // Refresh task list
        await fetchTasks(token);
        return true;
      } else {
        _errorMessage = 'Failed to create task';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error: ${e.toString()}';
      _isLoading = false;
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
        // Update local task
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
