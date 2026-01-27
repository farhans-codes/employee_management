import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import '../../data/models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  String? _token;
  LoginUser? _loginUser;
  UserModel? _userProfile;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  String? get token => _token;
  LoginUser? get loginUser => _loginUser;
  UserModel? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _token != null;

  // Initialize auth state
  Future<void> init() async {
    // Check if user session exists
  }

  // Login (Simulated - will use Parse Objects for profile)
  Future<bool> login(String employeeId, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Hardcoded credentials for demo
      bool isValid = false;
      if (employeeId == 'L3T2077' && password == 'password123') {
        isValid = true;
      } else if (employeeId == 'L3T2088' && password == 'password456') {
        isValid = true;
      }

      if (!isValid) {
        throw 'Invalid Employee ID or Password';
      }

      // Authenticate with Parse (Anonymous login)
      ParseUser? currentUser = await ParseUser.currentUser() as ParseUser?;

      // If no user or previous session is invalid (checked via simple query or just blindly login)
      if (currentUser == null) {
        final user = ParseUser(null, null, null);
        final response = await user.loginAnonymous();
        if (!response.success) {
          throw 'Failed to connect to server: ${response.error?.message}';
        }
      } else {
        // Verify current session is valid
        final response = await currentUser.getUpdatedUser();
        if (!response.success && response.error?.code == 209) {
          // Session invalid, logout and re-login
          await currentUser.logout();
          final user = ParseUser(null, null, null);
          final loginResponse = await user.loginAnonymous();
          if (!loginResponse.success) {
            throw 'Failed to refresh session: ${loginResponse.error?.message}';
          }
        }
      }

      // Generate a mock token
      _token = 'parse_token_${DateTime.now().millisecondsSinceEpoch}';

      // Fetch or create profile from Parse
      await fetchProfile(employeeId);

      if (_userProfile == null) {
        await _createProfile(employeeId);
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Fetch user profile from Parse
  Future<void> fetchProfile(String employeeId) async {
    try {
      final query = QueryBuilder<ParseObject>(ParseObject('Users'))
        ..whereEqualTo('employee_id', employeeId);

      final response = await query.query();

      if (response.success &&
          response.results != null &&
          response.results!.isNotEmpty) {
        final userObject = response.results!.first as ParseObject;
        _userProfile = UserModel(
          employeeId: userObject.get<String>('employee_id') ?? '',
          name: userObject.get<String>('name') ?? '',
          designation: userObject.get<String>('designation') ?? '',
          role: userObject.get<String>('role') ?? 'Employee',
          department: userObject.get<String>('department') ?? '',
          location: userObject.get<String>('location') ?? '',
          profileImage: userObject.get<String>('profile_image') ?? '',
          personalDetails: PersonalDetails.fromJson(
            Map<String, dynamic>.from(
              userObject.get<Map>('personal_details') ?? {},
            ),
          ),
        );
        _loginUser = LoginUser(
          id: _userProfile!.employeeId,
          name: _userProfile!.name,
          role: _userProfile!.role,
        );
      }
    } catch (e) {
      debugPrint('Profile fetch error: $e');
    }
  }

  // Create profile in Parse if not exists
  Future<void> _createProfile(String employeeId) async {
    final mockData = _getMockUserData(employeeId);

    try {
      final userObject = ParseObject('Users')
        ..set('employee_id', mockData['employee_id'])
        ..set('name', mockData['name'])
        ..set('designation', mockData['designation'])
        ..set('role', mockData['role'])
        ..set('department', mockData['department'])
        ..set('location', mockData['location'])
        ..set('profile_image', mockData['profile_image'])
        ..set('personal_details', mockData['personal_details']);

      // Set ACL for public access to profile
      final acl = ParseACL();
      acl.setPublicReadAccess(allowed: true);
      acl.setPublicWriteAccess(allowed: true);
      userObject.setACL(acl);

      final response = await userObject.save();

      if (response.success) {
        _userProfile = UserModel.fromJson(mockData);
        _loginUser = LoginUser(
          id: _userProfile!.employeeId,
          name: _userProfile!.name,
          role: _userProfile!.role,
        );
      }
    } catch (e) {
      debugPrint('Create profile error: $e');
    }
  }

  // Helper to get mock user data
  Map<String, dynamic> _getMockUserData(String employeeId) {
    final bool isKaniz = employeeId == 'L3T2077';

    return {
      'employee_id': employeeId,
      'name': isKaniz ? 'Kaniz Fatima' : 'Rahim Uddin',
      'designation': isKaniz ? 'Senior Executive' : 'Software Engineer',
      'role': isKaniz ? 'Senior Executive' : 'Software Engineer',
      'department': 'Operations',
      'location': 'Dhaka, Bangladesh',
      'profile_image': isKaniz
          ? 'https://ui-avatars.com/api/?name=Kaniz+Fatima&background=0D8ABC&color=fff&size=150'
          : 'https://ui-avatars.com/api/?name=Rahim+Uddin&background=5D4037&color=fff&size=150',
      'personal_details': {
        'joining_date': '2024-01-01',
        'confirmation_date': '2024-04-01',
        'service_length': '1 Year',
      },
    };
  }

  // Logout
  Future<void> logout() async {
    _token = null;
    _loginUser = null;
    _userProfile = null;
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
