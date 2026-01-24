class ApiConstants {
  static const String baseUrl =
      'https://8b3abf7c-20cb-453a-bfba-f314c99cc45d.mock.pstmn.io';

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
