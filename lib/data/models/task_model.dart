class TaskModel {
  final int id;
  final String dayName;
  final String date;
  final String timeSlot;
  final String status;
  final String description;

  TaskModel({
    required this.id,
    required this.dayName,
    required this.date,
    required this.timeSlot,
    required this.status,
    required this.description,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] ?? 0,
      dayName: json['day_name'] ?? '',
      date: json['date'] ?? '',
      timeSlot: json['time_slot'] ?? '',
      status: json['status'] ?? '',
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'day_name': dayName,
      'date': date,
      'time_slot': timeSlot,
      'status': status,
      'description': description,
    };
  }

  // For creating new task (without id)
  Map<String, dynamic> toCreateJson() {
    return {
      'date': date,
      'time_slot': timeSlot,
      'status': status,
      'description': description,
    };
  }

  // Copy with method for updating
  TaskModel copyWith({
    int? id,
    String? dayName,
    String? date,
    String? timeSlot,
    String? status,
    String? description,
  }) {
    return TaskModel(
      id: id ?? this.id,
      dayName: dayName ?? this.dayName,
      date: date ?? this.date,
      timeSlot: timeSlot ?? this.timeSlot,
      status: status ?? this.status,
      description: description ?? this.description,
    );
  }
}

class TaskListResponse {
  final bool success;
  final TaskMeta? meta;
  final List<TaskModel> data;

  TaskListResponse({required this.success, this.meta, required this.data});

  factory TaskListResponse.fromJson(Map<String, dynamic> json) {
    return TaskListResponse(
      success: json['success'] ?? false,
      meta: json['meta'] != null ? TaskMeta.fromJson(json['meta']) : null,
      data:
          (json['data'] as List<dynamic>?)
              ?.map((e) => TaskModel.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class TaskMeta {
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  TaskMeta({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory TaskMeta.fromJson(Map<String, dynamic> json) {
    return TaskMeta(
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 10,
      total: json['total'] ?? 0,
      totalPages: json['total_pages'] ?? 1,
    );
  }
}
