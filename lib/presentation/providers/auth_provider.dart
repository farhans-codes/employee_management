import 'package:flutter/material.dart';
import '../../data/datasources/api_service.dart';
import '../../data/models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

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

  // Login
  Future<bool> login(String employeeId, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.login(employeeId, password);

      if (response.success && response.token != null) {
        _token = response.token;
        _loginUser = response.user;
        _isLoading = false;
        notifyListeners();

        // Fetch full profile after login
        await fetchProfile();
        return true;
      } else {
        _errorMessage = response.message;
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Login failed: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Fetch user profile
  Future<void> fetchProfile() async {
    if (_token == null) return;

    try {
      final profile = await _apiService.getProfile(_token!);
      if (profile != null) {
        _userProfile = profile;
        notifyListeners();
      }
    } catch (e) {
      // Profile fetch failed silently
    }
  }

  // Logout
  Future<void> logout() async {
    if (_token != null) {
      await _apiService.logout(_token!);
    }
    _token = null;
    _loginUser = null;
    _userProfile = null;
    _errorMessage = null;
    notifyListeners();
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
