import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/models/task_model.dart';

class TaskProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<TaskModel> _tasks = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Track session changes is no longer needed as Firestore provides persistence
  // but we keep the getters for UI compatibility

  // Getters
  List<TaskModel> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Fetch tasks from Firestore
  Future<void> fetchTasks(String token, {int page = 1, int limit = 10}) async {
    final user = _auth.currentUser;
    if (user == null) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final querySnapshot = await _firestore
          .collection('tasks')
          .where('userId', isEqualTo: user.uid)
          .orderBy('date', descending: true)
          .orderBy('id', descending: true)
          .get();

      _tasks = querySnapshot.docs.map((doc) {
        return TaskModel.fromJson(doc.data());
      }).toList();
    } catch (e) {
      _errorMessage = 'Cloud sync error: ${e.toString()}';
      debugPrint('Fetch tasks error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // Create task in Firestore
  Future<bool> createTask(String token, TaskModel task) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      final now = DateTime.now();
      final mockId = now.millisecondsSinceEpoch;
      final dayName = DateFormat('EEEE').format(now);
      final dateStr = DateFormat('yyyy-MM-dd').format(now);

      final newTask = task.copyWith(
        id: mockId,
        dayName: dayName,
        date: dateStr,
      );

      final taskData = newTask.toJson();
      taskData['userId'] = user.uid;
      taskData['createdAt'] = FieldValue.serverTimestamp();

      await _firestore.collection('tasks').doc(mockId.toString()).set(taskData);

      // Refresh local list
      await fetchTasks(token);
      return true;
    } catch (e) {
      _errorMessage = 'Error: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  // Update task in Firestore
  Future<bool> updateTask(
    String token,
    int taskId, {
    String? status,
    String? description,
  }) async {
    try {
      final updateData = <String, dynamic>{};
      if (status != null) updateData['status'] = status;
      if (description != null) updateData['description'] = description;
      updateData['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore
          .collection('tasks')
          .doc(taskId.toString())
          .update(updateData);

      // Update local list for immediate UI feedback
      final index = _tasks.indexWhere((t) => t.id == taskId);
      if (index != -1) {
        _tasks[index] = _tasks[index].copyWith(
          status: status ?? _tasks[index].status,
          description: description ?? _tasks[index].description,
        );
        notifyListeners();
      }
      return true;
    } catch (e) {
      debugPrint('Update task error: $e');
      return false;
    }
  }

  // Delete task from Firestore
  Future<bool> deleteTask(String token, int taskId) async {
    try {
      await _firestore.collection('tasks').doc(taskId.toString()).delete();

      // Remove from local list
      _tasks.removeWhere((t) => t.id == taskId);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Delete task error: $e');
      return false;
    }
  }

  // Reset for logout
  void clearSession() {
    _tasks = [];
    notifyListeners();
  }
}
