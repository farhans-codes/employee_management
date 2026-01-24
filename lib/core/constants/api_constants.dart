class ApiConstants {
  static const String baseUrl =
      'https://1f3224b1-96a3-4f15-ae68-836eafa1cd33.mock.pstmn.io';

  // Auth endpoints
  static const String login = '/login';
  static const String logout = '/logout';

  // User endpoints
  static const String profile = '/profile';

  // Task endpoints
  static const String tasks = '/tasks';

  // Attendance endpoints
  static const String attendance = '/attendance';
  static const String checkIn = '/attendance/check-in';
  static const String checkOut = '/attendance/check-out';
}
