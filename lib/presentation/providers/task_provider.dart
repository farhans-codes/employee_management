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
  final bool _useMock =
      true; // TOGGLE THIS TO SWITCH BETWEEN MOCK AND REAL BACKEND

  // Track session changes is no longer needed as Firestore provides persistence
  // but we keep the getters for UI compatibility

  // Getters
  List<TaskModel> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Fetch tasks from Firestore
  Future<void> fetchTasks({int page = 1, int limit = 10}) async {
    final user = _auth.currentUser;
    if (user == null) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (_useMock) {
        // Mock data
        await Future.delayed(const Duration(milliseconds: 800));
        _tasks = [
          TaskModel(
            id: 1,
            dayName: 'Monday',
            date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
            timeSlot: '09:00 AM - 10:00 AM',
            status: 'In Progress',
            description: 'Working on login screen UI',
          ),
          TaskModel(
            id: 2,
            dayName: 'Monday',
            date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
            timeSlot: '10:00 AM - 11:00 AM',
            status: 'Completed',
            description: 'Team meeting',
          ),
          TaskModel(
            id: 3,
            dayName: 'Tuesday',
            date: DateFormat(
              'yyyy-MM-dd',
            ).format(DateTime.now().add(const Duration(days: 1))),
            timeSlot: '02:00 PM - 04:00 PM',
            status: 'Next',
            description: 'Database schema design',
          ),
          TaskModel(
            id: 4,
            dayName: 'Wednesday',
            date: DateFormat(
              'yyyy-MM-dd',
            ).format(DateTime.now().add(const Duration(days: 2))),
            timeSlot: '11:00 AM - 12:00 PM',
            status: 'Blocking',
            description: 'Waiting for API specs',
          ),
        ];
        _isLoading = false;
        notifyListeners();
        return;
      }

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
  Future<bool> createTask(TaskModel task) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    final now = DateTime.now();
    final mockId = now.millisecondsSinceEpoch;
    final dayName = DateFormat('EEEE').format(now);
    final dateStr = DateFormat('yyyy-MM-dd').format(now);

    final newTask = task.copyWith(id: mockId, dayName: dayName, date: dateStr);

    // Optimistic Update: Add to local state first
    final originalTasks = List<TaskModel>.from(_tasks);
    _tasks.insert(0, newTask);
    // Note: If you want to keep sorting, you might want to call a sort method here
    _tasks.sort((a, b) {
      int dateCmp = b.date.compareTo(a.date);
      if (dateCmp != 0) return dateCmp;
      return b.id.compareTo(a.id);
    });
    notifyListeners();

    try {
      if (_useMock) {
        await Future.delayed(const Duration(milliseconds: 500));
        debugPrint('Mock: Created task ${mockId.toString()}');
        return true;
      }

      debugPrint('Firestore: Setting task ${mockId.toString()}');
      final taskData = newTask.toJson();
      taskData['userId'] = user.uid;
      taskData['createdAt'] = FieldValue.serverTimestamp();

      await _firestore
          .collection('tasks')
          .doc(mockId.toString())
          .set(taskData)
          .timeout(const Duration(seconds: 10));

      debugPrint('Firestore: Set success');

      // Optionally refresh in background to sync exactly with server state
      fetchTasks();
      return true;
    } catch (e) {
      debugPrint('Firestore Error (createTask): $e');
      _errorMessage = 'Error: ${e.toString()}';
      // Rollback on error
      _tasks = originalTasks;
      notifyListeners();
      return false;
    }
  }

  // Update task in Firestore
  Future<bool> updateTask(
    int taskId, {
    String? status,
    String? description,
  }) async {
    final originalTasks = List<TaskModel>.from(_tasks);
    final index = _tasks.indexWhere((t) => t.id == taskId);

    if (index != -1) {
      _tasks[index] = _tasks[index].copyWith(
        status: status ?? _tasks[index].status,
        description: description ?? _tasks[index].description,
      );
      notifyListeners();
    }

    try {
      if (_useMock) {
        await Future.delayed(const Duration(milliseconds: 500));
        debugPrint('Mock: Updated task ${taskId.toString()}');
        return true;
      }

      debugPrint('Firestore: Updating task ${taskId.toString()}');
      final updateData = <String, dynamic>{};
      if (status != null) updateData['status'] = status;
      if (description != null) updateData['description'] = description;
      updateData['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore
          .collection('tasks')
          .doc(taskId.toString())
          .update(updateData)
          .timeout(const Duration(seconds: 10));

      debugPrint('Firestore: Update success');
      return true;
    } catch (e) {
      debugPrint('Firestore Error (updateTask): $e');
      _errorMessage = 'Update error: ${e.toString()}';
      debugPrint('Update task error: $e');
      // Rollback
      _tasks = originalTasks;
      notifyListeners();
      return false;
    }
  }

  // Delete task from Firestore
  Future<bool> deleteTask(int taskId) async {
    final originalTasks = List<TaskModel>.from(_tasks);
    _tasks.removeWhere((t) => t.id == taskId);
    notifyListeners();

    try {
      if (_useMock) {
        await Future.delayed(const Duration(milliseconds: 500));
        debugPrint('Mock: Deleted task ${taskId.toString()}');
        return true;
      }

      await _firestore.collection('tasks').doc(taskId.toString()).delete();
      return true;
    } catch (e) {
      _errorMessage = 'Delete error: ${e.toString()}';
      debugPrint('Delete task error: $e');
      // Rollback
      _tasks = originalTasks;
      notifyListeners();
      return false;
    }
  }

  // Reset for logout
  void clearSession() {
    _tasks = [];
    notifyListeners();
  }
}
