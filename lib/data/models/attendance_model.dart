class AttendanceModel {
  final String date;
  final String dayName;
  final String inTime;
  final String outTime;
  final String status;
  final String workType;

  AttendanceModel({
    required this.date,
    required this.dayName,
    required this.inTime,
    required this.outTime,
    required this.status,
    required this.workType,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      date: json['date'] ?? '',
      dayName: json['day_name'] ?? '',
      inTime: json['in_time'] ?? '-',
      outTime: json['out_time'] ?? '-',
      status: json['status'] ?? '',
      workType: json['work_type'] ?? '-',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'day_name': dayName,
      'in_time': inTime,
      'out_time': outTime,
      'status': status,
      'work_type': workType,
    };
  }
}

class AttendanceResponse {
  final bool success;
  final AttendanceMeta? meta;
  final List<AttendanceModel> data;

  AttendanceResponse({required this.success, this.meta, required this.data});

  factory AttendanceResponse.fromJson(Map<String, dynamic> json) {
    return AttendanceResponse(
      success: json['success'] ?? false,
      meta: json['meta'] != null ? AttendanceMeta.fromJson(json['meta']) : null,
      data:
          (json['data'] as List<dynamic>?)
              ?.map((e) => AttendanceModel.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class AttendanceMeta {
  final String month;
  final int year;
  final int totalPresent;
  final int? totalAbsent;
  final int? totalHolidays;

  AttendanceMeta({
    required this.month,
    required this.year,
    required this.totalPresent,
    this.totalAbsent,
    this.totalHolidays,
  });

  factory AttendanceMeta.fromJson(Map<String, dynamic> json) {
    return AttendanceMeta(
      month: json['month'] ?? '',
      year: json['year'] ?? 0,
      totalPresent: json['total_present'] ?? 0,
      totalAbsent: json['total_absent'],
      totalHolidays: json['total_holidays'],
    );
  }
}
