class UserModel {
  final String employeeId;
  final String name;
  final String designation;
  final String profileImage;
  final String department;
  final String location;
  final String role;
  final PersonalDetails personalDetails;

  UserModel({
    required this.employeeId,
    required this.name,
    required this.designation,
    required this.profileImage,
    required this.department,
    required this.location,
    required this.role,
    required this.personalDetails,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      employeeId: json['employee_id'] ?? '',
      name: json['name'] ?? '',
      designation: json['designation'] ?? '',
      profileImage: json['profile_image'] ?? '',
      department: json['department'] ?? '',
      location: json['location'] ?? '',
      role: json['role'] ?? 'Employee',
      personalDetails: PersonalDetails.fromJson(json['personal_details'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'employee_id': employeeId,
      'name': name,
      'designation': designation,
      'profile_image': profileImage,
      'department': department,
      'location': location,
      'role': role,
      'personal_details': personalDetails.toJson(),
    };
  }
}

class PersonalDetails {
  final String joiningDate;
  final String confirmationDate;
  final String serviceLength;

  PersonalDetails({
    required this.joiningDate,
    required this.confirmationDate,
    required this.serviceLength,
  });

  factory PersonalDetails.fromJson(Map<String, dynamic> json) {
    return PersonalDetails(
      joiningDate: json['joining_date'] ?? '',
      confirmationDate: json['confirmation_date'] ?? '',
      serviceLength: json['service_length'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'joining_date': joiningDate,
      'confirmation_date': confirmationDate,
      'service_length': serviceLength,
    };
  }
}

class LoginResponse {
  final bool success;
  final String message;
  final String? token;
  final LoginUser? user;

  LoginResponse({
    required this.success,
    required this.message,
    this.token,
    this.user,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      success: json['success'] ?? false,
      message:
          json['message'] ??
          (json['success'] == true ? 'Success' : 'Authentication failed'),
      token: json['token'],
      user: json['user'] != null ? LoginUser.fromJson(json['user']) : null,
    );
  }
}

class LoginUser {
  final String id;
  final String name;
  final String role;

  LoginUser({required this.id, required this.name, required this.role});

  factory LoginUser.fromJson(Map<String, dynamic> json) {
    return LoginUser(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      role: json['role'] ?? '',
    );
  }
}
